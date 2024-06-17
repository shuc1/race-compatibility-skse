#include "configs.h"
#include "race_manager.h"

namespace race_compatibility
{
	namespace ini
	{
		namespace detail
		{
			using path_t = std::shared_ptr<std::string>;
			using entry_t = std::vector<std::pair<std::unique_ptr<std::string>, std::shared_ptr<std::string>>>;  // key-value
			using configs_t = std::vector<std::pair<path_t, entry_t>>;
			constexpr auto SECTION_MIN_SIZE = 2;
			constexpr auto SECTION_MAX_SIZE = 5;

			using record_ptr_t = std::shared_ptr<record_t>;
			using record_cache_t = std::map<std::string, record_ptr_t>;

			enum class HeadPartFlag : char
			{
				kNone = 0,
				kHuman = 'H',
				kBeast = 'B',
				kElf = 'E',
				kOrc = 'O'
			};

			static std::map<char, HeadPartFlag> head_part_flag_map = {
				{ std::to_underlying(HeadPartFlag::kHuman), HeadPartFlag::kHuman },
				{ std::to_underlying(HeadPartFlag::kBeast), HeadPartFlag::kBeast },
				{ std::to_underlying(HeadPartFlag::kElf), HeadPartFlag::kElf },
				{ std::to_underlying(HeadPartFlag::kOrc), HeadPartFlag::kOrc }
			};

			struct ConfigData
			{
				record_ptr_t              race{};
				record_ptr_t              vampire_race{};
				std::vector<record_ptr_t> proxy_races{};
				std::vector<record_ptr_t> proxy_vampire_races{};
				HeadPartFlag              head_part_flag{ HeadPartFlag::kNone };
			};

			namespace str
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
			}

			namespace parse
			{

				// path-configdata
				using parsed_entry_t = std::vector<ConfigData>;
				using parsed_config_t = std::pair<std::shared_ptr<std::string>, parsed_entry_t>;
				using parsed_configs_t = std::vector<parsed_config_t>;
				using parse_cache_t = std::pair<record_cache_t&, lookup::form::lookup_table_t&>;

				static inline record_ptr_t GetCachedRecord(const std::string& raw_str, parse_cache_t& cache)
				{
					auto& [record_cache, table] = cache;
					if (!record_cache.contains(raw_str)) {
						// must success
						auto [it, _] = record_cache.emplace(raw_str,
							std::make_shared<record_t>(clib_util::distribution::get_record(raw_str)));
						table.emplace(it->second, nullptr);
					}
					return record_cache.at(raw_str);
				}

				static inline void ParseProxyRaces(const std::string& raw_string, const char* error_message,
					decltype(ConfigData::proxy_races)& races, parse_cache_t& cache)
				{
					using namespace clib_util::distribution;
					auto form_strings = split_entry(raw_string, ",");
					if (auto size = form_strings.size(); size > 0) {
						races.reserve(size);
						for (const auto& str : form_strings) {
							if (is_valid_entry(str)) {
								races.emplace_back(GetCachedRecord(str, cache));
							} else {
								logs::warn("\t\t\t Invalid form: {}, {}", str, error_message);
							}
						}
					}
				}

				static inline HeadPartFlag ParseHeadPartFlag(const std::string& raw_string)
				{
					if (raw_string.size() == 1) {
						auto flag = raw_string[0];
						if (head_part_flag_map.count(flag) > 0) {
							return head_part_flag_map[flag];
						}
					}
					if (!raw_string.empty()) {
						logs::warn("\t\t\t Invalid flag: {}, head part flag invalid", raw_string);
					}
					return HeadPartFlag::kNone;
				}
			}

			namespace apply
			{
				static inline void TryEmplaceProxyRaces(RE::TESRace* race, const decltype(ConfigData::proxy_races)& proxy_races,
					const lookup::form::lookup_table_t& table)
				{
					// even if race is null, contains(nullptr)
					// the record_ptr will always be in table for how the record_ptr is created
					// but it could be nullptr
					using namespace rcs::manager::compatibility;
					if (proxy_races.size() == 0 ||
						// race already in the compatibility map
						// according to the override rule, ignore this config
						race_map.contains(race)) {
						return;
					}

					auto [it, _] = race_map.emplace(race, std::set<RE::TESRace*>{});
					for (const auto& proxy_race_ptr : proxy_races) {
						if (auto& proxy_race = table.at(proxy_race_ptr); proxy_race != nullptr) {
							it->second.emplace(proxy_race);
						}
					}
				}
			}

