#include "Configs.h"
#include "Forms.h"

namespace rcs::config
{
	namespace
	{
		auto CollectConfigFilenamesFromFolder(const std::string_view folder)
			-> std::vector<std::string>
		{
			std::vector<std::string> files{};
			if (!std::filesystem::exists(folder)) {
				logs::warn("Folder {} does not exist", folder);
				return files;
			}
			files.reserve(4);  // there should not be that many config files
			for (const auto& entry : std::filesystem::directory_iterator(folder)) {
				if (entry.is_regular_file() && entry.path().extension() == ".json"sv) {
					files.emplace_back(entry.path().filename().string());
				}
			}
			std::ranges::sort(files);
			return files;
		}

		using RaceFormCache = form::FormCache<RE::TESRace>;

		auto LookupRace(std::string_view form_str, RaceFormCache& cache)
			-> RE::TESRace*
		{
			//auto* race = form::LookupCachedForm(form_str, cache);
			// if (!race) {
			// 	logs::warn("\t\tInvalid race form: {}"sv, form_str);
			// }
			return form_str.empty() ? nullptr : form::LookupCachedForm(form_str, cache);
		}

		auto ParseArmorProxy(const RawConfigEntry::RaceProxy::ArmorProxy& armor_proxy, RaceFormCache& form_cache)
			-> ConfigEntry::RaceProxy::ArmorProxy
		{
			using BipedObjectSlot = RE::BGSBipedObjectForm::BipedObjectSlot;
			using ArmorVariant = ConfigEntry::ArmorVariant;

			ConfigEntry::RaceProxy::ArmorProxy result{
				.race = armor_proxy.race.empty() ? nullptr : LookupRace(armor_proxy.race, form_cache),
				.variants = std::vector<ArmorVariant>(armor_proxy.variants.size())
			};
			if (!armor_proxy.variants.empty()) {
				size_t i = 0;
				for (const auto& [slots, proxy] : armor_proxy.variants) {
					auto* race = LookupRace(proxy, form_cache);
					if (!race || slots.empty()) {
						continue;
					}
					auto slotSet = REX::EnumSet<BipedObjectSlot, std::uint32_t>{};
					for (const auto& slot :
						slots | std::views::filter([](const auto& s) { return s >= 30 && s <= 61; })) {
						slotSet.set(static_cast<BipedObjectSlot>(1 << (slot - 30)));
					}
					if (slotSet.underlying()) {
						result.variants[i] = {
							.proxy = race,
							.slotMask = slotSet.get()
						};
						i++;
					}
				}
			}
			return result;
		}

		auto ParseRaceProxy(const RawConfigEntry::RaceProxy& proxy_config, RaceFormCache& form_cache)
			-> ConfigEntry::RaceProxy
		{
			ConfigEntry::RaceProxy result{
				.form = LookupRace(proxy_config.form, form_cache),
				.proxies = std::set<const RE::TESRace*>{},
				.armor = ParseArmorProxy(proxy_config.armor, form_cache)
			};

			for (const auto& proxy : proxy_config.proxies) {
				if (const auto* race = LookupRace(proxy, form_cache)) {
					result.proxies.insert(race);
				}
			}

			return result;
		}

		void ApplyRaceProxy(ConfigEntry::RaceProxy& race_proxy)
		{
			// apply condition race proxies
			manager::EmplaceRaceProxies(race_proxy.form, std::move(race_proxy.proxies));
			// set armorParentRace
			if (auto* armor_race = race_proxy.armor.race) {
				race_proxy.form->armorParentRace = armor_race;
			}
			// set armorParentRace for specific slot masks
			manager::EmplaceArmorRaceProxies(race_proxy.form, std::move(race_proxy.armor.variants));
		}

		void ApplyConfigEntry(ConfigEntry& config, manager::headpart::HeadPartFormIdListAdder& adder)
		{
			auto *race = config.race.form, *race_vamp = config.vampireRace.form;

			// condition & armor related
			ApplyRaceProxy(config.race);
			if (race_vamp) {
				ApplyRaceProxy(config.vampireRace);
				// vampirism related
				manager::EmplaceVampirismRacePair(race, race_vamp);
			}
			// head part related, due to RE::BGSListForm::AddForm, race cannot be const
			adder.AddRace(race, race_vamp, config.headPart);
		}

		struct ParseCache
		{
			manager::headpart::HeadPartFormIdListAdder     adder;
			RaceFormCache                                  form_cache{};
			std::vector<std::string>                       applied_entry_info{};
			std::map<const RE::TESRace*, std::string_view> visited_map{};
		};

