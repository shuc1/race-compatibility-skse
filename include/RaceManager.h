#pragma once

namespace rcs::manager
{
	class RaceManager :
		public REX::Singleton<RaceManager>
	{
	public:
		enum HeadPartType : char
		{
			kNone,
			kArgonian,
			kElf,
			kDarkElf,
			kHighElf,
			kWoodElf,
			kHuman,
			kBreton,
			kImperial,
			kNord,
			kRedguard,
			kKhajiit,
			kOrc,
		};

		struct ArmorProxyEntry
		{
			RE::TESRace*                            race;
			RE::BGSBipedObjectForm::BipedObjectSlot slotMask;
		};

		// TODO: could use another struct to collect all proxy config, but leave it for now
		std::vector<std::pair<const RE::TESRace*, const RE::TESRace*>> vampirismPairs{};
		std::map<const RE::TESRace*, std::set<const RE::TESRace*>>     raceProxies{};
		std::map<const RE::TESRace*, std::vector<ArmorProxyEntry>>     armorRaceProxies{};
		std::map<const RE::TESRace*, HeadPartType>                     headPartMap{};

		// emplace
		void EmplaceVampirismRacePair(const RE::TESRace* race, const RE::TESRace* vampire_race);
		void EmplaceRaceProxies(const RE::TESRace* race, std::set<const RE::TESRace*>&& proxies);
		void EmplaceArmorRaceProxies(const RE::TESRace* race, std::vector<ArmorProxyEntry>&& proxies);
		void EmplaceHeadPartRaces(const RE::TESRace* race, const RE::TESRace* vampire_race, HeadPartType type);
		// judge
		auto GetVampireRaceByRace(const RE::TESRace* race) const -> const RE::TESRace*;
		auto GetRaceByVampireRace(const RE::TESRace* vampire_race) const -> const RE::TESRace*;
		auto GetIsRaceByProxy(const RE::TESRace* source_race, const RE::TESRace* target_race) const -> bool;
		auto GetProxyArmorParentRace(const RE::TESObjectARMA* armor_addon, const RE::TESRace* race) const -> const RE::TESRace*;
		auto GetHeadPartType(const RE::TESRace* race) const -> const HeadPartType;
		// summary
		void Summary();
	};

	namespace headpart
	{
		class HeadPartFormIdListAdder
		{
		public:
			using Type = RaceManager::HeadPartType;

			HeadPartFormIdListAdder(bool& is_initialized);
			Type GetHeadPartType(std::string_view head_part_str);
#define ADD_RACE_ARGS RE::TESRace *race, RE::TESRace *vampire_race
			void AddRace(ADD_RACE_ARGS, Type type);

		private:
			const std::map<std::string_view, Type> type_map{
				{ "Argonian"sv, Type::kArgonian },
				{ "Elf"sv, Type::kElf },
				{ "DarkElf"sv, Type::kDarkElf },
				{ "HighElf"sv, Type::kHighElf },
				{ "WoodElf"sv, Type::kWoodElf },
				{ "Human"sv, Type::kHuman },
				{ "Breton"sv, Type::kBreton },
				{ "Imperial"sv, Type::kImperial },
				{ "Nord"sv, Type::kNord },
				{ "Redguard"sv, Type::kRedguard },
				{ "Khajiit"sv, Type::kKhajiit },
				{ "Orc"sv, Type::kOrc }
			};

			const std::array<void (HeadPartFormIdListAdder::*)(RE::TESRace*, RE::TESRace*), 13> kAdder{
				&HeadPartFormIdListAdder::AddNone,
				&HeadPartFormIdListAdder::AddArgonian,
				&HeadPartFormIdListAdder::AddElf,
				&HeadPartFormIdListAdder::AddDarkElf,
				&HeadPartFormIdListAdder::AddHighElf,
				&HeadPartFormIdListAdder::AddWoodElf,
				&HeadPartFormIdListAdder::AddHuman,
				&HeadPartFormIdListAdder::AddBreton,
				&HeadPartFormIdListAdder::AddImperial,
				&HeadPartFormIdListAdder::AddNord,
				&HeadPartFormIdListAdder::AddRedguard,
				&HeadPartFormIdListAdder::AddKhajiit,
				&HeadPartFormIdListAdder::AddOrc
			};

