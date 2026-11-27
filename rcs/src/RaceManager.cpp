#include "RaceManager.h"
#include "RE/T/TESRace.h"

namespace rcs::manager
{
    namespace
    {
        std::vector<std::vector<const RE::TESRace*>> raceGroups{};
        std::vector<const RE::TESRace*>              alternateForms{};
    }

    void EmplaceRaceGroup(std::vector<const RE::TESRace*>&& races)
    {
        if (!races.empty()) {
            raceGroups.emplace_back(std::move(races));
        }
    }

    void EmplaceRaceProxy(const RE::TESRace* race, const RE::TESRace* proxy) noexcept
    {
        if (race && proxy) {
            raceProxies.try_emplace(race, proxy);
        }
    }

    void EmplaceConditionProxies(const RE::TESRace* race, std::vector<const RE::TESRace*>&& proxies) noexcept
    {
        if (race && !proxies.empty()) {
            conditionProxies.try_emplace(race, std::move(proxies));
        }
    }

    void EmplaceArmorRaceProxies(const RE::TESRace* race, std::vector<ArmorOverride>&& proxies) noexcept
    {
        if (race && !proxies.empty()) {
            armorRaceProxies.try_emplace(race, std::move(proxies));
        }
    }

    void AddAlternateForm(const RE::TESRace* race)
    {
        if (!race || IsAlternateForm(race)) {
            return;
        }
        alternateForms.emplace_back(race);
    }

    auto GetIsRaceByProxy(const RE::TESRace* source_race, const RE::TESRace* target_race) noexcept
        -> bool
    {
        if (source_race == target_race) {
            return true;
        }
        if (!source_race || !target_race) {
            return false;
        }
        if (GetRaceProxy(source_race) == target_race) {
            return true;
        }
        const auto it = conditionProxies.find(source_race);
        return it != conditionProxies.end() && std::ranges::contains(it->second, target_race);
    }

    auto ResolveArmorParentRace(const RE::TESObjectARMA* armor_addon, const RE::TESRace* race) noexcept
        -> const RE::TESRace*
    {
        if (const auto it = armorRaceProxies.find(race);
            it != armorRaceProxies.end()) {
            auto& slots = armor_addon->bipedModelData.bipedObjectSlots;
            for (const auto& [proxy, slotMask] : it->second) {
                if (slots.any(slotMask)) {
                    return proxy;
                }
            }
        }
        return race->armorParentRace;
    }

    auto IsAlternateForm(const RE::TESRace* race) noexcept
        -> bool
    {
        return race && std::ranges::contains(alternateForms, race);
    }

    void BindLoadedExclusionFunctions()
    {
        // Bind scripts already loaded before hook installation without loading new ones.
        if (const auto* vm = RE::BSScript::Internal::VirtualMachine::GetSingleton()) {
            for (const auto& script : scriptBindings) {
                RE::BSTSmartPointer<RE::BSScript::ObjectTypeInfo> type{};
                if (vm->GetScriptObjectTypeNoLoad(script.name, type) && type) {
                    RefreshExclusionFunctions(type.get(), script);
                }
            }
        }
    }

    void RefreshExclusionFunctions(const RE::BSScript::ObjectTypeInfo* type, const ScriptBinding& script)
    {
        using ScriptFunction = RE::BSScript::Internal::ScriptFunction;
        static const auto scriptVtable = ScriptFunction::VTABLE[0].address();

        for (const auto& function : script.functions) {
            const auto find = [&](const auto* table, std::uint32_t count) -> const RE::BSScript::IFunction* {
                for (const auto& entry : std::span{ table, count }) {
                    const auto* binding = entry.func.get();
                    if (!binding) {
                        continue;
                    }
                    std::uintptr_t vtable;
                    std::memcpy(&vtable, reinterpret_cast<const std::byte*>(binding), sizeof(vtable));
                    if (vtable != scriptVtable) {
                        continue;
                    }
                    const auto* scriptFunction = static_cast<const ScriptFunction*>(binding);
                    if (scriptFunction->name == function.name) {
                        return binding;
                    }
                }
                // A miss clears the previous version's pointer.
                return nullptr;
            };

            auto resolved = [&]() -> const RE::BSScript::IFunction* {
                if (function.state.empty()) {
                    if (const auto* binding = find(type->GetMemberFuncIter(), type->GetNumMemberFuncs())) {
                        return binding;
                    }
                    return find(type->GetGlobalFuncIter(), type->GetNumGlobalFuncs());
                }
                for (const auto& state : std::span{ type->GetNamedStateIter(), type->GetNumNamedStates() }) {
                    if (state.name == function.state) {
                        return find(state.GetFuncIter(), state.GetNumFuncs());
                    }
                }
                return nullptr;
            }();
            // atomic write
            std::atomic_ref{ function.slot }.store(resolved, std::memory_order_relaxed);
        }
    }

