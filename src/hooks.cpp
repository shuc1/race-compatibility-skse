#include "hooks.h"
#include <cstdint>
#include "RE/C/Console.h"
#include "RE/C/ConsoleLog.h"
#include "RE/T/TESForm.h"
#include "RE/T/TESObjectREFR.h"
#include "REL/Relocation.h"

namespace Hooks {
namespace RaceComp {

static inline bool _GetIsRace(RE::TESObjectREFR* obj, RE::TESForm* race_form) {
  auto result = false;
  // check if obj is an NPC and has the same race
  if (obj != nullptr && race_form != nullptr &&
      obj->data.objectReference->formType == RE::FormType::NPC &&
      race_form->formType == RE::FormType::Race) {
    const auto npc = dynamic_cast<RE::TESNPC*>(obj->data.objectReference);
    const auto race = dynamic_cast<RE::TESRace*>(race_form);
    if (npc != nullptr && race != nullptr && npc->race == race) {
      result = true;
    }
  }

  // print to console
  const auto ui = RE::UI::GetSingleton();
  const auto player = RE::PlayerCharacter::GetSingleton();
  if (ui->IsMenuOpen(RE::Console::MENU_NAME) && player->Is3DLoaded()) {
    RE::ConsoleLog::GetSingleton()->Print("My GetIsRace >> %0.2f",
                                          static_cast<float>(result));
  }
  return result;
}

struct GetIsRace {
  static bool thunk(RE::TESObjectREFR* obj, RE::TESForm* race_form) {
    return _GetIsRace(obj, race_form);
  }
  static inline REL::Relocation<decltype(GetIsRace::thunk)> func;
};
struct GetPcIsRace {
  static bool thunk(RE::TESObjectREFR* obj, RE::TESForm* race_form) {
    return _GetIsRace(obj, race_form);
    // check if obj is an NPC and has the same
  }
  static inline REL::Relocation<decltype(GetPcIsRace::thunk)> func;
};

void Install() {
  logs::info("{:*^30}", "HOOKS");

  const REL::Relocation<std::uintptr_t> target1{REL::ID(21691), 0x68};
  stl::write_thunk_call<GetIsRace>(target1.address());
  logs::info("Installed GetIsRace Hook");

  const REL::Relocation<std::uintptr_t> target2(REL::ID(21697), 0x66);
  stl::write_thunk_call<GetPcIsRace>(target2.address());
  logs::info("Installed GetPCIsRace Hook");
}
}  // namespace RaceComp

void Install() {
  RaceComp::Install();
}
}  // namespace Hooks