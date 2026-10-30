#pragma once

#include "RaceManager.h"

namespace rcs
{
    namespace papyrus
    {
        namespace
        {
            template <class T>
            [[nodiscard]] static auto GetRace(RE::BSScript::Internal::VirtualMachine* a_vm, RE::VMStackID a_stackID, const T* a_object)
                -> const RE::TESRace*
            {
                if (!a_object) {
                    return nullptr;
                }

                const auto* race = a_object->race;
                const auto* proxy = manager::GetRaceProxy(race);
                if (!proxy) {
                    return race;
                }

                if (manager::raceProxyExclusions.empty()) {
                    return proxy;
                }
                RE::BSScript::Stack* stack{};
                if (a_vm && a_vm->GetStackByID(a_stackID, &stack) && stack && stack->top) {
                    const auto* frame = stack->top->previousFrame;
                    if (frame && std::ranges::contains(manager::raceProxyExclusions, frame->owningFunction.get())) {
                        // excluded
                        return race;
                    }
                }
                return proxy;
            }
        }

        static inline bool Bind(RE::BSScript::Internal::VirtualMachine* a_vm)
        {
            if (!a_vm) {
                logs::error("Can't get VM state"sv);
                return false;
            }
            logs::info("{:*^30}"sv, "PAPYRUS"sv);
            a_vm->RegisterFunction("GetRace"sv, "Actor"sv, GetRace<RE::Actor>);
            a_vm->RegisterFunction("GetRace"sv, "ActorBase"sv, GetRace<RE::TESNPC>);
            logs::info("Registered papyrus functions Actor.GetRace and ActorBase.GetRace"sv);
            return true;
        }
    }
}
