#pragma once

#define WIN32_LEAN_AND_MEAN

#define NOGDICAPMASKS
#define NOVIRTUALKEYCODES
#define NOWINMESSAGES
#define NOWINSTYLES
#define NOSYSMETRICS
#define NOMENUS
#define NOICONS
#define NOKEYSTATES
#define NOSYSCOMMANDS
#define NORASTEROPS
#define NOSHOWWINDOW
#define OEMRESOURCE
#define NOATOM
#define NOCLIPBOARD
#define NOCOLOR
#define NOCTLMGR
#define NODRAWTEXT
#define NOGDI
#define NOKERNEL
#define NOUSER
// #define NONLS
#define NOMB
#define NOMEMMGR
#define NOMETAFILE
#define NOMINMAX
#define NOMSG
#define NOOPENFILE
#define NOSCROLL
#define NOSERVICE
#define NOSOUND
#define NOTEXTMETRIC
#define NOWH
#define NOWINOFFSETS
#define NOCOMM
#define NOKANJI
#define NOHELP
#define NOPROFILER
#define NODEFERWINDOWPOS
#define NOMCX

#include <RE/Skyrim.h>
#include <SKSE/SKSE.h>

#include <ClibUtil/distribution.hpp>
#include <ClibUtil/simpleINI.hpp>
#include <ClibUtil/string.hpp>

using clib_util::distribution::formid_pair;
using clib_util::distribution::record;
 
#include <srell.hpp>

namespace logs = SKSE::log;
using namespace std::literals;

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

#ifdef SKYRIM_SUPPORT_AE
#	define OFFSET(se, ae) ae
#else
#	define OFFSET(se, ae) se
#endif