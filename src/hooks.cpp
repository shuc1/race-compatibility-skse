#include "hooks.h"
#include <cstdint>
#include "RE/C/Console.h"
#include "RE/C/ConsoleLog.h"
#include "RE/RTTI.h"
#include "RE/T/TESForm.h"
#include "RE/T/TESObjectREFR.h"
#include "REL/Relocation.h"

namespace Hooks {
namespace RaceComp {

struct GetIsRace {
  static bool thunk(RE::TESObjectREFR* obj, RE::TESForm* race_form) {
    auto result = false;
    // check if obj is an NPC and has the same race
    if (obj != nullptr && race_form != nullptr &&
        obj->data.objectReference->formType == RE::FormType::NPC &&
        race_form->formType == RE::FormType::Race) {
      const auto npc = skyrim_cast<RE::TESNPC*>(obj->data.objectReference);
      const auto race = skyrim_cast<RE::TESRace*>(race_form);
      if (npc != nullptr && race != nullptr) [[likely]]{
        if (npc->race == race) {
          result = true;
        }
      }
    }

    const auto ui = RE::UI::GetSingleton();
    const auto player = RE::PlayerCharacter::GetSingleton();
    // Typically, the player is loaded when the 'GetIsRace' function is invoked,
    // with the exception of pre-printing in the console.
    if (ui->IsMenuOpen(RE::Console::MENU_NAME)) [[unlikely]] {
      if (player->Is3DLoaded()) [[likely]] {
        RE::ConsoleLog::GetSingleton()->Print("My GetIsRace >> %u.00", result);
      }
    }
    return result;
  }
  static inline REL::Relocation<decltype(GetIsRace::thunk)> func;
};

void Install() {
  logs::info("{:*^30}", "HOOKS");

  // Incompatible with hooks at the same position, for ignoring the return value of write_call
  const REL::Relocation<std::uintptr_t> target1{REL::ID(21691), 0x68};
  stl::write_thunk_call<GetIsRace>(target1.address());
  logs::info("Installed GetIsRace Hook");
  const REL::Relocation<std::uintptr_t> target2(REL::ID(21697), 0x66);
  stl::write_thunk_call<GetIsRace>(target2.address());
  logs::info("Installed GetPCIsRace Hook");
}
}  // namespace RaceComp

void Install() {
  RaceComp::Install();
}
}  // namespace Hooks