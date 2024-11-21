#include "configs.h"
#include "forms.h"
#include <memory>

namespace race_compatibility
{
	namespace ini
	{
		namespace detail
		{
			constexpr auto SECTION_MIN_SIZE = 2;
			constexpr auto SECTION_MAX_SIZE = 5;

			//// TODO very ugly, should be refactored

			// <rcs key, raw string>
			using raw_entries_t = std::vector<std::pair<std::string_view, std::string>>;
			// <path, entry>
			using raw_configs_t = std::vector<std::pair<std::string, raw_entries_t>>;

			using record_ptr_t = std::shared_ptr<record>;
			using record_cache_t = std::map<std::string, record_ptr_t>;

			struct ConfigEntry
			{
				record_ptr_t              race{};
				record_ptr_t              vampire_race{};
				std::vector<record_ptr_t> proxy_races{};
				std::vector<record_ptr_t> proxy_vampire_races{};
				manager::RaceFlag         head_part_flag{ 0 };
			};

			// path-config data
			using parsed_entry_t = std::vector<ConfigEntry>;
			// <path, config data>
			// TODO there is at least twice string copy for "path", reduce it
			using parsed_config_t = std::pair<std::string, parsed_entry_t>;
			using parsed_configs_t = std::vector<parsed_config_t>;

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

				static inline std::string RecordToString(const record& r)
				{
					return std::visit([](auto&& arg) -> std::string {
						using T = std::decay_t<decltype(arg)>;
						if constexpr (std::is_same_v<T, formid_pair>) {
							return std::format("0x{:X}~{}", arg.first.value(), arg.second.value_or(""));
						} else if constexpr (std::is_same_v<T, std::string>) {
							return arg;
						}
					},
						r);
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
				using parse_cache_t = std::pair<record_cache_t&, lookup::form::race_lookup_table_t&>;

				/// <param name="a_record_type">must NOT be kMod</param>
				static inline record_ptr_t GetCachedRecord(
					const std::string&                         raw_str,
					parse_cache_t&                             cache,
					const clib_util::distribution::record_type a_record_type = clib_util::distribution::record_type::kNone)
				{
					auto& [record_cache, table] = cache;

					if (!record_cache.contains(raw_str)) {
						using namespace clib_util::distribution;
						auto&& r = get_record(a_record_type == record_type::kNone ? get_record_type(raw_str) : a_record_type, raw_str);

						// must success, ignore the bool returnval
						const auto it = record_cache.emplace(raw_str,
														std::make_shared<record>(r))
						                    .first;
						table.emplace(it->second, nullptr);
					}
					return record_cache.at(raw_str);
				}
			}

			namespace parse
			{
				static inline void ParseProxyRaces(const std::string& raw_string,
					decltype(ConfigEntry::proxy_races)& races, cache::parse_cache_t& cache)
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
						if (valid_flags.count(flag) > 0) {
							return manager::RaceFlag(flag);
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
				// will be used locally, so string_view is fine
				using visited_map_t = std::map<RE::TESRace*, std::string_view>;

				static inline std::set<RE::TESRace*> MakeProxyRaces(
					const decltype(ConfigEntry::proxy_races)& proxy_races,
					const lookup::form::race_lookup_table_t&  table)
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

			static inline raw_configs_t GetVanillaGameRawConfigs()
			{
				return raw_configs_t{
					{ "Default",
						raw_entries_t{
#define RCS_DEFAULT_ENTRY_PAIR(value) { rcs::CONFIG_KEY, value }
							RCS_DEFAULT_ENTRY_PAIR("ArgonianRace|ArgonianRaceVampire"),
							RCS_DEFAULT_ENTRY_PAIR("BretonRace|BretonRaceVampire"),
							RCS_DEFAULT_ENTRY_PAIR("DarkElfRace|DarkElfRaceVampire"),
							RCS_DEFAULT_ENTRY_PAIR("HighElfRace|HighElfRaceVampire"),
							RCS_DEFAULT_ENTRY_PAIR("ImperialRace|ImperialRaceVampire"),
							RCS_DEFAULT_ENTRY_PAIR("KhajiitRace|KhajiitRaceVampire"),
							RCS_DEFAULT_ENTRY_PAIR("NordRace|NordRaceVampire"),
							RCS_DEFAULT_ENTRY_PAIR("OrcRace|OrcRaceVampire"),
							RCS_DEFAULT_ENTRY_PAIR("RedguardRace|RedguardRaceVampire"),
							RCS_DEFAULT_ENTRY_PAIR("WoodElfRace|WoodElfRaceVampire"),
#undef RCS_DEFAULT_ENTRY_PAIR
						} }
				};
			}

			static inline void ReadAndFormatConfigs(
				const std::vector<std::string>& files,
				raw_configs_t&                  raw_configs)
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

					// strip "Data\\"
					if (auto values = ini.GetSection(""); values != nullptr && !values->empty()) {
						auto& entries = raw_configs.emplace_back(path.substr(5), 0).second;
						entries.reserve(values->size());

						// sanitize and format entries
						for (auto&& [key, entry] : *values) {
							if (auto key_str = key.pItem; key_str != rcs::CONFIG_KEY) {
								logs::warn("\t\t\tKey illegal: {}", key_str);
								continue;
							}
							auto& santinized_entry = entries.emplace_back(
																rcs::CONFIG_KEY,
																detail::utility::Sanitize(entry))
							                             .second;
							// formatting old configs when need
							if (entry != santinized_entry) {
								ini.DeleteValue("", key.pItem, entry);
								ini.SetValue("", key.pItem, santinized_entry.c_str(), key.pComment, false);
							}
						}
					}
				}
			}

