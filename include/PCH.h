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
	using namespace SKSE::stl;

	template <typename T>
	concept HasThunk = requires {
		T::thunk;
	} && std::is_function_v<std::remove_pointer_t<decltype(T::thunk)>>;

	template <typename T>
	concept HasID = requires {
		T::id;
	} && std::is_same_v<decltype(T::id), const REL::ID>;

	template <typename T>
	concept Hookable = HasThunk<T> && HasID<T>;

	// Incompatible with hooks at the same position
	template <HasThunk T>
	void write_jump_to_thunk(std::uintptr_t a_src)
	{
#pragma pack(push, 1)
		struct TrampolineAssembly
		{
			// 0x0: jmp [rip + 0]
			// 0x6: target
			std::uint8_t  jmp{ 0xFF };                                        // 0x0
			std::uint8_t  modrm{ 0x25 };                                      // 0x1
			std::int32_t  disp{ 0 };                                          // 0x2
			std::uint64_t addr{ reinterpret_cast<std::uint64_t>(T::thunk) };  // 0x6
		} const assembly{};
		static_assert(offsetof(TrampolineAssembly, jmp) == 0x0);
		static_assert(offsetof(TrampolineAssembly, modrm) == 0x1);
		static_assert(offsetof(TrampolineAssembly, disp) == 0x2);
		static_assert(offsetof(TrampolineAssembly, addr) == 0x6);
		static_assert(sizeof(TrampolineAssembly) == 0xE);
#pragma pack(pop)

		REL::safe_write(a_src, &assembly, sizeof(assembly));
	}

	template <typename T>
	consteval auto get_signature()
	{
#if defined(_MSC_VER)
		return std::string_view(__FUNCSIG__);
#else
		static_assert(false, "Unsupported compiler for type name extraction");
#endif
	}

	// get struct raw/unqualified name
	template <typename T>
	consteval auto raw_struct_name()
	{
		constexpr auto probe = get_signature<int>();
		constexpr auto marker = "int"sv;
		constexpr auto mp = probe.find(marker);  // marker pos
		static_assert(mp != std::string_view::npos);
		constexpr auto suffix = probe.size() - mp - marker.size();

		constexpr auto sig = get_signature<T>();
		constexpr auto keyword = "struct "sv;
		constexpr auto kp = sig.find(keyword);  // keyword pos
		static_assert(kp != std::string_view::npos);
		constexpr auto scope = "::"sv;
		constexpr auto spr = sig.rfind(scope);  // scope resolution operator r-pos
		constexpr auto prefix = [&] {
			if constexpr (spr != std::string_view::npos) {
				return spr + scope.size();
			} else {
				return kp + keyword.size();
			}
		}();

		constexpr auto size = sig.size() - prefix - suffix + 1;
		static_assert(size);

		std::array<char, size> result{};
		std::copy_n(std::next(sig.begin(), prefix), size - 1, result.begin());
		// result[view.size()] = '\0'; // unnecessary, default initialized
		return result;
	}

}  // namespace stl