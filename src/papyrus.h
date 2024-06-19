#pragma once

#include "race_manager.h"

namespace race_compatibility
{
	namespace papyrus
	{
// #define BIND(a_method, ...) a_vm.RegisterFunction(#a_method##sv, script, a_method __VA_OPT__(, ) __VA_ARGS__)
#define BIND(a_method) a_vm->RegisterFunction(#a_method##sv, rcs::SCRIPT_NAME, a_method)
		static inline bool Bind(RE::BSScript::Internal::VirtualMachine* a_vm)
		{
			if (a_vm == nullptr) {
				logs::error("Can't get VM state");
				return false;
			}

			using namespace manager::vampirism;
			BIND(GetRaceByVampireRace);
			BIND(GetVampireRaceByRace);
			logs::info("Registered Vampirism Handler Functions");
			return true;
		}
#undef BIND
	}
}