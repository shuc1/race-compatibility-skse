#pragma once

#define VANILLA_RACES \
    X(Argonian)       \
    X(DarkElf)        \
    X(HighElf)        \
    X(WoodElf)        \
    X(Breton)         \
    X(Imperial)       \
    X(Nord)           \
    X(Redguard)       \
    X(Khajiit)        \
    X(Orc)

#define HEAD_PART_TYPES \
    VANILLA_RACES       \
    X(Elf)              \
    X(Human)

#define HEAD_PART_LISTS           \
    /* normal races */            \
    X(Argonian)                   \
    X(Elves)                      \
    X(DarkElf)                    \
    X(HighElf)                    \
    X(WoodElf)                    \
    X(Human)                      \
    X(Breton)                     \
    X(Imperial)                   \
    X(Nord)                       \
    X(Redguard)                   \
    X(Khajiit)                    \
    X(Orc)                        \
    X(AllRacesMinusBeastVampires) \
    /* vampire races */           \
    X(ArgonianVampire)            \
    X(HumanoidVampire)            \
    X(HumanVampires)              \
    X(KhajiitVampire)             \
    /* both normal & vampire */   \
    X(ArgonianandVampire)         \
    X(ElvesandVampires)           \
    X(DarkElfandVampire)          \
    X(HighElfandVampire)          \
    X(WoodElfandVampire)          \
    X(HumansandVampires)          \
    X(BretonandVampire)           \
    X(ImperialandVampire)         \
    X(NordandVampire)             \
    X(RedguardandVampire)         \
    X(KhajiitandVampire)          \
    X(OrcandVampire)              \
    X(AllRacesMinusBeast)         \
    X(HumansOrcsandVampires)

namespace rcs::manager
{
    enum HeadPartType : std::uint8_t
    {
        kNone = 0,
#define X(TYPE) k##TYPE,
        HEAD_PART_TYPES
#undef X
    };

    struct ArmorProxyEntry
    {
        const RE::TESRace*                      proxy;
        RE::BGSBipedObjectForm::BipedObjectSlot slotMask;
    };

    inline std::unordered_map<const RE::TESRace*, const RE::TESRace*>           raceProxies{};
    inline std::unordered_map<const RE::TESRace*, std::vector<ArmorProxyEntry>> armorRaceProxies{};
    inline std::unordered_map<RE::FormID, const RE::TESRace*>                   originRaces{};

    // emplace
    void               EmplaceVampirismRacePair(const RE::TESRace* race, const RE::TESRace* vampire_race) noexcept;
    void               EmplaceRaceProxy(const RE::TESRace* race, const RE::TESRace* proxy) noexcept;
    void               EmplaceArmorRaceProxies(const RE::TESRace* race, std::vector<ArmorProxyEntry>&& proxies) noexcept;
    void               AddHeadPartType(const RE::TESRace* race, HeadPartType type) noexcept;
    [[nodiscard]] bool AddAlternateForm(const RE::TESRace* race);
    // judge
    [[nodiscard]] auto GetVampireRaceByRace(const RE::TESRace* race) noexcept -> const RE::TESRace*;
    [[nodiscard]] auto GetRaceByVampireRace(const RE::TESRace* vampire_race) noexcept -> const RE::TESRace*;
    [[nodiscard]] auto GetIsRaceByProxy(const RE::TESRace* source_race, const RE::TESRace* target_race) noexcept -> bool;
    [[nodiscard]] auto ResolveArmorParentRace(const RE::TESObjectARMA* armor_addon, const RE::TESRace* race) noexcept -> const RE::TESRace*;
    [[nodiscard]] auto HasHeadPartType(const RE::TESRace* race, HeadPartType type) noexcept -> bool;
    [[nodiscard]] auto IsAlternateForm(const RE::TESRace* race) noexcept -> bool;
    // get/set race
    [[nodiscard]] auto GetRaceProxy(const RE::TESRace* race) noexcept -> const RE::TESRace*;
    [[nodiscard]] auto GetProxyOrRace(const RE::TESRace* race) noexcept -> const RE::TESRace*;
    [[nodiscard]] auto ResolveTargetRace(const RE::TESRace* origin, const RE::TESRace* target) noexcept -> const RE::TESRace*;
    [[nodiscard]] auto GetOriginRace(const RE::FormID actor_id) noexcept -> const RE::TESRace*;
    // after successful switch; had_origin is from the pre-switch lookup
    void UpdateOriginRace(RE::FormID actor_id, const RE::TESRace* previous, const RE::TESRace* current, bool had_origin);
    // summary
    void LogSummary();

    namespace headpart
    {
#define ADD_RACE_ARGS RE::TESRace *race, RE::TESRace *vampire_race

        auto StringToHeadPartType(std::string_view head_part_str) -> HeadPartType;

        class HeadPartFormIdListAdder
        {
        public:
            HeadPartFormIdListAdder();
            [[nodiscard]] bool IsInitialized() const;
            void               AddRacePair(ADD_RACE_ARGS, HeadPartType type) const;

        private:
#define X(LIST) RE::BGSListForm*(LIST){ nullptr };
            HEAD_PART_LISTS
#undef X

#define X(TYPE) void Add##TYPE(ADD_RACE_ARGS) const;
            HEAD_PART_TYPES
#undef X
        };
    }  // namespace headpart
}  // namespace rcs::manager
