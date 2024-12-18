#include "RaceManager.h"
#include "forms.h"

namespace rcs::manager
{
	void EmplaceVampirismRacePair(const RE::TESRace* race, const RE::TESRace* vampire_race)
	{
		vampirismPairs.emplace_back(std::make_pair(race, vampire_race));
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
		const auto it = std::find_if(vampirismPairs.begin(), vampirismPairs.end(),
			[&](auto& pair) { return pair.first == race; });
		return (it == vampirismPairs.end()) ? nullptr : it->second;
	}

	auto GetRaceByVampireRace(const RE::TESRace* vampire_race)
		-> const RE::TESRace*
	{
		const auto it = std::find_if(vampirismPairs.begin(), vampirismPairs.end(),
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
		-> const HeadPartType
	{
		const auto it = headPartMap.find(race);
		return it != headPartMap.end() ? it->second : HeadPartType::kNone;
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
		HeadPartFormIdListAdder::HeadPartFormIdListAdder(bool& is_initialized)
		{
			is_initialized = false;
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

			is_initialized = argonian && elves && dark_elf && high_elf && wood_elf &&
			                 human && breton && imperial && nord && redguard &&
			                 khajiit && orc && all_races_minus_beast_vampires &&
			                 argonian_vampire &&
			                 humanoid_vampire && dark_elf_and_vampire && high_elf_and_vampire && wood_elf_and_vampire &&
			                 human_vampires && breton_and_vampire && imperial_and_vampire && nord_and_vampire && redguard_and_vampire &&
			                 khajiit_vampire && argonian_and_vampire && elves_and_vampires &&
			                 humans_and_vampires && khajiit_and_vampire && orc_and_vampire && all_races_minus_beast &&
			                 humans_orcs_and_vampires;
		}

		auto HeadPartFormIdListAdder::GetHeadPartType(std::string_view head_part_str) -> Type
		{
			auto it = type_map.find(head_part_str);
			return it != type_map.end() ? it->second : Type::kNone;
		}

#define ADD_RACE_ARGS RE::TESRace *race, RE::TESRace *vampire_race
		void HeadPartFormIdListAdder::AddRace(ADD_RACE_ARGS, Type type)
		{
			if (type != Type::kNone) {
				(*this.*(kAdder[std::to_underlying(type)]))(race, vampire_race);
				EmplaceHeadPartRaces(race, vampire_race, type);
			}
		}

#define TRY_ADD_RACE(a_form_id_list, a_race)  \
	if (!(a_form_id_list->HasForm(a_race))) { \
		a_form_id_list->AddForm(a_race);      \
	}

#define ADD_RACE_TO(a_form_id_list) TRY_ADD_RACE(a_form_id_list, race)
#define ADD_VAMPIRE_RACE_TO(a_form_id_list) TRY_ADD_RACE(a_form_id_list, vampire_race)
#define ADD_BOTH_RACES_TO(a_form_id_list) \
	ADD_RACE_TO(a_form_id_list)           \
	ADD_VAMPIRE_RACE_TO(a_form_id_list)

		void HeadPartFormIdListAdder::AddNonBeast(ADD_RACE_ARGS)
		{
			ADD_BOTH_RACES_TO(all_races_minus_beast)
			ADD_RACE_TO(all_races_minus_beast_vampires)
		}

		void HeadPartFormIdListAdder::AddArgonian(ADD_RACE_ARGS)
		{
			using func_t = decltype(&HeadPartFormIdListAdder::AddArgonian);
			ADD_RACE_TO(argonian)
			ADD_VAMPIRE_RACE_TO(argonian_vampire)
			ADD_BOTH_RACES_TO(argonian_and_vampire)
		}

		void HeadPartFormIdListAdder::AddElf(ADD_RACE_ARGS)
		{
			AddNonBeast(race, vampire_race);
			ADD_RACE_TO(elves)
			ADD_VAMPIRE_RACE_TO(humanoid_vampire)
			ADD_BOTH_RACES_TO(elves_and_vampires)
		}

		void HeadPartFormIdListAdder::AddDarkElf(ADD_RACE_ARGS)
		{
			AddElf(race, vampire_race);
			ADD_RACE_TO(dark_elf)
			ADD_VAMPIRE_RACE_TO(dark_elf_and_vampire)
		}

		void HeadPartFormIdListAdder::AddHighElf(ADD_RACE_ARGS)
		{
			AddElf(race, vampire_race);
			ADD_RACE_TO(high_elf)
			ADD_VAMPIRE_RACE_TO(high_elf_and_vampire)
		}

		void HeadPartFormIdListAdder::AddWoodElf(ADD_RACE_ARGS)
		{
			AddElf(race, vampire_race);
			ADD_RACE_TO(wood_elf)
			ADD_VAMPIRE_RACE_TO(wood_elf_and_vampire)
		}

		void HeadPartFormIdListAdder::AddHuman(ADD_RACE_ARGS)
		{
			AddNonBeast(race, vampire_race);
			ADD_RACE_TO(human)
			ADD_VAMPIRE_RACE_TO(human_vampires)
			ADD_VAMPIRE_RACE_TO(humanoid_vampire)
			ADD_BOTH_RACES_TO(humans_and_vampires)
			ADD_BOTH_RACES_TO(humans_orcs_and_vampires)
		}

		void HeadPartFormIdListAdder::AddBreton(ADD_RACE_ARGS)
		{
			AddHuman(race, vampire_race);
			ADD_RACE_TO(breton)
			ADD_VAMPIRE_RACE_TO(breton_and_vampire)
		}

		void HeadPartFormIdListAdder::AddImperial(ADD_RACE_ARGS)
		{
			AddHuman(race, vampire_race);
			ADD_RACE_TO(imperial)
			ADD_VAMPIRE_RACE_TO(imperial_and_vampire)
		}

		void HeadPartFormIdListAdder::AddNord(ADD_RACE_ARGS)
		{
			AddHuman(race, vampire_race);
			ADD_RACE_TO(nord)
			ADD_VAMPIRE_RACE_TO(nord_and_vampire)
		}

		void HeadPartFormIdListAdder::AddRedguard(ADD_RACE_ARGS)
		{
			AddHuman(race, vampire_race);
			ADD_RACE_TO(redguard)
			ADD_VAMPIRE_RACE_TO(redguard_and_vampire)
		}

		void HeadPartFormIdListAdder::AddKhajiit(ADD_RACE_ARGS)
		{
			ADD_RACE_TO(khajiit)
			ADD_VAMPIRE_RACE_TO(khajiit_vampire)
			ADD_BOTH_RACES_TO(khajiit_and_vampire)
		}

		void HeadPartFormIdListAdder::AddOrc(ADD_RACE_ARGS)
		{
			AddNonBeast(race, vampire_race);
			ADD_RACE_TO(orc)
			ADD_VAMPIRE_RACE_TO(humanoid_vampire)
			ADD_BOTH_RACES_TO(orc_and_vampire)
			ADD_BOTH_RACES_TO(humans_orcs_and_vampires)
		}
#undef ADD_BOTH_RACES_TO
#undef ADD_VAMPIRE_RACE_TO
#undef ADD_RACE_TO
#undef TRY_ADD_RACE

#undef ADD_RACE_ARGS
	}  // namespace headpart
}  // namespace rcs::manager