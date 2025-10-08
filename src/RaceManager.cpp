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
		if (race && !proxies.empty()) {
			raceProxies.emplace(race, std::move(proxies));
		}
	}

	void EmplaceArmorRaceProxies(const RE::TESRace* race, std::vector<ArmorProxyEntry>&& proxies)
	{
		if (race && !proxies.empty()) {
			armorRaceProxies.emplace(race, std::move(proxies));
		}
	}

	void EmplaceHeadPartType(const RE::TESRace* race, HeadPartType type)
	{
		if (race) {
			headPartMap.emplace(race, type);
		}
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
		if (!source_race || !target_race) {
			return false;
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
			for (const auto& [proxy, slotMask] : it->second) {
				if (slots.any(slotMask)) {
					return proxy;
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
		logs::info("{:*^30}"sv, "SUMMARY"sv);
		logs::info("Added {} vampirism race pairs"sv, vampirismPairs.size());
		logs::info("Proxied {} race(s)"sv, raceProxies.size());
		logs::info("Proxied {} armor race(s)"sv, armorRaceProxies.size());
		logs::info("Recorded head part types for {} races"sv, headPartMap.size());
	}

	namespace headpart
	{
		namespace
		{
			template <typename... Args>
			void AddRaceTo(RE::TESRace* race, Args... args)
			{
				if (race) {
					(..., (args->HasForm(race) ? 0 : (args->AddForm(race), 1)));
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
			EmplaceHeadPartType(race, type);
			EmplaceHeadPartType(vampire_race, type);
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