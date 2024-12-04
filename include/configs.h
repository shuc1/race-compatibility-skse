#pragma once

namespace rcs
{
	namespace config
	{
		// Format: RCS = RaceForm|VampireRaceForm|RaceProxyForms|VampireRaceProxyForms|HeadPartFlag
		// Restrict: RCS = MUST|MUST|OPTIONAL|OPTIONAL|OPTIONAL
		// RaceProxyForms: "A,B" for A or B race
		// HeadPartFlag: A(Argonian), E(Elf), H(Human), K(Khajiit), O(Orc)
		bool TryReadAndApplyConfigs();
	}
}