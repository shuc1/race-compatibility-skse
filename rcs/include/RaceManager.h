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
    struct ArmorOverride
    {
        const RE::TESRace*                      proxy;
        RE::BGSBipedObjectForm::BipedObjectSlot slotMask;
    };

    struct FunctionBinding
    {
        RE::BSFixedString state;
        RE::BSFixedString name;
        std::size_t       ruleIndex;
        std::size_t       functionIndex;
    };

    struct ScriptBinding
    {
        RE::BSFixedString            name;
        std::vector<FunctionBinding> functions;
    };

    struct GetRaceExclusion
    {
        std::vector<const RE::BSScript::IFunction*> functions;
        std::vector<const RE::TESRace*>             unlessProxyMatches;
    };

    inline std::unordered_map<const RE::TESRace*, const RE::TESRace*>         raceProxies{};
    inline std::unordered_map<const RE::TESRace*, std::vector<ArmorOverride>> armorRaceProxies{};
    inline std::unordered_map<RE::FormID, const RE::TESRace*>                 originRaces{};
    inline std::vector<ScriptBinding>                                         scriptBindings{};
    inline std::vector<GetRaceExclusion>                                      getRaceExclusions{};

    // emplace
    void EmplaceRaceGroup(std::vector<const RE::TESRace*>&& races);
    void EmplaceRaceProxy(const RE::TESRace* race, const RE::TESRace* proxy) noexcept;
    void EmplaceArmorRaceProxies(const RE::TESRace* race, std::vector<ArmorOverride>&& proxies) noexcept;
    void AddAlternateForm(const RE::TESRace* race);
    // judge
    [[nodiscard]] auto GetIsRaceByProxy(const RE::TESRace* source_race, const RE::TESRace* target_race) noexcept -> bool;
    [[nodiscard]] auto ResolveArmorParentRace(const RE::TESObjectARMA* armor_addon, const RE::TESRace* race) noexcept -> const RE::TESRace*;
    [[nodiscard]] auto IsAlternateForm(const RE::TESRace* race) noexcept -> bool;
    // get/set race
    [[nodiscard]] auto IsGetRaceExcluded(const RE::BSScript::IFunction* function, const RE::TESRace* current) noexcept -> bool;
    [[nodiscard]] auto GetRaceProxy(const RE::TESRace* race) noexcept -> const RE::TESRace*;
    [[nodiscard]] auto ResolveTargetRace(const RE::TESRace* origin, const RE::TESRace* target) noexcept -> const RE::TESRace*;
    [[nodiscard]] auto GetOriginRace(const RE::FormID actor_id) noexcept -> const RE::TESRace*;
    // after successful switch; had_origin is from the pre-switch lookup
    void UpdateOriginRace(RE::FormID actor_id, const RE::TESRace* previous, const RE::TESRace* current, bool had_origin);
    // summary
    void LogSummary();

    namespace headpart
    {
        class HeadPartFormIdListAdder
        {
        public:
            HeadPartFormIdListAdder();
            [[nodiscard]] bool IsInitialized() const;
            void               AddRace(RE::TESRace* race, std::string_view type) const;

        private:
#define X(LIST) RE::BGSListForm*(LIST){ nullptr };
            HEAD_PART_LISTS
#undef X

#define X(TYPE)                              \
    void Add##TYPE(RE::TESRace* race) const; \
    void Add##TYPE##Vampire(RE::TESRace* vampire_race) const;
            HEAD_PART_TYPES
#undef X
        };
    }  // namespace headpart
}  // namespace rcs::manager
