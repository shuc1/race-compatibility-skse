#include "RaceManager.h"
#include "RE/T/TESRace.h"

namespace rcs::manager
{
    namespace
    {
        std::vector<std::pair<const RE::TESRace*, const RE::TESRace*>> vampirismPairs{};
        std::unordered_map<const RE::TESRace*, std::bitset<13>>        headPartMap{};
        std::vector<const RE::TESRace*>                                alternateForms{};

        auto GetPairedRace(const RE::TESRace* race) noexcept
            -> const RE::TESRace*
        {
            for (const auto& [mortal, vampire] : vampirismPairs) {
                if (race == mortal) {
                    return vampire;
                }
                if (race == vampire) {
                    return mortal;
                }
            }
            return nullptr;
        }
    }

    void EmplaceVampirismRacePair(const RE::TESRace* race, const RE::TESRace* vampire_race) noexcept
    {
        if (race && vampire_race) {
            vampirismPairs.emplace_back(std::make_pair(race, vampire_race));
        }
    }

    void EmplaceRaceProxy(const RE::TESRace* race, const RE::TESRace* proxy) noexcept
    {
        if (race && proxy) {
            raceProxies.try_emplace(race, proxy);
        }
    }

    void EmplaceArmorRaceProxies(const RE::TESRace* race, std::vector<ArmorProxyEntry>&& proxies) noexcept
    {
        if (race && !proxies.empty()) {
            armorRaceProxies.try_emplace(race, std::move(proxies));
        }
    }

    void AddHeadPartType(const RE::TESRace* race, HeadPartType type) noexcept
    {
        if (race) {
            headPartMap[race].set(std::to_underlying(type));
        }
    }

    bool AddAlternateForm(const RE::TESRace* race)
    {
        if (!race || IsAlternateForm(race)) {
            return false;
        }
        alternateForms.push_back(race);
        return true;
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

    auto HasHeadPartType(const RE::TESRace* race, HeadPartType type) noexcept
        -> bool
    {
        const auto it = headPartMap.find(race);
        if (it == headPartMap.end()) {
            return false;
        }
        return it->second.test(std::to_underlying(type));
    }

    auto IsAlternateForm(const RE::TESRace* race) noexcept
        -> bool
    {
        return race && std::ranges::contains(alternateForms, race);
    }

    auto GetRaceProxy(const RE::TESRace* race) noexcept
        -> const RE::TESRace*
    {
        const auto it = raceProxies.find(race);
        return it != raceProxies.end() ? it->second : nullptr;
    }

    auto GetProxyOrRace(const RE::TESRace* race) noexcept
        -> const RE::TESRace*
    {
        const auto* proxy = GetRaceProxy(race);
        return proxy ? proxy : race;
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
        if (const auto* paired = GetPairedRace(origin);
            paired && target == GetRaceProxy(paired)) {
            return paired;
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
        logs::info("Vanilla vampirism race pairs recorded: 10"sv);
        logs::info("Custom vampirism race pairs added: {}"sv, vampirismPairs.size() - 10);
        logs::info("Custom races with head part types: {}"sv, headPartMap.size() - 20);
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

        auto StringToHeadPartType(const std::string_view head_part_str)
            -> HeadPartType
        {
            // for small number of comparisons(12), this is faster than loop, similar to hash-switch
            // refer to: https://godbolt.org/z/MT96Msnqr
#define X(TYPE)                     \
    if (head_part_str == #TYPE##sv) \
        return k##TYPE;
            HEAD_PART_TYPES
#undef X
            return kNone;
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

        void HeadPartFormIdListAdder::AddRacePair(ADD_RACE_ARGS, HeadPartType type) const
        {
            switch (type) {
            case kNone:
                return;
#define X(TYPE)                        \
    case k##TYPE:                      \
        Add##TYPE(race, vampire_race); \
        break;
                HEAD_PART_TYPES
#undef X
            }
            AddHeadPartType(race, type);
            AddHeadPartType(vampire_race, type);
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

        void HeadPartFormIdListAdder::AddArgonian(ADD_RACE_ARGS) const
        {
            AddRaceTo(race, Argonian, ArgonianandVampire);
            AddRaceTo(vampire_race, ArgonianVampire, ArgonianandVampire);
        }

        void HeadPartFormIdListAdder::AddElf(ADD_RACE_ARGS) const
        {
            AddRaceTo(race, ELF_RACES);
            AddRaceTo(vampire_race, ELF_VAMPIRE_RACES);
        }

#define ADD_ELF_FUNCTION(ELF)                                        \
    void HeadPartFormIdListAdder::Add##ELF(ADD_RACE_ARGS) const      \
    {                                                                \
        AddRaceTo(race, ELF_RACES, ELF, ELF##andVampire);            \
        AddRaceTo(vampire_race, ELF_VAMPIRE_RACES, ELF##andVampire); \
    }
        ADD_ELF_FUNCTION(DarkElf)
        ADD_ELF_FUNCTION(HighElf)
        ADD_ELF_FUNCTION(WoodElf)
#undef ADD_ELF_FUNCTION

        void HeadPartFormIdListAdder::AddHuman(ADD_RACE_ARGS) const
        {
            AddRaceTo(race, HUMAN_RACES);
            AddRaceTo(vampire_race, HUMAN_VAMPIRE_RACES);
        }

#define ADD_HUMAN_FUNCTION(HUMAN)                                        \
    void HeadPartFormIdListAdder::Add##HUMAN(ADD_RACE_ARGS) const        \
    {                                                                    \
        AddRaceTo(race, HUMAN_RACES, HUMAN, HUMAN##andVampire);          \
        AddRaceTo(vampire_race, HUMAN_VAMPIRE_RACES, HUMAN##andVampire); \
    }
        ADD_HUMAN_FUNCTION(Breton)
        ADD_HUMAN_FUNCTION(Imperial)
        ADD_HUMAN_FUNCTION(Nord)
        ADD_HUMAN_FUNCTION(Redguard)
#undef ADD_HUMAN_FUNCTION

        void HeadPartFormIdListAdder::AddKhajiit(ADD_RACE_ARGS) const
        {
            AddRaceTo(race, Khajiit, KhajiitandVampire);
            AddRaceTo(vampire_race, KhajiitVampire, KhajiitandVampire);
        }

        void HeadPartFormIdListAdder::AddOrc(ADD_RACE_ARGS) const
        {
            AddRaceTo(race, NON_BEAST_RACES, Orc, OrcandVampire, HumansOrcsandVampires);
            AddRaceTo(vampire_race, NON_BEAST_VAMPIRE_RACES, HumanoidVampire, OrcandVampire, HumansOrcsandVampires);
        }
    }  // namespace headpart
}  // namespace rcs::manager