    bool IsGetRaceExcluded(const RE::BSScript::IFunction* function, const RE::TESRace* current) noexcept
    {
        if (!function) {
            return false;
        }
        for (const auto& rule : getRaceExclusions) {
            // atomic read
            if (!std::ranges::any_of(rule.functions,
                    [function](auto& slot) {
                        return std::atomic_ref{ slot }.load(std::memory_order_relaxed) == function;
                    })) {
                continue;
            }
            if (rule.unlessProxyMatches.empty()) {
                return true;
            }

            const auto group = std::ranges::find_if(raceGroups, [&](const auto& group) {
                return std::ranges::contains(group, current);
            });
            return group == raceGroups.end() ||
                   std::ranges::none_of(*group, [&](const auto* race) {
                       const auto* proxy = GetRaceProxy(race);
                       return std::ranges::contains(rule.unlessProxyMatches, proxy ? proxy : race);
                   });
        }
        return false;
    }

    auto GetRaceProxy(const RE::TESRace* race) noexcept
        -> const RE::TESRace*
    {
        const auto it = raceProxies.find(race);
        return it != raceProxies.end() ? it->second : nullptr;
    }

    auto ResolveTargetRace(const RE::TESRace* origin, const RE::TESRace* target) noexcept
        -> const RE::TESRace*
    {
        if (!origin || !target || target == origin) {
            return target;
        }
        // actually proxied race
        if (target == GetRaceProxy(origin)) {
            return origin;
        }
        for (const auto& group : raceGroups) {
            if (!std::ranges::contains(group, origin)) {
                continue;
            }
            for (const auto* member : group) {
                if (member != origin && target == GetRaceProxy(member)) {
                    return member;
                }
            }
            // Each race belongs to at most one group.
            return target;
        }
        return target;
    }

    auto GetOriginRace(const RE::FormID actor_id) noexcept
        -> const RE::TESRace*
    {
        const auto it = originRaces.find(actor_id);
        return it != originRaces.end() ? it->second : nullptr;
    }

    void UpdateOriginRace(RE::FormID actor_id, const RE::TESRace* previous, const RE::TESRace* current, bool had_origin)
    {
        if (!IsAlternateForm(current)) {
            if (had_origin) {
                originRaces.erase(actor_id);
            }
            return;
        }
        if (had_origin || IsAlternateForm(previous)) {
            return;
        }
        // only proxied race needs this
        if (GetRaceProxy(previous)) {
            originRaces.try_emplace(actor_id, previous);
        }
    }

    void LogSummary()
    {
        logs::info("{:*^30}"sv, "SUMMARY"sv);
        logs::info("Race groups recorded: {}"sv, raceGroups.size());
        logs::info("Race proxies created: {}"sv, raceProxies.size());
        logs::info("Race extra condition proxies created: {}"sv, conditionProxies.size());
        logs::info("ArmorRace proxies created: {}"sv, armorRaceProxies.size());
        logs::info("Alternate forms recorded: {}"sv, alternateForms.size());
        logs::info("GetRace related scripts recorded: {}"sv, scriptBindings.size());
    }

    namespace headpart
    {
        namespace
        {
            template <typename... Args>
            void AddRaceTo(RE::TESRace* race, Args... args)
            {
                if (race) {
                    ((args->HasForm(race) ? void() : args->AddForm(race)), ...);
                }
            }
        }

        HeadPartFormIdListAdder::HeadPartFormIdListAdder()
        {
#define X(LIST) LIST = RE::TESForm::LookupByEditorID<RE::BGSListForm>("HeadParts" #LIST##sv);
            HEAD_PART_LISTS
#undef X
        }

