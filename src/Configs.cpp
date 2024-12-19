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

			using RaceFormCache = form::FormCache<RE::TESRace>;

			RE::TESRace* LookupRace(std::string_view form_str, RaceFormCache& cache)
			{
				auto* race = form::LookupCachedForm(form_str, cache);
				if (!race) {
					logs::warn("\t\tInvalid race form: {}"sv, form_str);
				}
				return race;
			}

			auto ParseArmorProxy(const RawConfigEntry::RaceProxy::ArmorProxy& armor_proxy, RaceFormCache& form_cache)
				-> ConfigEntry::RaceProxy::ArmorProxy
			{
				using BipedObjectSlot = RE::BGSBipedObjectForm::BipedObjectSlot;
				using ArmorVariant = ConfigEntry::ArmorVariant;

				ConfigEntry::RaceProxy::ArmorProxy result{
					.proxy = armor_proxy.race.empty() ? nullptr : LookupRace(armor_proxy.race, form_cache),
					.variants = std::vector<ArmorVariant>(armor_proxy.variants.size())
				};
				if (!armor_proxy.variants.empty()) {
					size_t i = 0;
					for (const auto& [slots, proxy] : armor_proxy.variants) {
						auto* race = LookupRace(proxy, form_cache);
						if (!race || slots.empty()) {
							continue;
						}
						auto slot_mask = REX::EnumSet<BipedObjectSlot, std::uint32_t>{};
						for (const auto& slot :
							slots | std::views::filter([](const auto& s) { return s >= 30 && s <= 61; })) {
							slot_mask.set(static_cast<BipedObjectSlot>(1 << (slot - 30)));
						}
						if (slot_mask.underlying()) {
							result.variants[i] = ArmorVariant{
								.race = race,
								.slotMask = slot_mask.get()
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
					if (const auto* race = LookupRace(proxy, form_cache); race) {
						result.proxies.insert(race);
					}
				}

				return result;
			}

			void ApplyVampirismAndHeadPart(const ConfigEntry& config, manager::headpart::HeadPartFormIdListAdder& adder)
			{
				auto *race = config.race.form, *race_vamp = config.vampireRace.form;
				manager::EmplaceVampirismRacePair(race, race_vamp);
				adder.AddRace(race, race_vamp, config.headPart);
			}

			void ApplyRaceProxy(ConfigEntry::RaceProxy& race_proxy)
			{
				// apply dialogue race proxies
				if (!race_proxy.proxies.empty()) {
					manager::EmplaceRaceProxies(race_proxy.form, std::move(race_proxy.proxies));
				}
				// set armorParentRace
				if (auto* armor_race = race_proxy.armor.proxy;
					armor_race) {
					race_proxy.form->armorParentRace = armor_race;
				}
				// add armorParentRace for specific slot mask
				if (!race_proxy.armor.variants.empty()) {
					EmplaceArmorRaceProxies(race_proxy.form, std::move(race_proxy.armor.variants));
				}
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
						raw_config.name, raw_config.race.form, raw_config.vampireRace.form);

					auto config = ConfigEntry{
						.race = ParseRaceProxy(raw_config.race, cache.form_cache),
						.vampireRace = ParseRaceProxy(raw_config.vampireRace, cache.form_cache),
						.headPart = manager::headpart::GetHeadPartType(raw_config.headPart)
					};

					const auto *race = config.race.form, *race_vamp = config.vampireRace.form;
					if (!race || !race_vamp) {
						logs::warn("\t\t[SKIP] Invalid race or vampire race"sv);
						continue;
					}
					if (auto it_race = cache.visited_map.find(race);
						it_race != cache.visited_map.end()) {
						logs::warn("\t\t[SKIP] Race already used in {}"sv, it_race->second);
						continue;
					}
					if (auto it_race_vamp = cache.visited_map.find(race_vamp);
						it_race_vamp != cache.visited_map.end()) {
						logs::warn("\t\t[SKIP] Vampire race already used in {}"sv, it_race_vamp->second);
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

			bool LoadConfigs(std::vector<std::string>& files)
			{
				auto parse_cache = ParseCache{};
				if (!parse_cache.adder.IsInitialized()) {
					logs::error("HeadPartFormIdListAdder is not initialized"sv);
					return false;
				}

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
				logs::info("Config: default");
				ParseAndApplyRawConfig(
					"default",
					std::vector{
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

				// summary
				manager::Summary();
				return true;
			}
		}  // namespace detail
#undef RCS_DEFAULT_RACE_RAW_ENTRY

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
