#pragma once

#define WIN32_LEAN_AND_MEAN

#include <RE/Skyrim.h>
#include <REX/REX.h>
#include <SKSE/SKSE.h>

namespace logs = SKSE::log;
using namespace std::literals;

#include "Versions.h"

namespace stl
{
	using namespace SKSE::stl;

	// Incompatible with hooks at the same position, for ignoring the return value of write_call/write_branch
	template <typename T>
	void write_thunk_call(std::uintptr_t a_src)
	{
		auto& trampoline = SKSE::GetTrampoline();
		SKSE::AllocTrampoline(14);
		//T::func = trampoline.write_call<5>(a_src, T::thunk)
		trampoline.write_call<5>(a_src, T::thunk);
	}
	template <typename T>
	void write_thunk_branch(std::uintptr_t a_src)
	{
		auto& trampoline = SKSE::GetTrampoline();
		SKSE::AllocTrampoline(14);
		//T::func = trampoline.write_branch<5>(a_src, T::thunk);
		trampoline.write_branch<5>(a_src, T::thunk);
	}
}  // namespace stl

#ifdef SKYRIM_SUPPORT_AE
#	define OFFSET(se, ae) ae
#else
#	define OFFSET(se, ae) se
#endif