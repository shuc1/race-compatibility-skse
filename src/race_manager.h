#pragma once

#include "CLIBUtil/singleton.hpp"

namespace race_compatibility
{
	namespace manager
	{
		namespace ini
		{
			// Format: RCS = RaceEditorID|VampireRaceEditorID|RaceProxyEditorIDs|VampireRaceProxyEditorIDs|HeadPartFlag
			// Restrict: RCS = MUST|MUST|OPTIONAL|OPTIONAL|OPTIONAL
			// RaceProxyEditorIDs: "A,B" for A or B race
			// HeadPartFlag: B(Beasts), E(Elf), H(Human), O(Orc)
			void TryParse(rcs::ini::configs_t& raw_configs);
		}

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
		}
	}
}