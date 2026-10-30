#pragma once

#include "Form.h"
#include "RaceManager.h"
#include <glaze/glaze.hpp>
#include <string>
#include <string_view>

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
                    std::vector<uint8_t> slots;
                    std::string_view     proxy;
                };

                std::string_view          race;
                std::vector<ArmorVariant> variants;
            };

            std::string_view form;
            std::string_view proxy;
            ArmorProxy       armor;
        };

        std::string_view                                              name;
        RaceProxy                                                     race;
        RaceProxy                                                     vampireRace;
        std::variant<std::string_view, std::vector<std::string_view>> headPart;
    };

    struct RawRaceConfigFileContent
    {
        std::string_view            schema;
        std::vector<RawConfigEntry> entries;
    };

    struct RaceProxyExclusion
    {
        std::string_view script;
        std::string_view function;
        std::string_view state;
    };

    struct RawPluginConfigFileContent
    {
        struct Settings
        {
            std::vector<std::string_view>   alternateForms;
            std::vector<RaceProxyExclusion> raceProxyExclusions;
        };

        std::string_view schema;
        Settings         settings;
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
                std::vector<ArmorVariant> variants;
            };

            RE::TESRace*       form;
            const RE::TESRace* proxy;
            ArmorProxy         armor;
        };

        RaceProxy                 race;
        RaceProxy                 vampireRace;
        std::vector<HeadPartType> headPartTypes;
    };

    class ConfigProcessor
    {
        using RaceFormCache = form::FormCache<RE::TESRace>;
        using RawRaceProxy = RawConfigEntry::RaceProxy;
        using RaceProxy = ConfigEntry::RaceProxy;

    public:
        [[nodiscard]] bool Run();

    private:
        // process
        [[nodiscard]] static std::vector<std::filesystem::path> ListConfigFiles(const std::filesystem::path& directory);
        void                                                    ProcessPluginConfigFile(const std::filesystem::path& path);
        void                                                    ProcessAlternateForms(const std::vector<std::string_view>& forms);
        void                                                    ProcessRaceProxyExclusions(const std::vector<RaceProxyExclusion>& exclusions);
        void                                                    ProcessRaceConfigFile(const std::filesystem::path& path);
        void                                                    ProcessRaceConfigEntries(std::string_view filename, const std::vector<RawConfigEntry>& entries);
        // parse
        RaceProxy    ParseRaceProxy(const RawRaceProxy& raw);
        RE::TESRace* LookupRace(std::string_view form);
        // apply
        void        ApplyConfigEntry(ConfigEntry& entry) const;
        static void ApplyRaceProxy(RaceProxy& proxy);

        std::filesystem::path                                    configDir{ CONFIG_DIR };
        manager::headpart::HeadPartFormIdListAdder               adder;
        RaceFormCache                                            formCache;
        std::deque<std::string>                                  entryInfoPool{};  // make sure alive during processing
        std::unordered_map<const RE::TESRace*, std::string_view> visitedMap{};
    };

    bool ProcessConfigs();
}

template <>
struct glz::meta<rcs::config::RawConfigEntry::RaceProxy>
{
    using T = rcs::config::RawConfigEntry::RaceProxy;

    static constexpr auto ReadProxies = [](T& config, const std::vector<std::string_view>& proxies) {
        logs::warn("\tproxies is deprecated; only the first item is used. Use proxy instead"sv);
        config.proxy = proxies.front();
    };

    static constexpr auto value = glz::object(
        "form", &T::form,
        "proxy", &T::proxy,
        "proxies", glz::custom<ReadProxies, glz::skip{}>,
        "armor", &T::armor);
};

template <>
struct glz::meta<rcs::config::RawRaceConfigFileContent>
{
    using T = rcs::config::RawRaceConfigFileContent;

    static constexpr auto value = glz::object(
        "$schema", &T::schema,
        rcs::CONFIG_KEY, &T::entries);
};

template <>
struct glz::meta<rcs::config::RawPluginConfigFileContent>
{
    using T = rcs::config::RawPluginConfigFileContent;

    static constexpr auto value = glz::object(
        "$schema", &T::schema,
        rcs::CONFIG_KEY, &T::settings);
};
