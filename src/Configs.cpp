#include "Configs.h"
#include "Forms.h"

#include <glaze/glaze.hpp>

namespace rcs
{
	namespace config
	{
		namespace detail
		{
			std::vector<std::string> CollectConfigFilesFromFolder(const std::string_view folder)
			{
				std::vector<std::string> files{};
				if (!std::filesystem::exists(folder)) {
					logs::warn("Folder {} does not exist", folder);
					return files;
				}
				files.reserve(4);  // there should not be that many config files
				for (const auto& entry : std::filesystem::directory_iterator(folder)) {
					if (entry.is_regular_file() && entry.path().extension() == ".json"sv) {
						files.emplace_back(entry.path().string());
					}
				}
				std::ranges::sort(files);
				return files;
			}

			using RaceFormCache = rcs::form::FormCache<RE::TESRace>;

			RE::TESRace* LookupRace(std::string_view form_str, RaceFormCache& cache)
			{
				auto* race = rcs::form::LookupCachedForm(form_str, cache);
				if (!race) {
					logs::warn("\tInvalid race form {}"sv, form_str);
				}
				return race;
			}

			auto ParseArmorProxy(const RawConfigEntry::RaceProxy::ArmorProxy& armor_proxy, RaceFormCache& form_cache)
				-> ConfigEntry::RaceProxy::ArmorProxy
			{
				using BipedObjectSlot = RE::BGSBipedObjectForm::BipedObjectSlot;
				using ArmorVariant = ConfigEntry::ArmorVariant;

				ConfigEntry::RaceProxy::ArmorProxy result{
					.proxy = armor_proxy.race.empty() ? nullptr : LookupRace(armor_proxy.race, form_cache)
				};
				if (!armor_proxy.variants.empty()) {
					result.variants.reserve(armor_proxy.variants.size());
					for (const auto& variant : armor_proxy.variants) {
						auto* race = LookupRace(variant.proxy, form_cache);
						if (!race || variant.slots.empty()) {
							continue;
						}
						auto slot_mask = REX::EnumSet<BipedObjectSlot, std::uint32_t>{};
						for (const auto& slot :
							variant.slots | std::views::filter([](const auto& slot) { return slot >= 30 && slot <= 61; })) {
							slot_mask.set(BipedObjectSlot(1 << (slot - 30)));
						}
						if (slot_mask.underlying()) {
							result.variants.emplace_back(ArmorVariant{
								.race = race,
								.slotMask = slot_mask.get() });
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
					.armor = ParseArmorProxy(proxy_config.armor, form_cache)
				};

				for (const auto& proxy : proxy_config.proxies) {
					auto* race = LookupRace(proxy, form_cache);
					if (race) {
						result.proxies.insert(race);
					}
				}

				return result;
			}

			void ApplyVampirismAndHeadPart(const ConfigEntry& config, manager::headpart::HeadPartFormIdListAdder& adder)
			{
				auto* manager = manager::RaceManager::GetSingleton();
				auto *race = config.race.form, *race_vamp = config.vampireRace.form;
				manager->EmplaceVampirismRacePair(race, race_vamp);
				adder.AddRace(race, race_vamp, config.headPart);
			}

			void ApplyRaceProxy(ConfigEntry::RaceProxy& race_proxy)
			{
				auto* manager = manager::RaceManager::GetSingleton();
				// apply dialogue race proxies
				if (!race_proxy.proxies.empty()) {
					manager->EmplaceRaceProxies(race_proxy.form, std::move(race_proxy.proxies));
				}
				// set armorParentRace
				if (auto* armor_race = race_proxy.armor.proxy;
					armor_race) {
					race_proxy.form->armorParentRace = armor_race;
				}
				// add armorParentRace for specific slot mask
				if (!race_proxy.armor.variants.empty()) {
					manager->EmplaceArmorRaceProxies(race_proxy.form, std::move(race_proxy.armor.variants));
				}
			}

			const std::vector<RawConfigEntry> GetDefaultRawEntries()
			{
#define RCS_DEFAULT_RACE_RAW_ENTRY(a_name)       \
	RawConfigEntry                               \
	{                                            \
		.name = #a_name,                         \
		.race = RawConfigEntry::RaceProxy{       \
			.form = (#a_name "Race"),            \
		},                                       \
		.vampireRace = RawConfigEntry::RaceProxy \
		{                                        \
			.form = (#a_name "RaceVampire"),     \
		}                                        \
	}

				auto t = RCS_DEFAULT_RACE_RAW_ENTRY(Argonian);
				return std::vector<RawConfigEntry>{
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
				};
#undef RCS_DEFAULT_RACE_RAW_ENTRY
			}

			struct ParseCache
			{
				manager::headpart::HeadPartFormIdListAdder&    adder;
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
					logs::info("Entry: {}\t({}, {})"sv,
						raw_config.name, raw_config.race.form, raw_config.vampireRace.form);

					auto config = ConfigEntry{
						.race = ParseRaceProxy(raw_config.race, cache.form_cache),
						.vampireRace = ParseRaceProxy(raw_config.vampireRace, cache.form_cache),
						.headPart = cache.adder.GetHeadPartType(raw_config.headPart)
					};

					const auto *race = config.race.form, *race_vamp = config.vampireRace.form;
					if (!race || !race_vamp) {
						logs::warn("\t[SKIP] Invalid race or vampire race"sv);
						continue;
					} else if (auto it_race = cache.visited_map.find(race);
							   it_race != cache.visited_map.end()) {
						logs::warn("\t[SKIP] Race already used in {}"sv, it_race->second);
						continue;
					} else if (auto it_race_vamp = cache.visited_map.find(race_vamp);
							   it_race_vamp != cache.visited_map.end()) {
						logs::warn("\t[SKIP] Vampire race already used in {}"sv, it_race_vamp->second);
						continue;
					}

					ApplyVampirismAndHeadPart(config, cache.adder);
					ApplyRaceProxy(config.race);
					ApplyRaceProxy(config.vampireRace);

					auto info = std::string_view(
						cache.applied_entry_info.emplace_back(std::format("{}:{}"sv, filename, raw_config.name)));
					cache.visited_map.emplace(race, info);
					cache.visited_map.emplace(race_vamp, info);
				}
			}

			bool LoadConfigs(std::vector<std::string>& files)
			{
				bool is_adder_initialized{ false };
				auto adder = manager::headpart::HeadPartFormIdListAdder(is_adder_initialized);
				if (!is_adder_initialized) {
					logs::error("Failed to initialize HeadPartFormIdListAdder"sv);
					return false;
				}

				auto parse_cache = ParseCache{
					.adder = adder
				};

				// from config files
				for (const auto& file : files | std::views::reverse) {
					logs::info("Config: {}", file);

					///// Read Configs From File
					auto content = glz::read_json<glz::json_t>(glz::file_to_buffer(file));
					if (!content) {
						logs::error("Failed to read file for {}",
							content.error().custom_error_message);
						continue;
					}
					auto raw_config_data = glz::read_json<std::vector<RawConfigEntry>>(
						content.value()[rcs::CONFIG_KEY]);
					if (!raw_config_data) {
						logs::error("Failed to read config from file for {}"sv,
							raw_config_data.error().custom_error_message);
						continue;
					}
					/////

					///// Parse And Apply Raw Configs
					ParseAndApplyRawConfig(file, raw_config_data.value(), parse_cache);
					/////
				}

				// from default
				logs::info("Config: Default");
				const auto default_raw_entries = GetDefaultRawEntries();
				ParseAndApplyRawConfig("Default", default_raw_entries, parse_cache);

				// summary
				manager::RaceManager::GetSingleton()->Summary();
				return true;
			}
		}  // namespace detail

		bool TryReadAndApplyConfigs()
		{
			logs::info("{:*^30}", "CONFIGS");
			if (!RE::TESDataHandler::GetSingleton()) {
				logs::error("TESDataHandler is not initialized"sv);
				return false;
			}
			auto files = detail::CollectConfigFilesFromFolder(rcs::CONFIG_DIR);
			if (files.empty()) {
				logs::warn("No config files found in {}"sv, rcs::CONFIG_DIR);
			}
			return detail::LoadConfigs(files);
		}
	}  // namespace config
}  // namespace rcs
