#pragma once

#include "RaceManager.h"

namespace rcs
{
	namespace papyrus
	{
#define STATIC_ARGS [[maybe_unused]] RE::BSScript::Internal::VirtualMachine *a_vm, [[maybe_unused]] RE::VMStackID a_stackID, RE::StaticFunctionTag *
		[[nodiscard]] static inline const RE::TESRace* GetVampireRaceByRace(STATIC_ARGS, const RE::TESRace* a_race)
		{
			return manager::RaceManager::GetSingleton()->GetVampireRaceByRace(a_race);
		}

		[[nodiscard]] static inline const RE::TESRace* GetRaceByVampireRace(STATIC_ARGS, const RE::TESRace* a_race)
		{
			return manager::RaceManager::GetSingleton()->GetRaceByVampireRace(a_race);
		}

		[[nodiscard]] static inline bool GetIsRaceByProxy(STATIC_ARGS, RE::TESRace* a_source_race, RE::TESRace* a_target_race)
		{
			return manager::RaceManager::GetSingleton()->GetIsRaceByProxy(a_source_race, a_target_race);
		}

		[[nodiscard]] static inline int GetHeadPartTypeByRace(STATIC_ARGS, RE::TESRace* a_race)
		{
			return std::to_underlying(manager::RaceManager::GetSingleton()->GetHeadPartType(a_race));
		}
#undef STATIC_ARGS

		static inline bool Bind(RE::BSScript::Internal::VirtualMachine* a_vm)
		{
			if (!a_vm) {
				logs::error("Can't get VM state");
				return false;
			}

#define BIND(a_method) a_vm->RegisterFunction(#a_method##sv, rcs::PROJECT_NAME_CAMEL, a_method)
			BIND(GetVampireRaceByRace);
			BIND(GetRaceByVampireRace);
			BIND(GetIsRaceByProxy);
			BIND(GetHeadPartTypeByRace);
#undef BIND
			logs::info("Registered papyrus functions");
			return true;
		}
	}
}