#pragma once

namespace race_compatibility
{
	namespace manager
	{
#define NAME_OF(a_namespace) #a_namespace##sv
		namespace vampirism
		{
			// export functions to game scripting
			// there wouldn't be frequent calls to get original race of vampire race or vice versa
			inline std::vector<std::pair<RE::TESRace*, RE::TESRace*>> vampirism_race_pairs{};

			[[nodiscard]] static inline RE::TESRace* GetRaceByVampireRace(RE::TESRace* vampire_race)
			{
				auto it = std::find_if(vampirism_race_pairs.begin(), vampirism_race_pairs.end(),
					[&](std::pair<RE::TESRace*, RE::TESRace*>& pair) { return pair.second == vampire_race; });
				if (it == vampirism_race_pairs.end()) {
					return nullptr;
				} else {
					return it->first;
				}
			}

			[[nodiscard]] static inline RE::TESRace* GetVampireRaceByRace(RE::TESRace* race)
			{
				auto it = std::find_if(vampirism_race_pairs.begin(), vampirism_race_pairs.end(),
					[&](std::pair<RE::TESRace*, RE::TESRace*>& pair) { return pair.first == race; });
				if (it == vampirism_race_pairs.end()) {
					return nullptr;
				} else {
					return it->second;
				}
			}

			static inline void EmplaceVampirismRacePair(RE::TESRace* race, RE::TESRace* vampire_race)
			{
				vampirism_race_pairs.emplace_back(std::make_pair(race, vampire_race));
			}

			static inline void Summary()
			{
				logs::info("Summary({}): {} race pairs applied", NAME_OF(vampirism), vampirism_race_pairs.size());
			}
		}

		namespace compatibility
		{
			inline std::map<RE::TESRace*, std::set<RE::TESRace*>> race_map{};

			[[nodiscard]] static inline bool GetIsRaceByProxies(RE::TESRace* npc_race, RE::TESRace* race)
			{
				return race_map.contains(npc_race) && race_map.at(npc_race).contains(race);
			}

			static inline void EmplaceProxyRaces(
				decltype(race_map)::key_type                  race,
				decltype(race_map)::value_type::second_type&& set)
			{
				if (set.size() != 0) {
					race_map.emplace(race, set);
				}
			}

			static inline bool Summary()
			{
				auto size = race_map.size();
				logs::info("Summary({}): {} proxied race(s) applied", NAME_OF(compatibility), size);
				return (size != 0);
			}
		}

		namespace headpart
		{
			enum class HeadPartFlag : char
			{
				kNone = 0,
				kArgonian = 'A',
				kElf = 'E',
				kHuman = 'H',
				kKhajiit = 'K',
				kOrc = 'O'
			};

			inline std::map<char, HeadPartFlag> head_parts_flag_map_without_none{
#define MAKE_FLAG_MAP_PAIR(a_flag) { std::to_underlying(a_flag), a_flag }
				MAKE_FLAG_MAP_PAIR(HeadPartFlag::kArgonian),
				MAKE_FLAG_MAP_PAIR(HeadPartFlag::kElf),
				MAKE_FLAG_MAP_PAIR(HeadPartFlag::kHuman),
				MAKE_FLAG_MAP_PAIR(HeadPartFlag::kKhajiit),
				MAKE_FLAG_MAP_PAIR(HeadPartFlag::kOrc)
#undef MAKE_FLAG_MAP_PAIR
			};

			struct HeadPartFormIdLists
			{
				// for normal races
				// argonian
				RE::BGSListForm* argonian{ nullptr };
				// elves
				RE::BGSListForm* elves{ nullptr };
				// humans
				RE::BGSListForm* human{ nullptr };
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
				// humans and human vampires
				RE::BGSListForm* humans_and_vampires{ nullptr };
				// khajiit and khajiit vampire
				RE::BGSListForm* khajiit_and_vampire{ nullptr };
				// orc and orc vampire
				RE::BGSListForm* orc_and_vampire{ nullptr };
				// non-beast races and vampires
				RE::BGSListForm* all_races_minus_beast{ nullptr };
				// non-beast, non-elf races and vampires
				RE::BGSListForm* humans_orcs_and_vampires{ nullptr };

				bool         is_initialized{ false };
				std::uint8_t count{ 0 };

				void AddRace(RE::TESRace* race, RE::TESRace* vampire_race, HeadPartFlag flag);
				void Initialize();

			private:
				void AddArgonian(RE::TESRace* race, RE::TESRace* vampire_race);
				void AddElf(RE::TESRace* race, RE::TESRace* vampire_race);
				void AddHuman(RE::TESRace* race, RE::TESRace* vampire_race);
				void AddKhajiit(RE::TESRace* race, RE::TESRace* vampire_race);
				void AddOrc(RE::TESRace* race, RE::TESRace* vampire_race);
				void AddNonBeast(RE::TESRace* race, RE::TESRace* vampire_race);
			};

			static inline void Summary(const HeadPartFormIdLists& lists)
			{
				logs::info("Summary({}): attempted to add {} race pair(s) to head part lists", NAME_OF(headpart), lists.count);
			}
		}
#undef NAME_OF
	}
}