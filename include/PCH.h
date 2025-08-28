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

	// Incompatible with hooks at the same position, for ignoring the return value of write_call/write_branch
	template <HasThunk T>
	void write_jump_to_thunk(std::uintptr_t a_src)
	{
#pragma pack(push, 1)
		// FF /4
		// JMP r/m64
		struct TrampolineAssembly
		{
			// jmp [rip + 0]
			// target
			std::uint8_t  jmp;    // 0 - 0xFF
			std::uint8_t  modrm;  // 1 - 0x25
			std::int32_t  disp;   // 2 - 0x00000000
			std::uint64_t addr;   // 6 - [rip + 0]/target
		};
		static_assert(offsetof(TrampolineAssembly, jmp) == 0x0);
		static_assert(offsetof(TrampolineAssembly, modrm) == 0x1);
		static_assert(offsetof(TrampolineAssembly, disp) == 0x2);
		static_assert(offsetof(TrampolineAssembly, addr) == 0x6);
		static_assert(sizeof(TrampolineAssembly) == 0xE);
#pragma pack(pop)

		const TrampolineAssembly assembly{
			.jmp = 0xFFu,
			.modrm = 0x25u,
			.disp = 0,
			.addr = reinterpret_cast<std::uint64_t>(T::thunk)
		};
		//REL::safe_write(a_src, &assembly, sizeof(assembly));
		const auto count = sizeof(assembly);

		std::uint32_t old{ 0 };
		auto          success = REX::W32::VirtualProtect(
            reinterpret_cast<void*>(a_src), count, REX::W32::PAGE_EXECUTE_READWRITE, std::addressof(old));
		if (success) {
			std::memcpy(reinterpret_cast<void*>(a_src), &assembly, count);
			success = REX::W32::VirtualProtect(
				reinterpret_cast<void*>(a_src), count, old, std::addressof(old));
#ifdef NDEBUG
			// avoid unused code removal in release build
			(void)success;
#endif
		}
		assert(success);
	}
}  // namespace stl