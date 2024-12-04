#include "Hooks.h"
#include "RaceManager.h"

namespace rcs
{
	// hook for race compatibility
	namespace hook
	{
		struct GetIsRace
		{
			static inline bool thunk(RE::TESObjectREFR* obj, RE::TESForm* race_form, [[maybe_unused]] void* unused, double& result)
			{
				result = 0.0;
				// check if obj is an NPC and has the same race
				// TODO: remove FormType check and try this command on a non-npc thing
				if (obj != nullptr && race_form != nullptr &&
					obj->data.objectReference->formType == RE::FormType::NPC &&
					race_form->formType == RE::FormType::Race) {
					const auto npc = skyrim_cast<RE::TESNPC*>(obj->data.objectReference);
					const auto race = skyrim_cast<RE::TESRace*>(race_form);
					if (npc != nullptr && race != nullptr) [[likely]] {
						if (auto npc_race = npc->race;  // npc_race could be nullptr, and won't affect the result
							npc_race == race ||
							manager::compatibility::GetIsRaceEqual(npc_race, race)) {
							result = 1.0;
						}
					}
				}

				if (RE::GetStaticTLSData()->consoleMode) {
					// RE::ConsoleLog::GetSingleton()->Print("[RCS]GetIsRace >> %0.2lf", result);
					RE::ConsoleLog::GetSingleton()->Print("GetIsRace >> %0.2lf", result);
				}
				return true;
			}
			// static inline REL::Relocation<decltype(GetIsRace::thunk)> func;
		};

#ifdef SKYRIM_SUPPORT_AE
		struct GetPcIsRace
		{
			static inline bool thunk([[maybe_unused]] RE::TESObjectREFR* obj, RE::TESForm* race_form, [[maybe_unused]] void* unused, double& result)
			{
				return GetIsRace::thunk(RE::PlayerCharacter::GetSingleton(), race_form,
					unused, result);
			}
			// static inline REL::Relocation<decltype(GetPcIsRace::thunk)> func;
		};
#endif  // SKYRIM_SUPPORT_AE

		void Install()
		{
			const REL::Relocation<std::uintptr_t> target_get_is_race{ RELOCATION_ID(21028, 21478), 0 };
			stl::write_thunk_branch<GetIsRace>(target_get_is_race.address());

#ifdef SKYRIM_SUPPORT_AE
			const REL::Relocation<std::uintptr_t> target_get_pc_is_race{ RELOCATION_ID(0, 21484), 0 };
			stl::write_thunk_branch<GetPcIsRace>(target_get_pc_is_race.address());
#endif  // SKYRIM_SUPPORT_AE

			logs::info("Installed race judgement hooks");
		}
	}  // namespace hook

	void Install()
	{
		hook::Install();
	}
}  // namespace rcs