			static inline void ReadAndFormatConfigs(const std::vector<std::string>& files, configs_t& raw_configs)
			{
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
							// only the formatting requires an entry, hence it's unique
							// however, the sanitized_entry can be utilized in both old_format_map and entries
							// therefore it should be shared
							std::pair<std::unique_ptr<std::string>, std::shared_ptr<std::string>>,
							CSimpleIniA::Entry::LoadOrder>;
						ini_value_t old_format_map{};

						// strip "Data\\"
						auto& [_, entries] = raw_configs.emplace_back(std::make_shared<std::string>(path.substr(5)), 0);
						entries.reserve(9);  // TODO is 9 reasonable?

						for (auto&& [key, entry] : *values) {
							auto santinized_entry = std::make_shared<std::string>(detail::str::Sanitize(entry));
							entries.emplace_back(std::make_unique<std::string>(std::string(key.pItem)), santinized_entry);  // TODO 验证shared_ptr是否得到了释放

							if (*santinized_entry != entry) {
								old_format_map.emplace(key,
									std::make_pair(std::make_unique<std::string>(entry), santinized_entry));  // here the shared_ptr of santinized_entry is copied
							}
							//try {
							//} catch (...) {
							//	logs::warn("\t\tFailed to parse entry [{} = {}]"sv, key.pItem, entry);
							//	RE::ConsoleLog::GetSingleton()->Print(
							//		"[RCS] Errors found when reading configs. Check {}.log in {} for more info\n",
							//		RcsVersions::PROJECT,
							//		SKSE::log::log_directory()->c_str());
							//}
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

			static inline void ParseConfigData(const configs_t& raw_configs,
				parse::parsed_configs_t& parsed_configs, lookup::form::lookup_table_t& table)
			{
				record_cache_t record_cache;
				auto           cache = std::make_pair(std::ref(record_cache), std::ref(table));

				for (const auto& [path, entries] : raw_configs) {
					logs::info("\tParsing configs in {}", *path);
					// initialize config data in one file
					auto& [_, config_entries] = parsed_configs.emplace_back(path, 0);
					config_entries.reserve(entries.size());

					for (const auto& [key, value] : entries) {
						logs::info("\t\t{}={}", *key, *value);
						if (*key != rcs::CONFIG_KEY) {
							logs::warn("\t\t Key illegal");
							continue;
						}

						// get raw sections through splitting by '|'
						auto       raw_sections = clib_util::string::split(*value, "|");
						const auto section_size = raw_sections.size();
						if (section_size < SECTION_MIN_SIZE ||
							section_size > SECTION_MAX_SIZE) {
							logs::warn("\t\t Invalid entry, too many or too few sections");
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
						if (!clib_util::distribution::is_valid_entry(raw_sections[0]) ||
							!clib_util::distribution::is_valid_entry(raw_sections[1])) {
							logs::warn("\t\t Invalid config entry, form of race or vampire race invalid");
							continue;
						}
						// create new data
						auto& data = config_entries.emplace_back();
						data.race = parse::GetCachedRecord(raw_sections[0], cache);
						data.vampire_race = parse::GetCachedRecord(raw_sections[1], cache);
						// proxy_races
						parse::ParseProxyRaces(raw_sections[2], "forms in proxy races invalid",
							data.proxy_races, cache);
						// proxy_vampire_races
						parse::ParseProxyRaces(raw_sections[3], "forms in proxy vampire races invalid",
							data.proxy_vampire_races, cache);
						// head_part_flag
						data.head_part_flag = parse::ParseHeadPartFlag(raw_sections[4]);
					}
				}
			}

			static inline void ApplyManagerConfig(
				const parse::parsed_configs_t&      parsed_configs,
				const lookup::form::lookup_table_t& table)
			{
				// reverse iterate for override support
				for (const auto& [path, entries] : parsed_configs | std::views::reverse) {
					logs::info("\tApplying configs in {}", *path);
					for (const auto& data : entries) {
						// the record_ptr will always be in table for how the record_ptr is created
						auto race = table.at(data.race);
						auto vampire_race = table.at(data.vampire_race);
						if (race == nullptr || vampire_race == nullptr) {
							logs::warn("\t\t Unable to find race or vampire race");
							continue;
						}

						// vampirism
						// TODO: 吸血鬼种族与普通种族必须一一对应

						// compatibility
						apply::TryEmplaceProxyRaces(race, data.proxy_races, table);
						apply::TryEmplaceProxyRaces(vampire_race, data.proxy_vampire_races, table);
					}
				}
			}
		}

		bool TryReadAndApplyConfigs()
		{
			using namespace detail;
			parse::parsed_configs_t      parsed_configs;
			lookup::form::lookup_table_t table;
			{
				configs_t raw_configs{};
				{
					auto files = clib_util::distribution::get_configs(R"(Data\)", "_RCS"sv);
					if (files.empty()) {
						logs::warn("No .ini files with _RCS suffix within the Data folder, aborting...");
						return false;
					}

					raw_configs.reserve(9);  // reserve 9 config files for now
					logs::info("Reading configs");
					ReadAndFormatConfigs(files, raw_configs);
				}
				logs::info("Parsing configs");
				ParseConfigData(raw_configs, parsed_configs, table);
			}
			if (!lookup::form::LookupRaces(table)) {
				logs::warn("Failed to get TESDataHandler, unable to lookup forms, aborting...");
				return false;
			}
			logs::info("Applying configs");
			ApplyManagerConfig(parsed_configs, table);
			return true;
		}
	}  // namespace ini
}
