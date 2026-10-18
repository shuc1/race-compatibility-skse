#pragma once

#include "Form.h"
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

    struct RawConfigFileContent
    {
        using RaceEntries = std::vector<RawConfigEntry>;
        using AlternateForms = std::vector<std::string_view>;

        std::string_view                          schema;
        std::variant<RaceEntries, AlternateForms> entries;
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
        [[nodiscard]] std::vector<std::filesystem::path> ListConfigFiles() const;
        void                                             ProcessConfigFile(const std::filesystem::path& path);
        void                                             ProcessFileEntries(std::string_view filename, const std::vector<RawConfigEntry>& entries);
        void                                             ProcessAlternateForms(const std::vector<std::string_view>& forms);
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
struct glz::meta<rcs::config::RawConfigFileContent>
{
    using T = rcs::config::RawConfigFileContent;

    template <typename Entries>
    static constexpr auto ReadEntries = [](T& config, Entries entries) {
        config.entries = std::move(entries);
    };

    static constexpr auto value = glz::object(
        "$schema", &T::schema,
        rcs::CONFIG_KEY, glz::custom<ReadEntries<T::RaceEntries>, glz::skip{}>,
        "AlternateForms", glz::custom<ReadEntries<T::AlternateForms>, glz::skip{}>);
};
