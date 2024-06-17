#pragma once

#include "CLIBUtil/singleton.hpp"

namespace race_compatibility
{
	namespace manager
	{
		namespace vampirism
		{
			// export functions to game scripting
			// there wouldn't be frequent calls to get original race of vampire race or vice versa
			inline std::vector<std::pair<RE::TESRace*, RE::TESRace*>> vampirism_pairs{};
			// TODO: 1 get race by vampire race
			// TODO: 2 get vampire race by race

		}

		namespace compatibility
		{
			inline std::map<RE::TESRace*, std::set<RE::TESRace*>> race_map{};

			static inline bool GetIsRaceByProxies(RE::TESRace* npc_race, RE::TESRace* race)
			{
				return race_map.contains(npc_race) && race_map.at(npc_race).contains(race);
			}
		}
	}
}