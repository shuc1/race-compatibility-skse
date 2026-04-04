#pragma once

#include <cstddef>
#define WIN32_LEAN_AND_MEAN

#include <RE/Skyrim.h>
#include <SKSE/SKSE.h>

#ifdef NDEBUG
namespace logs = spdlog;
#else
namespace logs = SKSE::log;
#endif
using namespace std::literals;

#include "Versions.h"

namespace stl
{
    // godbolt: https://godbolt.org/z/vc8hnjcrb
    template <typename T>
    consteval auto get_signature()
    {
#if defined(_MSC_VER)
        return std::string_view(__FUNCSIG__);
#else
        static_assert(false, "Unsupported compiler for type name extraction");
#endif
    }

    // get struct name with scope, but without anonymous namespace (if any)
    template <typename T>
    consteval auto struct_name()
    {
        constexpr auto sig = []() {
            constexpr auto probe = get_signature<int>();
            constexpr auto sig_raw = get_signature<T>();

            constexpr auto pre_size = probe.find("int"sv);
            constexpr auto suf_size = probe.size() - pre_size - "int"sv.size();

            auto s = sig_raw.substr(pre_size, sig_raw.size() - pre_size - suf_size);
            if (s.starts_with("struct "sv))
                s.remove_prefix(7);
            else if (s.starts_with("class "sv))
                s.remove_prefix(6);
            return s;
        }();

        constexpr auto len = sig.size();
        struct NameBuffer
        {
            std::array<char, len + 1> value{};    // +1 for null terminator
            size_t                    count = 0;  // actual length without anonymous namespace parts
        } constexpr name_buffer = [&]() {
            NameBuffer                buffer{};
            auto                      it = buffer.value.begin();
            size_t                    pos = 0;
            while (pos < len) {
                auto next_op = sig.find("::"sv, pos);
                auto part = (next_op == std::string_view::npos) ? sig.substr(pos) : sig.substr(pos, next_op - pos);
                // remove anonymous namespace if any, MSVC only
                if (part != "`anonymous-namespace'"sv) {
                    it = std::copy_n(part.begin(), part.size(), it);
                    if (next_op != std::string_view::npos) {
                        *it++ = ':';
                        *it++ = ':';
                    }
                }
                pos = (next_op == std::string_view::npos) ? sig.size() : next_op + 2;
            }
            buffer.count = static_cast<size_t>(std::distance(buffer.value.begin(), it));
            return buffer;
        }();

        std::array<char, name_buffer.count + 1> result{};
        std::copy_n(name_buffer.value.begin(), name_buffer.count, result.begin());
        return result;
    }

    // for assisting, not direct use
    template <typename T>
    inline constexpr auto struct_name_for = struct_name<T>();
}  // namespace stl