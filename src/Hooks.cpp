#include "Hooks.h"
#include "RaceManager.h"

namespace rcs::hook
{
	namespace
	{
#define LOG_TO_CONSOLE(a_name)                                               \
	if (RE::GetStaticTLSData()->consoleMode) {                               \
		RE::ConsoleLog::GetSingleton()->Print(#a_name " >> %0.2lf", result); \
	}

		// thunk for GetIsRace
		struct GetIsRace
		{
			static bool thunk(const RE::TESObjectREFR* obj, const RE::TESForm* race_form, [[maybe_unused]] void* unused, double& result)
			{
				result = 0.0;
				// check if obj is an NPC and has the same race
				if (obj && race_form) {
					const auto npc = obj->data.objectReference->As<RE::TESNPC>();
					const auto race = race_form->As<RE::TESRace>();
					if (npc && race && manager::GetIsRaceByProxy(npc->race, race)) {
						result = 1.0;
					}
				}
				LOG_TO_CONSOLE(GetIsRace)
				return true;
			}
		};

		struct SameRace
		{
			static bool thunk(const RE::TESObjectREFR* obj1, const RE::TESObjectREFR* obj2, [[maybe_unused]] void* unused, double& result)
			{
				result = 0.0;
				if (obj1 && obj2) {
					// check if obj1 and obj2 are NPC
					const auto npc1 = obj1->data.objectReference->As<RE::TESNPC>();
					const auto npc2 = obj2->data.objectReference->As<RE::TESNPC>();
					if (npc1 && npc2 && manager::GetIsRaceByProxy(npc1->race, npc2->race)) {
						result = 1.0;
					}
				}
				LOG_TO_CONSOLE(SameRace)
				return true;
			}
		};

#ifdef SKYRIM_SUPPORT_AE
		// thunk for GetPCIsRace
		struct GetPCIsRace
		{
			static bool thunk([[maybe_unused]] const RE::TESObjectREFR* unused1, const RE::TESForm* race_form, [[maybe_unused]] void* unused2, double& result)
			{
				result = 0.0;
				if (const auto pc = RE::PlayerCharacter::GetSingleton(); pc && race_form) {
					if (const auto race = race_form->As<RE::TESRace>();
						race && manager::GetIsRaceByProxy(pc->race, race)) {
						result = 1.0;
					}
				}
				LOG_TO_CONSOLE(GetIsRace)
				return true;
			}
		};
#endif
#undef LOG_TO_CONSOLE

		// thunk for TESObjectARMA::IsValidRace
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

		template <typename T>
		void InstallHook(const REL::ID id)
		{
			const REL::Relocation target{ id, 0 };
			stl::write_jump_to_thunk<T>(target.address());
		}

	}

	void TryInstall()
	{
		if (!manager::raceProxies.empty()) {
			// VR shared GetIsRace/IsValidRace ids with SE
			InstallHook<GetIsRace>(RELOCATION_ID(21028, 21478));
			InstallHook<SameRace>(RELOCATION_ID(20978, 21428));
			logs::info("Installed hooks for GetIsRace and SameRace");

#ifdef SKYRIM_SUPPORT_AE
			InstallHook<GetPCIsRace>(REL::ID(21484));
			logs::info("Installed hook for GetPCIsRace");
#endif
		}

		if (!manager::armorRaceProxies.empty()) {
			InstallHook<IsValidRace>(RELOCATION_ID(17359, 17757));
			logs::info("Installed hook for TESObjectARMA::IsValidRace");
		}
	}
}  // namespace rcs::hook