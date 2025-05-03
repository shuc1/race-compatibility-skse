#include "RaceManager.h"

namespace rcs::manager
{
	void EmplaceVampirismRacePair(const RE::TESRace* race, const RE::TESRace* vampire_race)
	{
		if (race && vampire_race) {
			vampirismPairs.emplace_back(std::make_pair(race, vampire_race));
		}
	}

	void EmplaceRaceProxies(const RE::TESRace* race, std::set<const RE::TESRace*>&& proxies)
	{
		if (proxies.size()) {
			raceProxies.emplace(race, proxies);
		}
	}

	void EmplaceArmorRaceProxies(const RE::TESRace* race, std::vector<ArmorProxyEntry>&& proxies)
	{
		if (proxies.size()) {
			armorRaceProxies.emplace(race, proxies);
		}
	}

	void EmplaceHeadPartRaces(const RE::TESRace* race, const RE::TESRace* vampire_race, HeadPartType type)
	{
		headPartMap.emplace(race, type);
		headPartMap.emplace(vampire_race, type);
	}

	auto GetVampireRaceByRace(const RE::TESRace* race)
		-> const RE::TESRace*
	{
		const auto it = std::ranges::find_if(vampirismPairs,
			[&](auto& pair) { return pair.first == race; });
		return (it == vampirismPairs.end()) ? nullptr : it->second;
	}

	auto GetRaceByVampireRace(const RE::TESRace* vampire_race)
		-> const RE::TESRace*
	{
		const auto it = std::ranges::find_if(vampirismPairs,
			[&](auto& pair) { return pair.second == vampire_race; });
		return (it == vampirismPairs.end()) ? nullptr : it->first;
	}

	auto GetIsRaceByProxy(const RE::TESRace* source_race, const RE::TESRace* target_race)
		-> bool
	{
		if (source_race == target_race) {
			return true;
		}
		const auto it = raceProxies.find(source_race);
		return it != raceProxies.end() && it->second.contains(target_race);
	}

	auto GetProxyArmorParentRace(const RE::TESObjectARMA* armor_addon, const RE::TESRace* race)
		-> const RE::TESRace*
	{
		if (const auto it = armorRaceProxies.find(race);
			it != armorRaceProxies.end()) {
			auto& slots = armor_addon->bipedModelData.bipedObjectSlots;
			for (const auto& proxy : it->second) {
				if (slots.any(proxy.slotMask)) {
					return proxy.race;
				}
			}
		}
		return race->armorParentRace;
	}

	auto GetHeadPartType(const RE::TESRace* race)
		-> HeadPartType
	{
		const auto it = headPartMap.find(race);
		return it != headPartMap.end() ? it->second : kNone;
	}

	void Summary()
	{
		logs::info("{:*^30}", "SUMMARY");
		logs::info("Added {} vampirism race pairs"sv, vampirismPairs.size());
		logs::info("Proxied {} race(s)"sv, raceProxies.size());
		logs::info("Proxied {} armor race(s)"sv, armorRaceProxies.size());
		logs::info("Added {} race(s) to head part lists"sv, headPartMap.size());
	}

	namespace headpart
	{
		auto StringToHeadPartType(const std::string_view head_part_str)
			-> HeadPartType
		{
			const std::map<std::string_view, HeadPartType> type_map{
				{ "Argonian"sv, kArgonian },
				{ "Elf"sv, kElf },
				{ "DarkElf"sv, kDarkElf },
				{ "HighElf"sv, kHighElf },
				{ "WoodElf"sv, kWoodElf },
				{ "Human"sv, kHuman },
				{ "Breton"sv, kBreton },
				{ "Imperial"sv, kImperial },
				{ "Nord"sv, kNord },
				{ "Redguard"sv, kRedguard },
				{ "Khajiit"sv, kKhajiit },
				{ "Orc"sv, kOrc }
			};
			const auto it = type_map.find(head_part_str);
			return it != type_map.end() ? it->second : kNone;
		}

