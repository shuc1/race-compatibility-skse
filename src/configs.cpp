#include "configs.h"

namespace race_compatibility
{
	namespace ini
	{
		namespace detail
		{
			namespace utility
			{
				static inline std::string Sanitize(const std::string& a_value)
				{
					//strip spaces between " | "
					static const srell::regex re_bar(R"(\s*\|\s*)", srell::regex_constants::optimize);
					//strip spaces between " , "
					static const srell::regex re_comma(R"(\s*,\s*)", srell::regex_constants::optimize);
					//convert 00012345 formIDs to 0x12345
					static const srell::regex re_formID(R"(\b00+([0-9a-fA-F]{1,6})\b)", srell::regex_constants::optimize);
					//strip leading zeros
					static const srell::regex re_zeros(R"((0x00+)([0-9a-fA-F]+))", srell::regex_constants::optimize);

					auto new_value{ a_value };
					if (!new_value.contains('~')) {
						clib_util::string::replace_first_instance(new_value, " - ", "~");
					}
					new_value = srell::regex_replace(new_value, re_bar, "|");
					new_value = srell::regex_replace(new_value, re_comma, ",");
					new_value = srell::regex_replace(new_value, re_formID, "0x$1");
					new_value = srell::regex_replace(new_value, re_zeros, "0x$2");
					return new_value;
				}

				static inline std::string RecordToString(const record_t& record)
				{
					return std::visit([](auto&& arg) -> std::string {
						using T = std::decay_t<decltype(arg)>;
						if constexpr (std::is_same_v<T, form_mod_pair_t>) {
							return std::format("0x{:X}~{}", arg.first, arg.second.value_or(""));
						} else if constexpr (std::is_same_v<T, std::string>) {
							return arg;
						}
					},
						record);
				}

				static inline record_t ConvertClibRecord(clib_util::distribution::record&& record)
				{
					if (const auto form_id = std::get_if<clib_util::distribution::formid_pair>(&record); form_id != nullptr) {
						return form_mod_pair_t{ form_id->first.value(), form_id->second };
					} else {
						return std::get<std::string>(record);
					}
				}

				static inline std::pair<bool, clib_util::distribution::record_type> IsRawStringValidRecord(const std::string& raw_str)
				{
					using namespace clib_util::distribution;
					if (!is_valid_entry(raw_str)) {
						return { false, record_type::kNone };
					}
					return { true, get_record_type(raw_str) };
				}
			}

			namespace cache
			{
				static inline std::shared_ptr<std::string> GetCachedEntryKey(const std::string& key, key_cache_t& key_cache)
				{
					if (key_cache.contains(key)) {
						return key_cache.at(key);
					} else {
						auto [it, _] = key_cache.emplace(key, std::make_shared<std::string>(key));
						return it->second;
					}
				}

				/// <summary>
				///
				/// </summary>
				/// <param name="raw_str"></param>
				/// <param name="cache"></param>
				/// <param name="a_record_type">must not be kMod</param>
				/// <returns></returns>
				static inline record_ptr_t GetCachedRecord(
					const std::string&                         raw_str,
					parse_cache_t&                             cache,
					const clib_util::distribution::record_type a_record_type = clib_util::distribution::record_type::kNone)
				{
					auto& [record_cache, table] = cache;

					if (!record_cache.contains(raw_str)) {
						using namespace clib_util::distribution;
						auto&& record = utility::ConvertClibRecord(
							get_record(a_record_type == record_type::kNone ? get_record_type(raw_str) : a_record_type, raw_str));

						// must success, ignore the bool returnval
						auto [it, _] = record_cache.emplace(raw_str,
							std::make_shared<record_t>(record));
						table.emplace(it->second, nullptr);
					}
					return record_cache.at(raw_str);
				}
			}

