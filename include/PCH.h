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
		using sv = std::string_view;

		constexpr auto probe = get_signature<int>();
		constexpr auto marker = "int"sv;
		constexpr auto marker_start = probe.find(marker);
		static_assert(marker_start != sv::npos);
		constexpr auto suffix_size = probe.size() - (marker_start + marker.size());

		constexpr auto sig = get_signature<T>();
		constexpr auto keyword = "struct "sv;
		constexpr auto kw_start = sig.find(keyword);  // struct keyword pos
		static_assert(kw_start != sv::npos);
		constexpr auto prefix_size = kw_start + keyword.size();
		static_assert(prefix_size + suffix_size < sig.size());

		constexpr auto raw = sig.substr(prefix_size, sig.size() - (prefix_size + suffix_size));
		// raw name with possible scope
		struct NameParts
		{
			std::size_t                      raw_name_start;  // unqualified name position in raw
			std::size_t                      scope_size;      // scope size
			std::array<char, raw.size() + 1> scope{};         // scope, with null terminator
		};
		constexpr auto nameparts = [] {
			constexpr auto op = "::"sv;  // scope resolution operator
			NameParts      nameparts{};

			// l,r for substr in raw, i for `scope` index
			auto& [l, i, scope] = nameparts;
			for (std::size_t r = raw.find(op, 0); r != sv::npos;
				l = r + op.size(), r = raw.find(op, l)) {
				// MSVC only
				if (raw.substr(l).starts_with("`anonymous-namespace'"sv)) {
					continue;
				}
				auto size = r + op.size() - l;  // inclusive of '::'
				std::copy_n(std::next(raw.begin(), l), size,
					std::next(scope.begin(), i));
				i += size;
			}
			return nameparts;
		}();
		constexpr auto raw_name_size = raw.size() - nameparts.raw_name_start;
		static_assert(raw_name_size);

		auto result = std::array<char, raw_name_size + nameparts.scope_size + 1>{};
		// copy scope if any
		if constexpr (nameparts.scope_size) {
			std::copy_n(nameparts.scope.begin(), nameparts.scope_size, result.begin());
		}
		// copy unqualified name
		std::copy_n(std::next(raw.begin(), nameparts.raw_name_start), raw_name_size,
			std::next(result.begin(), nameparts.scope_size));
		return result;
	}

	// for assisting, not direct use
	template <typename T>
	inline constexpr auto struct_name_for = struct_name<T>();
}  // namespace stl