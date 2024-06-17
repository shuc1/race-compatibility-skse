#include "configs.h"
#include "race_manager.h"

namespace race_compatibility
{
	namespace ini
	{
		namespace detail
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
							auto santinized_entry = std::make_shared<std::string>(detail::Sanitize(entry));
							entries.emplace_back(std::make_unique<std::string>(std::string(key.pItem)), santinized_entry); // TODO 验证shared_ptr是否得到了释放

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
		}

		bool ParseConfigs(const std::vector<std::string>& files)
		{
			// if should print errors to console
			if (files.empty()) {
				return false;
			}
			configs_t raw_configs{};
			raw_configs.reserve(9);  // reserve 9 config files for now
			logs::info("Reading configs");
			detail::ReadAndFormatConfigs(files, raw_configs);
			manager::ini::TryParse(raw_configs);
			return true;
		}
	}  // namespace ini
}
