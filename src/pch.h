#pragma once

#define WIN32_LEAN_AND_MEAN
#define NOMINMAX
#define NOGDI

#include <RE/Skyrim.h>
#include <SKSE/SKSE.h>

#include <ClibUtil/distribution.hpp>
#include <ClibUtil/simpleINI.hpp>
#include <ClibUtil/singleton.hpp>
#include <ClibUtil/string.hpp>

#include <srell.hpp>

namespace logs = SKSE::log;
using namespace std::literals;

#include "defs.h"
#include "forms.h"
#include "versions.h"

namespace rcs = race_compatibility;

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

#ifdef SKYRIM_AE
#	define OFFSET(se, ae) ae
#else
#	define OFFSET(se, ae) se
#endif