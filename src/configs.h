#pragma once

namespace race_compatibility
{
	namespace ini
	{
		// Format: RCS = RaceEditorID|VampireRaceEditorID|RaceProxyEditorIDs|VampireRaceProxyEditorIDs|HeadPartFlag
		// Restrict: RCS = MUST|MUST|OPTIONAL|OPTIONAL|OPTIONAL
		// RaceProxyEditorIDs: "A,B" for A or B race
		// HeadPartFlag: B(Beasts), E(Elf), H(Human), O(Orc)
		bool TryReadAndApplyConfigs();
	}
}