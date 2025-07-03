#include "Hooks.h"
#include "RaceManager.h"

namespace rcs::hook
{
	// hook for GetIsRace
	struct GetIsRace
	{
		static bool thunk(const RE::TESObjectREFR* obj, RE::TESForm* race_form, [[maybe_unused]] void* unused, double& result)
		{
			result = 0.0;
			// check if obj is an NPC and has the same race
			if (obj && race_form) {
				const auto npc = obj->data.objectReference->As<RE::TESNPC>();
				const auto race = race_form->As<RE::TESRace>();
				if (npc && race) {
					if (const auto npc_race = npc->race;
						npc_race &&
						manager::GetIsRaceByProxy(npc_race, race)) {
						result = 1.0;
					}
				}
			}

			if (RE::GetStaticTLSData()->consoleMode) {
				RE::ConsoleLog::GetSingleton()->Print("GetIsRace >> %0.2lf", result);
			}
			return true;
		}
	};

	// hook for TESObjectARMA::IsValidRace
	struct IsValidRace
	{
		static bool thunk(const RE::TESObjectARMA* armor_addon, const RE::TESRace* race)
		{
			//auto* source_race = !race || !race->armorParentRace ? race : race->armorParentRace;
			if (!race) {
				return false;
			}
			// race not null
			auto* armor_parent_race = manager::GetProxyArmorParentRace(armor_addon, race);
			if (const auto* armor_race = armor_addon->race;
				race == armor_race || armor_parent_race == armor_race) {
				return true;
			}
			return std::ranges::any_of(armor_addon->additionalRaces,
				[&](const auto& target_race) { return race == target_race || armor_parent_race == target_race; });
		}
	};

#ifdef SKYRIM_SUPPORT_AE
	// hook for GetPcsRace
	struct GetPcIsRace
	{
		static bool thunk([[maybe_unused]] RE::TESObjectREFR* obj, RE::TESForm* race_form, [[maybe_unused]] void* unused, double& result)
		{
			return GetIsRace::thunk(RE::PlayerCharacter::GetSingleton(), race_form, unused, result);
		}
	};
#endif  // SKYRIM_SUPPORT_AE

	/////////////////////
	// Install the hooks
	void TryInstall()
	{
		// VR shared GetIsRace/IsValidRace ids with SE
		if (!manager::raceProxies.empty()) {
			const REL::Relocation get_is_race{ RELOCATION_ID(21028, 21478), 0 };
			stl::write_thunk_branch<GetIsRace>(get_is_race.address());

#ifdef SKYRIM_SUPPORT_AE
			const REL::Relocation get_pc_is_race{ RELOCATION_ID(0, 21484), 0 };
			stl::write_thunk_branch<GetPcIsRace>(get_pc_is_race.address());
#endif  // SKYRIM_SUPPORT_AE

			logs::info("Installed hooks for GetIsRace");
		}
		if (!manager::armorRaceProxies.empty()) {
			const REL::Relocation is_valid_race{ RELOCATION_ID(17359, 17757), 0 };
			stl::write_thunk_branch<IsValidRace>(is_valid_race.address());
			logs::info("Installed hooks for TESObjectARMA::IsValidRace");
		}
	}
}  // namespace rcs::hook