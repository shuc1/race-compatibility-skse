#include "hooks.h"
#include "race_manager.h"
//#include <cstdint>

namespace race_compatibility
{
	namespace hook
	{
		class GetIsRace
		{
		public:
			[[nodiscard]] static bool thunk(RE::TESObjectREFR* obj, RE::TESForm* race_form, [[maybe_unused]] void* unused, double& result)
			{
				result = 0.0;
				// check if obj is an NPC and has the same race
				if (obj != nullptr && race_form != nullptr &&
					obj->data.objectReference->formType == RE::FormType::NPC &&
					race_form->formType == RE::FormType::Race) {
					const auto npc = skyrim_cast<RE::TESNPC*>(obj->data.objectReference);
					const auto race = skyrim_cast<RE::TESRace*>(race_form);
					if (npc != nullptr && race != nullptr) [[likely]] {
						if (auto npc_race = npc->race; // npc_race could be nullptr, and won't affect the result
							npc_race == race ||
							manager::compatibility::GetIsRaceByProxies(npc_race, race)) {
							result = 1.0;
						}
					}
				}

				// Typically, the player is loaded when the 'GetIsRace' function is invoked
				// exception: pre-printing in the console.
				if (RE::UI::GetSingleton()->IsMenuOpen(RE::Console::MENU_NAME)) [[unlikely]] {
					if (RE::PlayerCharacter::GetSingleton()->Is3DLoaded()) [[likely]] {
						RE::ConsoleLog::GetSingleton()->Print("[RCS]GetIsRace >> %0.2lf", result);
					}
				}
				return true;
			}
			static inline REL::Relocation<decltype(GetIsRace::thunk)> func;
		};

		void Install()
		{
			const REL::Relocation<std::uintptr_t> target_in_lookup_table{ REL::ID(21034), 0x7 };
			stl::write_thunk_branch<GetIsRace>(target_in_lookup_table.address());
			logs::info("Installed GameFunc__native::GetPCIsRace Hook");

			const REL::Relocation<std::uintptr_t> target_get_is_race{ REL::ID(21691), 0x68 };
			stl::write_thunk_call<GetIsRace>(target_get_is_race.address());
			logs::info("Installed GameFunc__handler::GetIsRace Hook");

			const REL::Relocation<std::uintptr_t> target_get_pc_is_race{ REL::ID(21697), 0x66 };
			stl::write_thunk_call<GetIsRace>(target_get_pc_is_race.address());
			logs::info("Installed GameFunc__handler::GetPCIsRace Hook");
		}
	}  // namespace race_compatibility

	void Install()
	{
		hook::Install();
	}
}  // namespace hook