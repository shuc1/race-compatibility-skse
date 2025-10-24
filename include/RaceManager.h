#pragma once

#define HEAD_PART_TYPES \
	X(Argonian)         \
	X(Elf)              \
	X(DarkElf)          \
	X(HighElf)          \
	X(WoodElf)          \
	X(Human)            \
	X(Breton)           \
	X(Imperial)         \
	X(Nord)             \
	X(Redguard)         \
	X(Khajiit)          \
	X(Orc)

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
	enum HeadPartType : char
	{
		kNone,
#define X(TYPE) k##TYPE,
		HEAD_PART_TYPES
#undef X
	};

	struct ArmorProxyEntry
	{
		RE::TESRace*                            proxy;
		RE::BGSBipedObjectForm::BipedObjectSlot slotMask;
	};

	inline std::vector<std::pair<const RE::TESRace*, const RE::TESRace*>>       vampirismPairs{};
	inline std::unordered_map<const RE::TESRace*, std::set<const RE::TESRace*>> raceProxies{};
	inline std::unordered_map<const RE::TESRace*, std::vector<ArmorProxyEntry>> armorRaceProxies{};
	inline std::unordered_map<const RE::TESRace*, HeadPartType>                 headPartMap{};

	// emplace
	void EmplaceVampirismRacePair(const RE::TESRace* race, const RE::TESRace* vampire_race) noexcept;
	void EmplaceRaceProxies(const RE::TESRace* race, std::set<const RE::TESRace*>&& proxies) noexcept;
	void EmplaceArmorRaceProxies(const RE::TESRace* race, std::vector<ArmorProxyEntry>&& proxies) noexcept;
	void EmplaceHeadPartType(const RE::TESRace* race, HeadPartType type) noexcept;
	// judge
	[[nodiscard]] auto GetVampireRaceByRace(const RE::TESRace* race) noexcept -> const RE::TESRace*;
	[[nodiscard]] auto GetRaceByVampireRace(const RE::TESRace* vampire_race) noexcept -> const RE::TESRace*;
	[[nodiscard]] auto GetIsRaceByProxy(const RE::TESRace* source_race, const RE::TESRace* target_race) noexcept -> bool;
	[[nodiscard]] auto GetArmorParentRaceProxy(const RE::TESObjectARMA* armor_addon, const RE::TESRace* race) noexcept -> const RE::TESRace*;
	[[nodiscard]] auto GetHeadPartType(const RE::TESRace* race) noexcept -> HeadPartType;
	// summary
	void Summary();

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