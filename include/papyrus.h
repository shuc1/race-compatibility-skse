#pragma once

#include "RaceManager.h"

namespace rcs
{
	namespace papyrus
	{
#define STATIC_ARGS [[maybe_unused]] RE::BSScript::Internal::VirtualMachine *a_vm, [[maybe_unused]] RE::VMStackID a_stackID, RE::StaticFunctionTag *
		[[nodiscard]] static inline RE::TESRace* GetRaceByVampireRace(STATIC_ARGS, const RE::TESRace* a_race)
		{
			using namespace manager::vampirism;
			auto it = std::find_if(vampirism_race_pairs.begin(), vampirism_race_pairs.end(),
				[&](std::pair<RE::TESRace*, RE::TESRace*>& pair) { return pair.second == a_race; });
			return (it == vampirism_race_pairs.end()) ? nullptr : it->first;
		}

		[[nodiscard]] static inline RE::TESRace* GetVampireRaceByRace(STATIC_ARGS, const RE::TESRace* a_race)
		{
			using namespace manager::vampirism;
			auto it = std::find_if(vampirism_race_pairs.begin(), vampirism_race_pairs.end(),
				[&](std::pair<RE::TESRace*, RE::TESRace*>& pair) { return pair.first == a_race; });
			return (it == vampirism_race_pairs.end()) ? nullptr : it->second;
		}

		[[nodiscard]] static inline bool GetIsRaceByProxy(STATIC_ARGS, RE::TESRace* a_actor_race, RE::TESRace* a_race)
		{
			return manager::compatibility::GetIsRaceEqual(a_actor_race, a_race);
		}

		[[nodiscard]] static inline int GetHeadPartFlagByRace(STATIC_ARGS, RE::TESRace* a_race)
		{
			using namespace manager::headpart;
			return std::to_underlying(race_headpart_map.contains(a_race) ?
										  race_headpart_map[a_race] :
										  manager::RaceFlag::kNone);
		}
#undef STATIC_ARGS

		static inline bool Bind(RE::BSScript::Internal::VirtualMachine* a_vm)
		{
			if (a_vm == nullptr) {
				logs::error("Can't get VM state");
				return false;
			}
// #define BIND(a_method, ...) a_vm.RegisterFunction(#a_method##sv, script, a_method __VA_OPT__(, ) __VA_ARGS__)
#define BIND(a_method) a_vm->RegisterFunction(#a_method##sv, rcs::PROJECT_NAME_CAMEL, a_method)
			BIND(GetRaceByVampireRace);
			BIND(GetVampireRaceByRace);
			BIND(GetIsRaceByProxy);
			BIND(GetHeadPartFlagByRace);
#undef BIND
			logs::info("Registered Vampirism Handler Functions");
			return true;
		}
	}
}