        auto HeadPartFormIdListAdder::IsInitialized() const -> bool
        {
#define X(LIST) LIST&&
            return HEAD_PART_LISTS true;
#undef X
        }

        void HeadPartFormIdListAdder::AddRace(RE::TESRace* race, std::string_view type) const
        {
#define X(TYPE)                      \
    if (type == #TYPE##sv) {         \
        Add##TYPE(race);             \
        return;                      \
    }                                \
    if (type == #TYPE "Vampire"sv) { \
        Add##TYPE##Vampire(race);    \
        return;                      \
    }
            HEAD_PART_TYPES
#undef X
        }

// race lists
// non-beast
#define NON_BEAST_RACES AllRacesMinusBeastVampires, AllRacesMinusBeast
#define NON_BEAST_VAMPIRE_RACES AllRacesMinusBeast

// elf
#define ELF_RACES NON_BEAST_RACES, Elves, ElvesandVampires
#define ELF_VAMPIRE_RACES NON_BEAST_VAMPIRE_RACES, HumanoidVampire, ElvesandVampires

// human
#define HUMAN_RACES NON_BEAST_RACES, Human, HumansandVampires, HumansOrcsandVampires
#define HUMAN_VAMPIRE_RACES NON_BEAST_VAMPIRE_RACES, HumanVampires, HumanoidVampire, HumansandVampires, HumansOrcsandVampires

#define ADD_HEAD_PART_FUNCTION(TYPE, RACE, ...)                      \
    void HeadPartFormIdListAdder::Add##TYPE(RE::TESRace* RACE) const \
    {                                                                \
        AddRaceTo(RACE, __VA_ARGS__);                                \
    }

        ADD_HEAD_PART_FUNCTION(Argonian, race, Argonian, ArgonianandVampire)
        ADD_HEAD_PART_FUNCTION(ArgonianVampire, vampire_race, ArgonianVampire, ArgonianandVampire)
        ADD_HEAD_PART_FUNCTION(Elf, race, ELF_RACES)
        ADD_HEAD_PART_FUNCTION(ElfVampire, vampire_race, ELF_VAMPIRE_RACES)

#define ADD_ELF_FUNCTION(ELF)                                          \
    ADD_HEAD_PART_FUNCTION(ELF, race, ELF_RACES, ELF, ELF##andVampire) \
    ADD_HEAD_PART_FUNCTION(ELF##Vampire, vampire_race, ELF_VAMPIRE_RACES, ELF##andVampire)
        ADD_ELF_FUNCTION(DarkElf)
        ADD_ELF_FUNCTION(HighElf)
        ADD_ELF_FUNCTION(WoodElf)
#undef ADD_ELF_FUNCTION

        ADD_HEAD_PART_FUNCTION(Human, race, HUMAN_RACES)
        ADD_HEAD_PART_FUNCTION(HumanVampire, vampire_race, HUMAN_VAMPIRE_RACES)

#define ADD_HUMAN_FUNCTION(HUMAN)                                              \
    ADD_HEAD_PART_FUNCTION(HUMAN, race, HUMAN_RACES, HUMAN, HUMAN##andVampire) \
    ADD_HEAD_PART_FUNCTION(HUMAN##Vampire, vampire_race, HUMAN_VAMPIRE_RACES, HUMAN##andVampire)
        ADD_HUMAN_FUNCTION(Breton)
        ADD_HUMAN_FUNCTION(Imperial)
        ADD_HUMAN_FUNCTION(Nord)
        ADD_HUMAN_FUNCTION(Redguard)
#undef ADD_HUMAN_FUNCTION

        ADD_HEAD_PART_FUNCTION(Khajiit, race, Khajiit, KhajiitandVampire)
        ADD_HEAD_PART_FUNCTION(KhajiitVampire, vampire_race, KhajiitVampire, KhajiitandVampire)
        ADD_HEAD_PART_FUNCTION(Orc, race, NON_BEAST_RACES, Orc, OrcandVampire, HumansOrcsandVampires)
        ADD_HEAD_PART_FUNCTION(OrcVampire, vampire_race, NON_BEAST_VAMPIRE_RACES, HumanoidVampire, OrcandVampire, HumansOrcsandVampires)
#undef ADD_HEAD_PART_FUNCTION
    }  // namespace headpart
}  // namespace rcs::manager