			namespace parse
			{
				static inline void ParseProxyRaces(const std::string& raw_string,
					decltype(ConfigData::proxy_races)& races, cache::parse_cache_t& cache)
				{
					using namespace clib_util::distribution;
					auto form_strings = split_entry(raw_string, ",");
					if (auto size = form_strings.size(); size > 0) {
						races.reserve(size);
						for (const auto& str : form_strings) {
							if (auto [is_valid, record_type] = utility::IsRawStringValidRecord(str);
								!is_valid || record_type == record_type::kMod) {
								logs::warn("\t\t\tInvalid form or form is a mod name: {}", str);
							} else {
								races.emplace_back(cache::GetCachedRecord(str, cache, record_type));
							}
						}
					}
				}

				static inline manager::RaceFlag ParseHeadPartFlag(const std::string& raw_string)
				{
					using namespace manager::headpart;
					if (raw_string.size() == 1) {
						auto flag = raw_string[0];
						if (head_parts_flag_map_without_none.count(flag) > 0) {
							return head_parts_flag_map_without_none[flag];
						}
					}
					if (!raw_string.empty()) {
						logs::warn("\t\t\tInvalid flag: {}, head part flag invalid", raw_string);
					}
					return manager::RaceFlag::kNone;
				}
			}

			namespace apply
			{
				static inline std::set<RE::TESRace*> MakeProxyRaces(
					const decltype(ConfigData::proxy_races)& proxy_races,
					const lookup::form::race_lookup_table_t& table)
				{
					std::set<RE::TESRace*> result;
					for (const auto& proxy_race_ptr : proxy_races) {
						if (auto proxy_race = table.at(proxy_race_ptr); proxy_race != nullptr) {
							result.emplace(proxy_race);
						}
					}
					return result;
				}
			}

			static inline void AddDefaultVampirismRacePairs(
				raw_configs_t&      raw_configs,
				cache::key_cache_t& key_cache)
			{
				auto&& rcs_key = cache::GetCachedEntryKey(rcs::CONFIG_KEY, key_cache);
				raw_configs.emplace_back(
					std::make_shared<std::string>("Default"),
					entries_t{
						{ rcs_key, std::make_shared<std::string>("ArgonianRace|ArgonianRaceVampire") },
						{ rcs_key, std::make_shared<std::string>("BretonRace|BretonRaceVampire") },
						{ rcs_key, std::make_shared<std::string>("DarkElfRace|DarkElfRaceVampire") },
						{ rcs_key, std::make_shared<std::string>("HighElfRace|HighElfRaceVampire") },
						{ rcs_key, std::make_shared<std::string>("ImperialRace|ImperialRaceVampire") },
						{ rcs_key, std::make_shared<std::string>("KhajiitRace|KhajiitRaceVampire") },
						{ rcs_key, std::make_shared<std::string>("NordRace|NordRaceVampire") },
						{ rcs_key, std::make_shared<std::string>("OrcRace|OrcRaceVampire") },
						{ rcs_key, std::make_shared<std::string>("RedguardRace|RedguardRaceVampire") },
						{ rcs_key, std::make_shared<std::string>("WoodElfRace|WoodElfRaceVampire") } });
			}