		void ParseAndApplyRawConfig(
			const std::string_view             filename,
			const std::vector<RawConfigEntry>& raw_config_data,
			ParseCache&                        cache)
		{
			for (const auto& raw_config : raw_config_data | std::views::reverse) {
				logs::info("\t{}: {}, {}"sv,
					raw_config.name, raw_config.race.form,
					raw_config.vampireRace.form.empty() ? "N/A"sv : raw_config.vampireRace.form);

				auto config = ConfigEntry{
					.race = ParseRaceProxy(raw_config.race, cache.form_cache),
					.vampireRace = ParseRaceProxy(raw_config.vampireRace, cache.form_cache),
					.headPart = manager::headpart::StringToHeadPartType(raw_config.headPart)
				};

				const auto *race = config.race.form, *race_vamp = config.vampireRace.form;
				if (!race) {
					logs::warn("\t\t[SKIP] Invalid race"sv);
					continue;
				}
				if (auto it_race = cache.visited_map.find(race);
					it_race != cache.visited_map.end()) {
					logs::warn("\t\t[SKIP] Race already used in {}"sv, it_race->second);
					continue;
				}
				if (race_vamp) {
					if (auto it_race_vamp = cache.visited_map.find(race_vamp);
						it_race_vamp != cache.visited_map.end()) {
						logs::warn("\t\t[SKIP] Vampire race already used in {}"sv, it_race_vamp->second);
						continue;
					}
				}

				// race are guaranteed to be valid at this point, but vampireRace can be empty
				ApplyConfigEntry(config, cache.adder);

				// add to visited map
				auto info = std::string_view(
					cache.applied_entry_info.emplace_back(std::format("{}:{}"sv, filename, raw_config.name)));
				cache.visited_map.emplace(race, info);
				if (race_vamp) {
					cache.visited_map.emplace(race_vamp, info);
				}
			}
		}

		bool LoadConfigs(std::vector<std::string>& files)
		{
			auto parse_cache = ParseCache{};
			if (!parse_cache.adder.IsInitialized()) {
				logs::error("HeadPartFormIdListAdder is not initialized"sv);
				return false;
			}

			for (const auto& filename : files | std::views::reverse) {
				logs::info("{}:", filename);

				// Read Configs From File
				auto buffer = glz::file_to_buffer(std::format("{}\\{}"sv, rcs::CONFIG_DIR, filename));
				auto content = glz::read_json<RawConfigFileContent>(buffer);
				if (!content) {
					logs::error("Failed to read file for \"{}\"", glz::format_error(content));
					continue;
				}

				// Parse And Apply Raw Configs
				ParseAndApplyRawConfig(filename, content.value().entries, parse_cache);
			}

#define RCS_DEFAULT_RACE_RAW_ENTRY(a_name)                   \
	RawConfigEntry                                           \
	{                                                        \
		.name = #a_name,                                     \
		.race = RawConfigEntry::RaceProxy{                   \
			.form = std::string_view(#a_name "Race"),        \
		},                                                   \
		.vampireRace = RawConfigEntry::RaceProxy             \
		{                                                    \
			.form = std::string_view(#a_name "RaceVampire"), \
		}                                                    \
	}
			// from vanilla game
			logs::info("default:");
			ParseAndApplyRawConfig(
				"default",
				{
					RCS_DEFAULT_RACE_RAW_ENTRY(Argonian),
					RCS_DEFAULT_RACE_RAW_ENTRY(Breton),
					RCS_DEFAULT_RACE_RAW_ENTRY(DarkElf),
					RCS_DEFAULT_RACE_RAW_ENTRY(HighElf),
					RCS_DEFAULT_RACE_RAW_ENTRY(Imperial),
					RCS_DEFAULT_RACE_RAW_ENTRY(Khajiit),
					RCS_DEFAULT_RACE_RAW_ENTRY(Nord),
					RCS_DEFAULT_RACE_RAW_ENTRY(Orc),
					RCS_DEFAULT_RACE_RAW_ENTRY(Redguard),
					RCS_DEFAULT_RACE_RAW_ENTRY(WoodElf),
				},
				parse_cache);
#undef RCS_DEFAULT_RACE_RAW_ENTRY

			// summary
			manager::Summary();
			return true;
		}
	}  // anonymous namespace

	bool TryReadAndApplyConfigs()
	{
		logs::info("{:*^30}", "CONFIGS");
		if (!RE::TESDataHandler::GetSingleton()) {
			logs::error("TESDataHandler is not initialized"sv);
			return false;
		}
		auto files = CollectConfigFilenamesFromFolder(rcs::CONFIG_DIR);
		if (files.empty()) {
			logs::warn("No config files found in {}"sv, rcs::CONFIG_DIR);
		}
		return LoadConfigs(files);
	}
}  // namespace rcs::config