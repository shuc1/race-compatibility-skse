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
        return GetRaceProxy(source_race) == target_race;
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

    bool IsGetRaceExcluded(const RE::BSScript::IFunction* function, const RE::TESRace* current) noexcept
    {
        for (const auto& rule : getRaceExclusions) {
            if (!std::ranges::contains(rule.functions, function)) {
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
                       return std::ranges::contains(rule.unlessProxyMatches, GetRaceProxy(race));
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
        if (const auto* proxy = GetRaceProxy(previous);
            proxy && proxy != previous) {
            originRaces.try_emplace(actor_id, previous);
        }
    }

    void LogSummary()
    {
        logs::info("{:*^30}"sv, "SUMMARY"sv);
        logs::info("Race groups recorded: {}"sv, raceGroups.size());
        logs::info("Race proxies created: {}"sv, raceProxies.size());
        logs::info("ArmorRace proxies created: {}"sv, armorRaceProxies.size());
        logs::info("Alternate forms recorded: {}"sv, alternateForms.size());
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
