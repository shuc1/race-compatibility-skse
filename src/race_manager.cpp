#include "race_manager.h"

namespace race_compatibility
{
	namespace manager
	{
		namespace headpart
		{

			void HeadPartFormIdLists::Initialize()
			{
				is_initialized = false;

				argonian = lookup::form::LookupFormIdLists("HeadPartsArgonian");
				elves = lookup::form::LookupFormIdLists("HeadPartsElves");
				human = lookup::form::LookupFormIdLists("HeadPartsHuman");
				khajiit = lookup::form::LookupFormIdLists("HeadPartsKhajiit");
				orc = lookup::form::LookupFormIdLists("HeadPartsOrc");
				all_races_minus_beast_vampires = lookup::form::LookupFormIdLists("HeadPartsAllRacesMinusBeastVampires");

				argonian_vampire = lookup::form::LookupFormIdLists("HeadPartsArgonianVampire");
				humanoid_vampire = lookup::form::LookupFormIdLists("HeadPartsHumanoidVampire");
				human_vampires = lookup::form::LookupFormIdLists("HeadPartsHumanVampires");
				khajiit_vampire = lookup::form::LookupFormIdLists("HeadPartsKhajiitVampire");

				argonian_and_vampire = lookup::form::LookupFormIdLists("HeadPartsArgonianandVampire");
				elves_and_vampires = lookup::form::LookupFormIdLists("HeadPartsElvesandVampires");
				humans_and_vampires = lookup::form::LookupFormIdLists("HeadPartsHumansandVampires");
				khajiit_and_vampire = lookup::form::LookupFormIdLists("HeadPartsKhajiitandVampire");
				orc_and_vampire = lookup::form::LookupFormIdLists("HeadPartsOrcandVampire");
				all_races_minus_beast = lookup::form::LookupFormIdLists("HeadPartsAllRacesMinusBeast");
				humans_orcs_and_vampires = lookup::form::LookupFormIdLists("HeadPartsHumansOrcsandVampires");

				is_initialized = argonian != nullptr && elves != nullptr && human != nullptr && khajiit != nullptr &&
				                 orc != nullptr && all_races_minus_beast_vampires != nullptr && argonian_vampire != nullptr && humanoid_vampire != nullptr &&
				                 human_vampires != nullptr && khajiit_vampire != nullptr && argonian_and_vampire != nullptr && elves_and_vampires != nullptr &&
				                 humans_and_vampires != nullptr && khajiit_and_vampire != nullptr && orc_and_vampire != nullptr && all_races_minus_beast != nullptr &&
				                 humans_orcs_and_vampires != nullptr;
			}

			void HeadPartFormIdLists::AddRace(RE::TESRace* race, RE::TESRace* vampire_race, HeadPartFlag flag)
			{
				switch (flag) {
				default:
				case HeadPartFlag::kNone:
					return;
				case HeadPartFlag::kArgonian:
					AddArgonian(race, vampire_race);
					break;
				case HeadPartFlag::kElf:
					AddElf(race, vampire_race);
					break;
				case HeadPartFlag::kHuman:
					AddHuman(race, vampire_race);
					break;
				case HeadPartFlag::kKhajiit:
					AddKhajiit(race, vampire_race);
					break;
				case HeadPartFlag::kOrc:
					AddOrc(race, vampire_race);
					break;
				}
				count++;
			}

#define TRY_ADD_RACE(a_form_id_list, a_race)  \
	if (!(a_form_id_list->HasForm(a_race))) { \
		a_form_id_list->AddForm(a_race);      \
	}
			void HeadPartFormIdLists::AddArgonian(RE::TESRace* race, RE::TESRace* vampire_race)
			{
				// normal
				TRY_ADD_RACE(argonian, race)
				// vampire
				TRY_ADD_RACE(argonian_vampire, vampire_race)
				// both
				TRY_ADD_RACE(argonian_and_vampire, race)
				TRY_ADD_RACE(argonian_and_vampire, vampire_race)
			}

			void HeadPartFormIdLists::AddElf(RE::TESRace* race, RE::TESRace* vampire_race)
			{
				AddNonBeast(race, vampire_race);
				// normal
				TRY_ADD_RACE(elves, race)
				// vampire
				TRY_ADD_RACE(humanoid_vampire, vampire_race)
				// both
				TRY_ADD_RACE(elves_and_vampires, race)
				TRY_ADD_RACE(elves_and_vampires, vampire_race)
			}

			void HeadPartFormIdLists::AddHuman(RE::TESRace* race, RE::TESRace* vampire_race)
			{
				AddNonBeast(race, vampire_race);
				// normal
				TRY_ADD_RACE(human, race)
				// vampire
				TRY_ADD_RACE(human_vampires, vampire_race)
				TRY_ADD_RACE(humanoid_vampire, vampire_race)
				// both
				TRY_ADD_RACE(humans_and_vampires, race)
				TRY_ADD_RACE(humans_and_vampires, vampire_race)
				TRY_ADD_RACE(humans_orcs_and_vampires, race)
				TRY_ADD_RACE(humans_orcs_and_vampires, vampire_race)
			}

			void HeadPartFormIdLists::AddKhajiit(RE::TESRace* race, RE::TESRace* vampire_race)
			{
				// normal
				TRY_ADD_RACE(khajiit, race)
				// vampire
				TRY_ADD_RACE(khajiit_vampire, vampire_race)
				// both
				TRY_ADD_RACE(khajiit_and_vampire, race)
				TRY_ADD_RACE(khajiit_and_vampire, vampire_race)
			}

			void HeadPartFormIdLists::AddOrc(RE::TESRace* race, RE::TESRace* vampire_race)
			{
				AddNonBeast(race, vampire_race);
				// normal
				TRY_ADD_RACE(orc, race)
				// vampire
				TRY_ADD_RACE(humanoid_vampire, vampire_race)
				// both
				TRY_ADD_RACE(orc_and_vampire, race)
				TRY_ADD_RACE(orc_and_vampire, vampire_race)
				TRY_ADD_RACE(humans_orcs_and_vampires, race)
				TRY_ADD_RACE(humans_orcs_and_vampires, vampire_race)
			}

			void HeadPartFormIdLists::AddNonBeast(RE::TESRace* race, RE::TESRace* vampire_race)
			{
				TRY_ADD_RACE(all_races_minus_beast, race)
				TRY_ADD_RACE(all_races_minus_beast, vampire_race)

				TRY_ADD_RACE(all_races_minus_beast_vampires, race)
			}
#undef TRY_ADD_RACE
		}  // namespace headpart
	}  // namespace manager
}  // namespace race_compatibility