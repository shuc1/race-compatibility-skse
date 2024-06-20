#pragma once

#include "race_manager.h"

namespace race_compatibility
{
	namespace ini
	{
		namespace detail
		{
			constexpr auto SECTION_MIN_SIZE = 2;
			constexpr auto SECTION_MAX_SIZE = 5;

			using path_t = std::shared_ptr<std::string>;
			// key(RCS)-value(raw entries)
			using entries_t = std::vector<std::pair<std::shared_ptr<std::string>, std::shared_ptr<std::string>>>;
			using raw_configs_t = std::vector<std::pair<path_t, entries_t>>;

			using record_ptr_t = std::shared_ptr<record_t>;
			using record_cache_t = std::map<std::string, record_ptr_t>;

			struct ConfigData
			{
				record_ptr_t                    race{};
				record_ptr_t                    vampire_race{};
				std::vector<record_ptr_t>       proxy_races{};
				std::vector<record_ptr_t>       proxy_vampire_races{};
				manager::RaceFlag head_part_flag{ 0 };
			};

			// path-config data
			using parsed_entry_t = std::vector<ConfigData>;
			using parsed_config_t = std::pair<std::shared_ptr<std::string>, parsed_entry_t>;
			using parsed_configs_t = std::vector<parsed_config_t>;

			namespace cache
			{
				using key_cache_t = std::map<std::string, entries_t::value_type::first_type>;
				using parse_cache_t = std::pair<record_cache_t&, lookup::form::race_lookup_table_t&>;
			}

			namespace apply
			{
				using uasage_map_t = std::map<RE::TESRace*, std::shared_ptr<std::string>>;
			}
		}

		// Format: RCS = RaceEditorID|VampireRaceEditorID|RaceProxyEditorIDs|VampireRaceProxyEditorIDs|HeadPartFlag
		// Restrict: RCS = MUST|MUST|OPTIONAL|OPTIONAL|OPTIONAL
		// RaceProxyEditorIDs: "A,B" for A or B race
		// HeadPartFlag: B(Beasts), E(Elf), H(Human), O(Orc)
		bool TryReadAndApplyConfigs();
	}
}