		HeadPartFormIdListAdder::HeadPartFormIdListAdder()
		{
#define LookupFormIdLists(a_editor_id) RE::TESForm::LookupByEditorID<RE::BGSListForm>(a_editor_id)
			argonian = LookupFormIdLists("HeadPartsArgonian"sv);
			elves = LookupFormIdLists("HeadPartsElves"sv);
			high_elf = LookupFormIdLists("HeadPartsHighElf"sv);
			wood_elf = LookupFormIdLists("HeadPartsWoodElf"sv);
			dark_elf = LookupFormIdLists("HeadPartsDarkElf"sv);
			human = LookupFormIdLists("HeadPartsHuman"sv);
			breton = LookupFormIdLists("HeadPartsBreton"sv);
			imperial = LookupFormIdLists("HeadPartsImperial"sv);
			nord = LookupFormIdLists("HeadPartsNord"sv);
			redguard = LookupFormIdLists("HeadPartsRedguard"sv);
			khajiit = LookupFormIdLists("HeadPartsKhajiit"sv);
			orc = LookupFormIdLists("HeadPartsOrc"sv);
			all_races_minus_beast_vampires = LookupFormIdLists("HeadPartsAllRacesMinusBeastVampires"sv);

			argonian_vampire = LookupFormIdLists("HeadPartsArgonianVampire"sv);
			humanoid_vampire = LookupFormIdLists("HeadPartsHumanoidVampire"sv);
			human_vampires = LookupFormIdLists("HeadPartsHumanVampires"sv);
			khajiit_vampire = LookupFormIdLists("HeadPartsKhajiitVampire"sv);

			argonian_and_vampire = LookupFormIdLists("HeadPartsArgonianandVampire"sv);
			elves_and_vampires = LookupFormIdLists("HeadPartsElvesandVampires"sv);
			dark_elf_and_vampire = LookupFormIdLists("HeadPartsDarkElfandVampire"sv);
			high_elf_and_vampire = LookupFormIdLists("HeadPartsHighElfandVampire"sv);
			wood_elf_and_vampire = LookupFormIdLists("HeadPartsWoodElfandVampire"sv);
			humans_and_vampires = LookupFormIdLists("HeadPartsHumansandVampires"sv);
			breton_and_vampire = LookupFormIdLists("HeadPartsBretonandVampire"sv);
			imperial_and_vampire = LookupFormIdLists("HeadPartsImperialandVampire"sv);
			nord_and_vampire = LookupFormIdLists("HeadPartsNordandVampire"sv);
			redguard_and_vampire = LookupFormIdLists("HeadPartsRedguardandVampire"sv);
			khajiit_and_vampire = LookupFormIdLists("HeadPartsKhajiitandVampire"sv);
			orc_and_vampire = LookupFormIdLists("HeadPartsOrcandVampire"sv);
			all_races_minus_beast = LookupFormIdLists("HeadPartsAllRacesMinusBeast"sv);
			humans_orcs_and_vampires = LookupFormIdLists("HeadPartsHumansOrcsandVampires"sv);
#undef LookupFormIdLists
		}

