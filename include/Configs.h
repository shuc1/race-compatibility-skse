#pragma once

#include "RaceManager.h"
#include <glaze/glaze.hpp>

namespace rcs
{
	namespace config
	{
		struct RawConfigEntry
		{
			struct RaceProxy
			{
				struct ArmorProxy
				{
					struct ArmorVariant
					{
						std::vector<uint8_t> slots{};
						std::string_view     proxy;
					};

					std::string_view          race;
					std::vector<ArmorVariant> variants{};
				};

				std::string_view              form;
				std::vector<std::string_view> proxies{};
				ArmorProxy                    armor;
			};

			std::string_view name;
			RaceProxy        race;
			RaceProxy        vampireRace;
			std::string_view headPart;
		};

		struct RawConfigFileContent
		{
			std::string_view            schema;
			std::vector<RawConfigEntry> entries{};
		};

		struct ConfigEntry
		{
			using ArmorVariant = manager::ArmorProxyEntry;
			using HeadPartType = manager::HeadPartType;

			struct RaceProxy
			{
				struct ArmorProxy
				{
					RE::TESRace*              race;
					std::vector<ArmorVariant> variants{};
				};

				RE::TESRace*                 form;
				std::set<const RE::TESRace*> proxies{};
				ArmorProxy                   armor;
			};

			RaceProxy    race;
			RaceProxy    vampireRace;
			HeadPartType headPart;
		};

		bool TryReadAndApplyConfigs();
	}  // namespace config
}  // namespace rcs

template <>
struct glz::meta<rcs::config::RawConfigFileContent>
{
	static constexpr std::string_view rename_key(const std::string_view key)
	{
		if (key == "schema"sv) {
			return "$schema"sv;
		}
		if (key == "entries"sv) {
			return rcs::CONFIG_KEY;
		}
		return key;
	}
};