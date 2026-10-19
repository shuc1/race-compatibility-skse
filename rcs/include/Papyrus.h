#pragma once

#include "RaceManager.h"

namespace rcs
{
    namespace papyrus
    {
#define STATIC_ARGS [[maybe_unused]] RE::BSScript::Internal::VirtualMachine *a_vm, [[maybe_unused]] RE::VMStackID a_stackID, RE::StaticFunctionTag *
        [[nodiscard]] static auto GetActualRace(STATIC_ARGS, const RE::Actor* a_actor)
            -> const RE::TESRace*
        {
            return a_actor ? a_actor->GetRace() : nullptr;
        }

        [[nodiscard]] static auto GetOriginRace(STATIC_ARGS, const RE::Actor* a_actor)
            -> const RE::TESRace*
        {
            return a_actor ? manager::GetOriginRace(a_actor->GetFormID()) : nullptr;
        }

        [[nodiscard]] static auto GetIsHeadPartTypeByRace(STATIC_ARGS, const RE::TESRace* a_race, int a_type_id)
            -> bool
        {
            if (!a_race || a_type_id < 0 || a_type_id > 12) {
                return false;
            }
            return manager::HasHeadPartType(a_race, static_cast<manager::HeadPartType>(a_type_id));
        }
#undef STATIC_ARGS

        [[nodiscard]] static auto GetRace(const RE::Actor* a_actor)
            -> const RE::TESRace*
        {
            return manager::GetProxyOrRace(a_actor ? a_actor->race : nullptr);
        }

        [[nodiscard]] static auto GetActorBaseRace(const RE::TESNPC* a_actor_base)
            -> const RE::TESRace*
        {
            return manager::GetProxyOrRace(a_actor_base ? a_actor_base->race : nullptr);
        }

        static inline bool Bind(RE::BSScript::Internal::VirtualMachine* a_vm)
        {
            if (!a_vm) {
                logs::error("Can't get VM state"sv);
                return false;
            }

#define BIND(METHOD) a_vm->RegisterFunction(#METHOD##sv, rcs::PAPYRUS_NAME, METHOD)
            BIND(GetActualRace);
            BIND(GetOriginRace);
            BIND(GetIsHeadPartTypeByRace);
#undef BIND
            a_vm->RegisterFunction("GetRace"sv, "Actor"sv, GetRace);
            a_vm->RegisterFunction("GetRace"sv, "ActorBase"sv, GetActorBaseRace);
            logs::info("Registered papyrus functions"sv);
            return true;
        }
    }
}