		auto HeadPartFormIdListAdder::IsInitialized() const -> bool
		{
			return argonian && elves && dark_elf && high_elf && wood_elf &&
			       human && breton && imperial && nord && redguard &&
			       khajiit && orc && all_races_minus_beast_vampires &&
			       argonian_vampire &&
			       humanoid_vampire && dark_elf_and_vampire && high_elf_and_vampire && wood_elf_and_vampire &&
			       human_vampires && breton_and_vampire && imperial_and_vampire && nord_and_vampire && redguard_and_vampire &&
			       khajiit_vampire && argonian_and_vampire && elves_and_vampires &&
			       humans_and_vampires && khajiit_and_vampire && orc_and_vampire && all_races_minus_beast &&
			       humans_orcs_and_vampires;
		}

#define ADD_RACE_ARGS RE::TESRace *race, RE::TESRace *vampire_race
		void HeadPartFormIdListAdder::AddRace(ADD_RACE_ARGS, Type type)
		{
			constexpr std::array adder{
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

			if (type != kNone) {
				(this->*adder[std::to_underlying(type)])(race, vampire_race);
				EmplaceHeadPartRaces(race, vampire_race, type);
			}
		}

		template <typename... Args>
		void AddRaceTo(RE::TESRace* race, Args... args)
		{
			if (race) {
				(..., (args->HasForm(race) ? 0 : (args->AddForm(race), 1)));
			}
		}

		void HeadPartFormIdListAdder::AddArgonian(ADD_RACE_ARGS)
		{
			AddRaceTo(race, argonian, argonian_and_vampire);
			AddRaceTo(vampire_race, argonian_vampire, argonian_and_vampire);
		}

#define NON_BEAST_RACES all_races_minus_beast_vampires, all_races_minus_beast
#define NON_BEAST_VAMPIRE_RACES all_races_minus_beast

#define ELF_RACES NON_BEAST_RACES, elves, elves_and_vampires
#define ELF_VAMPIRE_RACES NON_BEAST_VAMPIRE_RACES, humanoid_vampire, elves_and_vampires
		void HeadPartFormIdListAdder::AddElf(ADD_RACE_ARGS)
		{
			AddRaceTo(race, ELF_RACES);
			AddRaceTo(vampire_race, ELF_VAMPIRE_RACES);
		}

#define ADD_ELF_FUNCTION(a_name, a_name_camel)                            \
	void HeadPartFormIdListAdder::Add##a_name_camel(ADD_RACE_ARGS)        \
	{                                                                     \
		AddRaceTo(race, ELF_RACES, a_name, a_name##_and_vampire);         \
		AddRaceTo(vampire_race, ELF_VAMPIRE_RACES, a_name##_and_vampire); \
	}

		ADD_ELF_FUNCTION(dark_elf, DarkElf)
		ADD_ELF_FUNCTION(high_elf, HighElf)
		ADD_ELF_FUNCTION(wood_elf, WoodElf)
#undef ELF_RACES
#undef ELF_VAMPIRE_RACES
#undef ADD_ELF_FUNCTION

#define HUMAN_RACES NON_BEAST_RACES, human, humans_and_vampires, humans_orcs_and_vampires
#define HUMAN_VAMPIRE_RACES NON_BEAST_VAMPIRE_RACES, human_vampires, humanoid_vampire, humans_and_vampires, humans_orcs_and_vampires
		void HeadPartFormIdListAdder::AddHuman(ADD_RACE_ARGS)
		{
			AddRaceTo(race, HUMAN_RACES);
			AddRaceTo(vampire_race, HUMAN_VAMPIRE_RACES);
		}

#define ADD_HUMAN_FUNCTION(a_name, a_name_camel)                            \
	void HeadPartFormIdListAdder::Add##a_name_camel(ADD_RACE_ARGS)          \
	{                                                                       \
		AddRaceTo(race, HUMAN_RACES, a_name, a_name##_and_vampire);         \
		AddRaceTo(vampire_race, HUMAN_VAMPIRE_RACES, a_name##_and_vampire); \
	}

		ADD_HUMAN_FUNCTION(breton, Breton)
		ADD_HUMAN_FUNCTION(imperial, Imperial)
		ADD_HUMAN_FUNCTION(nord, Nord)
		ADD_HUMAN_FUNCTION(redguard, Redguard)
#undef HUMAN_RACES
#undef HUMAN_VAMPIRE_RACES
#undef ADD_HUMAN_FUNCTION

		void HeadPartFormIdListAdder::AddKhajiit(ADD_RACE_ARGS)
		{
			AddRaceTo(race, khajiit, khajiit_and_vampire);
			AddRaceTo(vampire_race, khajiit_vampire, khajiit_and_vampire);
		}

		void HeadPartFormIdListAdder::AddOrc(ADD_RACE_ARGS)
		{
			AddRaceTo(race, NON_BEAST_RACES, orc, orc_and_vampire, humans_orcs_and_vampires);
			AddRaceTo(vampire_race, NON_BEAST_VAMPIRE_RACES, humanoid_vampire, orc_and_vampire, humans_orcs_and_vampires);
		}
#undef NON_BEAST_RACES
#undef NON_BEAST_VAMPIRE_RACES
	}  // namespace headpart
}  // namespace rcs::manager