			static inline void ReadAndFormatConfigs(
				const std::vector<std::string>& files,
				raw_configs_t&                  raw_configs,
				cache::key_cache_t&             key_cache)
			{
				raw_configs.reserve(files.size() + 1);
				for (const auto& path : files) {
					logs::info("\tINI : {}", path);

					CSimpleIni ini;
					ini.SetUnicode();
					ini.SetMultiKey();

					if (const auto rc = ini.LoadFile(path.c_str()); rc < 0) {
						logs::error("\tcouldn't read INI");
						continue;
					}

					if (auto values = ini.GetSection(""); values != nullptr && !values->empty()) {
						using ini_value_t = std::multimap<CSimpleIniA::Entry,
							// only the formatting requires entry ref, hence it's unique
							// however, the sanitized_entry can be utilized in both old_format_map and entries
							// therefore it should be shared
							std::pair<std::unique_ptr<std::string>, std::shared_ptr<std::string>>,
							CSimpleIniA::Entry::LoadOrder>;
						ini_value_t old_format_map{};

						auto& [_, entries] = raw_configs.emplace_back(
							// strip "Data\\"
							std::make_shared<std::string>(path.substr(5)), 0);
						entries.reserve(values->size());

						// sanitize and format entries
						for (auto&& [key, entry] : *values) {
							auto santinized_entry = std::make_shared<std::string>(detail::utility::Sanitize(entry));
							entries.emplace_back(cache::GetCachedEntryKey(key.pItem, key_cache), santinized_entry);

							if (*santinized_entry != entry) {
								old_format_map.emplace(key,
									// here the shared_ptr of santinized_entry is copied
									std::make_pair(std::make_unique<std::string>(entry), santinized_entry));
							}
						}

						// formatting config files
						if (!old_format_map.empty()) {
							logs::info("\tsanitizing {} entries", old_format_map.size());

							for (auto&& [key, entry] : old_format_map) {
								auto&& [original, sanitized] = entry;
								ini.DeleteValue("", key.pItem, original->c_str());
								ini.SetValue("", key.pItem, sanitized->c_str(), key.pComment, false);
							}
						}
					}
				}
			}

			static inline void ParseConfigData(
				const raw_configs_t&               raw_configs,
				parsed_configs_t&                  parsed_configs,
				lookup::form::race_lookup_table_t& table)
			{
				record_cache_t record_cache;
				auto           cache = std::make_pair(std::ref(record_cache), std::ref(table));

				// reserve space for parsed_configs according to size of raw_configs
				parsed_configs.reserve(raw_configs.size());
				for (const auto& [path, entries] : raw_configs) {
					logs::info("\tParsing configs in {}", *path);
					// initialize config data in one file
					auto& [_, config_entries] = parsed_configs.emplace_back(path, 0);
					config_entries.reserve(entries.size());

					for (const auto& [key, value] : entries) {
						logs::info("\t\t{}={}", *key, *value);
						if (*key != rcs::CONFIG_KEY) {
							logs::warn("\t\t\tKey illegal");
							continue;
						}

						// get raw sections through splitting by '|'
						auto       raw_sections = clib_util::string::split(*value, "|");
						const auto section_size = raw_sections.size();
						if (section_size < SECTION_MIN_SIZE ||
							section_size > SECTION_MAX_SIZE) {
							logs::warn("\t\t\tInvalid entry, too many or too few sections");
							continue;
						}

						// padding empty sections
						if (section_size < SECTION_MAX_SIZE) {
							raw_sections.reserve(SECTION_MAX_SIZE);
							for (auto i = 0; i < SECTION_MAX_SIZE - section_size; ++i) {
								raw_sections.emplace_back(""sv);
							}
						}

						// parsing sections
						// race and vampire_race
						auto [is_race_valid, race_record_type] = utility::IsRawStringValidRecord(raw_sections[0]);
						auto [is_vampire_race_valid, vampire_race_record_type] = utility::IsRawStringValidRecord(raw_sections[1]);
						if (!is_race_valid || !is_vampire_race_valid ||
							race_record_type == clib_util::distribution::record_type::kMod ||
							vampire_race_record_type == clib_util::distribution::record_type::kMod) {
							logs::warn("\t\t\tInvalid config entry, form of race or vampire race invalid or is a mod name");
							continue;
						}
						// create new data
						auto& data = config_entries.emplace_back();
						data.race = cache::GetCachedRecord(raw_sections[0], cache, race_record_type);
						data.vampire_race = cache::GetCachedRecord(raw_sections[1], cache, vampire_race_record_type);
						// proxy_races
						parse::ParseProxyRaces(raw_sections[2], data.proxy_races, cache);
						// proxy_vampire_races
						parse::ParseProxyRaces(raw_sections[3], data.proxy_vampire_races, cache);
						// head_part_flag
						data.head_part_flag = parse::ParseHeadPartFlag(raw_sections[4]);
					}
				}
			}