			// for normal races
			// argonian
			RE::BGSListForm* argonian{ nullptr };
			// elves
			RE::BGSListForm* elves{ nullptr };
			RE::BGSListForm* dark_elf{ nullptr };
			RE::BGSListForm* high_elf{ nullptr };
			RE::BGSListForm* wood_elf{ nullptr };
			// humans
			RE::BGSListForm* human{ nullptr };
			RE::BGSListForm* breton{ nullptr };
			RE::BGSListForm* imperial{ nullptr };
			RE::BGSListForm* nord{ nullptr };
			RE::BGSListForm* redguard{ nullptr };
			// khajiit
			RE::BGSListForm* khajiit{ nullptr };
			// orc
			RE::BGSListForm* orc{ nullptr };
			// non-beast races
			RE::BGSListForm* all_races_minus_beast_vampires{ nullptr };

			// for vampire races
			// argonian vampire
			RE::BGSListForm* argonian_vampire{ nullptr };
			// elf, human and orc vampires
			RE::BGSListForm* humanoid_vampire{ nullptr };
			// human vampires
			RE::BGSListForm* human_vampires{ nullptr };
			// khajiit vampire
			RE::BGSListForm* khajiit_vampire{ nullptr };

			// for both normal and vampire races
			// argonian and argonian vampire
			RE::BGSListForm* argonian_and_vampire{ nullptr };
			// elves and elf vampires
			RE::BGSListForm* elves_and_vampires{ nullptr };
			RE::BGSListForm* dark_elf_and_vampire{ nullptr };
			RE::BGSListForm* high_elf_and_vampire{ nullptr };
			RE::BGSListForm* wood_elf_and_vampire{ nullptr };
			// humans and human vampires
			RE::BGSListForm* humans_and_vampires{ nullptr };
			RE::BGSListForm* breton_and_vampire{ nullptr };
			RE::BGSListForm* imperial_and_vampire{ nullptr };
			RE::BGSListForm* nord_and_vampire{ nullptr };
			RE::BGSListForm* redguard_and_vampire{ nullptr };
			// khajiit and khajiit vampire
			RE::BGSListForm* khajiit_and_vampire{ nullptr };
			// orc and orc vampire
			RE::BGSListForm* orc_and_vampire{ nullptr };
			// non-beast races and vampires
			RE::BGSListForm* all_races_minus_beast{ nullptr };
			// non-beast, non-elf races and vampires
			RE::BGSListForm* humans_orcs_and_vampires{ nullptr };

			void AddNone([[maybe_unused]] RE::TESRace* race, [[maybe_unused]] RE::TESRace* vampire_race) {};
			void AddNonBeast(ADD_RACE_ARGS);
			void AddArgonian(ADD_RACE_ARGS);
			void AddElf(ADD_RACE_ARGS);
			void AddDarkElf(ADD_RACE_ARGS);
			void AddHighElf(ADD_RACE_ARGS);
			void AddWoodElf(ADD_RACE_ARGS);
			void AddHuman(ADD_RACE_ARGS);
			void AddBreton(ADD_RACE_ARGS);
			void AddImperial(ADD_RACE_ARGS);
			void AddNord(ADD_RACE_ARGS);
			void AddRedguard(ADD_RACE_ARGS);
			void AddKhajiit(ADD_RACE_ARGS);
			void AddOrc(ADD_RACE_ARGS);

#undef ADD_RACE_ARGS
		};
	}  // namespace headpart
}  // namespace rcs::manager