			static inline parsed_configs_t ParseConfigData(
				const raw_configs_t&               raw_configs,
				lookup::form::race_lookup_table_t& table)
			{
				record_cache_t   record_cache;
				parsed_configs_t parsed_configs;
				auto             cache = std::make_pair(std::ref(record_cache), std::ref(table));
				// reserve space for parsed_configs according to size of raw_configs
				parsed_configs.reserve(raw_configs.size());
				for (const auto& [path, entries] : raw_configs) {
					logs::info("\tParsing configs in {}", path);
					// initialize config data in one file
					auto& config_entries = parsed_configs.emplace_back(path, 0).second;
					config_entries.reserve(entries.size());

					for (const auto& [key, value] : entries) {
						logs::info("\t\t{}={}", key, value);
						//// according to the principle of high cohension
						//// this will be a good practice, but will consume more time and space
						//if (key != rcs::CONFIG_KEY) {
						//	logs::warn("\t\t\tKey illegal");
						//	continue;
						//}

						// get raw sections through splitting by '|'
						auto       raw_sections = clib_util::string::split(value, "|");
						const auto section_size = raw_sections.size();
						if (section_size < SECTION_MIN_SIZE ||
							section_size > SECTION_MAX_SIZE) {
							logs::warn("\t\t\tInvalid entry, too many or too few sections");
							continue;
						}

						// padding empty sections
						if (section_size < SECTION_MAX_SIZE) {
							raw_sections.reserve(SECTION_MAX_SIZE);
							for (size_t i = 0; i < SECTION_MAX_SIZE - section_size; ++i) {
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
				return parsed_configs;
			}

			static inline void ApplyManagerConfig(
				const parsed_configs_t&                  parsed_configs,
				const lookup::form::race_lookup_table_t& table,
				manager::headpart::HeadPartFormIdLists&  lists)
			{
				apply::visited_map_t visited;

				if (!(lists.is_initialized)) {
					logs::warn("FormId lists not initilized, ignoring head part flags");
				}

				// reverse iterate for config file override support, the last file will override the previous one
				for (const auto& [path, entries] : parsed_configs | std::views::reverse) {
					logs::info("\tApplying configs in {}", path);
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
						} else if (visited.contains(race)) {
							logs::warn("\t\t\tRace overrided by configs in {}", visited.at(race));
							continue;
						} else if (visited.contains(vampire_race)) {
							logs::warn("\t\t\tVampire race overrided by configs in {}", visited.at(vampire_race));
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
						if (data.head_part_flag != manager::RaceFlag::kNone) {
							// add to headpart flag map
							manager::headpart::race_headpart_map.emplace(race, data.head_part_flag);
							manager::headpart::race_headpart_map.emplace(vampire_race, data.head_part_flag);
						}

						// mark race and vampire race as used
						visited.emplace(race, path);
						visited.emplace(vampire_race, path);
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
				auto raw_configs = GetVanillaGameRawConfigs();

				// TODO check if there is a better way to handle the case of no configs (add an empty stub dir)
				if (!std::filesystem::exists(rcs::CONFIG_DIR)) {
					logs::warn("No {} folder found", rcs::CONFIG_DIR);
				} else {
					auto files = clib_util::distribution::get_configs(rcs::CONFIG_DIR, "_RCS"sv);
					if (files.empty()) {
						// there will be default configs, so no need to return false
						logs::warn("No .ini files with _RCS suffix within the {} folder", rcs::CONFIG_DIR);
					} else {
						logs::info("Reading configs");
					}
					ReadAndFormatConfigs(files, raw_configs);
				}

				logs::info("Parsing configs");
				parsed_configs = ParseConfigData(raw_configs, table);
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
			// if no proxy race, then no need for the hook
			return manager::compatibility::Summary();
		}
	}  // namespace ini
}  // namespace race_compatibility