			static inline void ApplyManagerConfig(
				const parsed_configs_t&                  parsed_configs,
				const lookup::form::race_lookup_table_t& table,
				manager::headpart::HeadPartFormIdLists&  lists)
			{
				apply::uasage_map_t usage_map;

				if (!(lists.is_initialized)) {
					logs::warn("FormId lists not initilized, ignoring head part flags");
				}

				// reverse iterate for config file override support, the last file will override the previous one
				for (const auto& [path, entries] : parsed_configs | std::views::reverse) {
					logs::info("\tApplying configs in {}", *path);
					// reverse iterate for config entry override support, the last entry will override the previous one
					for (const auto& data : entries | std::views::reverse) {
						logs::info("\t\t{}|{}",
							utility::RecordToString(*(data.race)),
							utility::RecordToString(*(data.vampire_race)));

						// the record_ptr will always be in table for how the record_ptr is created
						auto race = table.at(data.race);
						auto vampire_race = table.at(data.vampire_race);
						// validation
						if (race == nullptr || vampire_race == nullptr) {
							logs::warn("\t\t\tUnable to find race or vampire race");
							continue;
						} else if (race == vampire_race) {
							logs::warn("\t\t\tRace and vampire race must not be the same");
							continue;
						} else if (usage_map.contains(race)) {
							logs::warn("\t\t\tRace overrided by configs in {}", *(usage_map.at(race)));
							continue;
						} else if (usage_map.contains(vampire_race)) {
							logs::warn("\t\t\tVampire race overrided by configs in {}", *(usage_map.at(vampire_race)));
							continue;
						}

						// vampirism
						manager::vampirism::EmplaceVampirismRacePair(race, vampire_race);
						// compatibility
						manager::compatibility::EmplaceProxyRaces(race, apply::MakeProxyRaces(data.proxy_races, table));
						manager::compatibility::EmplaceProxyRaces(vampire_race, apply::MakeProxyRaces(data.proxy_vampire_races, table));
						// headparts
						if (lists.is_initialized) {
							lists.AddRace(race, vampire_race, data.head_part_flag);
						}

						// mark race and vampire race as used
						usage_map.emplace(race, path);
						usage_map.emplace(vampire_race, path);
					}
				}
			}
		}

		// TODO whether vampire_race must has keyword "Vampire"?
		bool TryReadAndApplyConfigs()
		{
			using namespace detail;
			parsed_configs_t                  parsed_configs;
			lookup::form::race_lookup_table_t table;
			{
				raw_configs_t raw_configs;
				{
					cache::key_cache_t key_cache;
					AddDefaultVampirismRacePairs(raw_configs, key_cache);
					auto files = clib_util::distribution::get_configs(R"(Data\)", "_RCS"sv);
					if (files.empty()) {
						logs::warn("No .ini files with _RCS suffix within the Data folder");
					} else {
						logs::info("Reading configs");
						ReadAndFormatConfigs(files, raw_configs, key_cache);
					}
				}
				logs::info("Parsing configs");
				ParseConfigData(raw_configs, parsed_configs, table);
			}

			if (!lookup::form::LookupRaces(table)) {
				logs::critical("Failed to get TESDataHandler, unable to lookup forms, aborting...");
				return false;
			}
			logs::info("Applying configs");
			{
				manager::headpart::HeadPartFormIdLists lists;
				lists.Initialize();
				ApplyManagerConfig(parsed_configs, table, lists);
				// summary
				manager::headpart::Summary(lists);
			}
			manager::vampirism::Summary();
			// if not proxy race, then no need for the hook
			return manager::compatibility::Summary();
		}
	}  // namespace ini
}  // namespace race_compatibility
