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
}  // namespace stl