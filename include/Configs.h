#pragma once

#include "Forms.h"
#include "RaceManager.h"
#include <glaze/glaze.hpp>

namespace rcs::config
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

	class ConfigProcessor
	{
		using RaceFormCache = form::FormCache<RE::TESRace>;
		using RawRaceProxy = RawConfigEntry::RaceProxy;
		using RaceProxy = ConfigEntry::RaceProxy;

	public:
		explicit ConfigProcessor() : configDir{ CONFIG_DIR } {}
		[[nodiscard]] bool Run();

	private:
		// process
		[[nodiscard]] std::vector<std::filesystem::path> ListConfigFiles() const;
		void                                             ProcessConfigFile(const std::filesystem::path& path);
		void                                             ProcessFileEntries(std::string_view filename, const std::vector<RawConfigEntry>& entries);
		// parse
		RaceProxy    ParseRaceProxy(const RawRaceProxy& raw);
		RE::TESRace* LookupRace(std::string_view form);
		// apply
		void        ApplyConfigEntry(ConfigEntry& entry) const;
		static void ApplyRaceProxy(RaceProxy& proxy);

		std::filesystem::path                                    configDir;
		manager::headpart::HeadPartFormIdListAdder               adder;
		RaceFormCache                                            formCache;
		std::deque<std::string>                                  entryInfoPool;  // make sure alive during processing
		std::unordered_map<const RE::TESRace*, std::string_view> visitedMap;
	};

	bool TryProcessConfigs();
}

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