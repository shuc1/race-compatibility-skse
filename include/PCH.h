#pragma once

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
        constexpr auto npos = std::string_view::npos;

        constexpr auto probe = get_signature<int>();
        constexpr auto marker = "int"sv;
        constexpr auto markerStart = probe.find(marker);
        static_assert(markerStart != npos);
        constexpr auto suffixSize = probe.size() - (markerStart + marker.size());

        constexpr auto sig = get_signature<T>();
        constexpr auto keyword = "struct "sv;
        constexpr auto keywordStart = sig.find(keyword);  // struct keyword pos
        static_assert(keywordStart != npos);
        constexpr auto prefixSize = keywordStart + keyword.size();
        static_assert(prefixSize + suffixSize < sig.size());

        constexpr auto qualified = sig.substr(prefixSize, sig.size() - (prefixSize + suffixSize));
        // raw name with possible scope
        struct NameParts
        {
            std::size_t                            rawNameStart;  // unqualified name position in raw
            std::size_t                            scopeSize;     // scope size
            std::array<char, qualified.size() + 1> scopeData{};   // scope, with null terminator
        };
        constexpr auto nameParts = [] {
            // remove anonymous namespace(s) if any
            constexpr auto op = "::"sv;  // scope resolution operator
            NameParts      nameParts{};
            auto& [l, i, data] = nameParts;  // l,r for substr in raw, i for `scope` index
            for (auto r = qualified.find(op, 0); r != npos;
                l = r + op.size(), r = qualified.find(op, l)) {
                // MSVC only
                if (qualified.substr(l).starts_with("`anonymous-namespace'"sv)) {
                    continue;
                }
                auto size = r + op.size() - l;  // inclusive of '::'
                std::copy_n(std::next(qualified.begin(), l), size,
                    std::next(data.begin(), i));
                i += size;
            }
            return nameParts;
        }();
        constexpr auto rawNameSize = qualified.size() - nameParts.rawNameStart;
        static_assert(rawNameSize);
        auto result = std::array<char, rawNameSize + nameParts.scopeSize + 1>{};
        // copy scope if any
        if constexpr (nameParts.scopeSize) {
            std::copy_n(nameParts.scopeData.begin(), nameParts.scopeSize, result.begin());
        }
        // copy unqualified name
        std::copy_n(std::next(qualified.begin(), nameParts.rawNameStart), rawNameSize,
            std::next(result.begin(), nameParts.scopeSize));
        return result;
    }

    // for assisting, not direct use
    template <typename T>
    inline constexpr auto struct_name_for = struct_name<T>();
}  // namespace stl