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
                struct ArmorOverride
                {
                    std::vector<uint8_t> slots;
                    std::string_view     proxy;
                };

                std::string_view           race;
                std::vector<ArmorOverride> overrides;
            };

            std::string_view         form;
            std::string_view         proxy;
            ArmorProxy               armor;
            std::vector<std::string> headPart;
        };

        std::string_view       name;
        RaceProxy              race;
        std::vector<RaceProxy> variants;
    };

    struct RawRaceConfigFileContent
    {
        std::vector<RawConfigEntry> entries;
    };

    struct FunctionID
    {
        std::string_view script;
        std::string_view function;
        std::string_view state;
    };

    struct GetRaceExclusion
    {
        std::vector<FunctionID>       functions;
        std::vector<std::string_view> unlessProxyMatches;
    };

    struct RawPluginConfigFileContent
    {
        struct Settings
        {
            std::vector<std::string_view> alternateForms;
            std::vector<GetRaceExclusion> getRaceExclusions;
        };

        Settings settings;
    };

    struct ConfigEntry
    {
        struct RaceProxy
        {
            struct ArmorProxy
            {
                RE::TESRace*                        race;
                std::vector<manager::ArmorOverride> overrides;
            };

            RE::TESRace*                 form;
            const RE::TESRace*           proxy;
            ArmorProxy                   armor;
            std::span<const std::string> headPart;
        };

        RaceProxy              race;
        std::vector<RaceProxy> variants;
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
        void                                                    ProcessGetRaceExclusions(const std::vector<GetRaceExclusion>& exclusions);
        void                                                    ProcessRaceConfigFile(const std::filesystem::path& path);
        void                                                    ProcessRaceConfigEntries(std::string_view filename, const std::vector<RawConfigEntry>& entries);
        // parse
        RaceProxy    ParseRaceProxy(const RawRaceProxy& raw, RE::TESRace* race);
        RE::TESRace* LookupRace(std::string_view form);
        // apply
        void ApplyRaceProxy(RaceProxy&& proxy) const;

        std::filesystem::path                                    configDir{ CONFIG_DIR };
        manager::headpart::HeadPartFormIdListAdder               adder;
        RaceFormCache                                            formCache;
        std::deque<std::string>                                  entryInfoPool{};  // make sure alive during processing
        std::unordered_map<const RE::TESRace*, std::string_view> visitedRaces{};
    };

    bool ProcessConfigs();
}

template <>
struct glz::meta<rcs::config::RawConfigEntry::RaceProxy::ArmorProxy>
{
    using T = rcs::config::RawConfigEntry::RaceProxy::ArmorProxy;

    static constexpr auto value = glz::object(
        "race", &T::race,
        "overrides", &T::overrides,
        "variants", &T::overrides);
};

template <>
struct glz::meta<rcs::config::RawConfigEntry::RaceProxy>
{
    using T = rcs::config::RawConfigEntry::RaceProxy;

    static constexpr auto ReadProxies = [](T& config, std::vector<std::string_view>&& input) {
        // logs::warn("\tproxies is deprecated; only the first item is used. Use proxy instead"sv);
        config.proxy = input.front();
    };

    static constexpr auto ReadHeadPart = [](T& config, std::variant<std::string, std::vector<std::string>>&& input) {
        std::visit([&]<typename P>(P& value) {
            if constexpr (std::is_same_v<P, std::string>) {
                if (!value.empty()) {
                    config.headPart.emplace_back(std::move(value));
                }
            } else {
                config.headPart = std::move(value);
            }
        },
            input);
    };

    static constexpr auto value = glz::object(
        "form", &T::form,
        "proxy", &T::proxy,
        "proxies", glz::custom<ReadProxies, glz::skip{}>,
        "armor", &T::armor,
        "headPart", glz::custom<ReadHeadPart, glz::skip{}>);
};

template <>
struct glz::from<glz::JSON, rcs::config::RawConfigEntry>
{
    using T = rcs::config::RawConfigEntry;

    // Legacy fields exist only in the JSON input
    struct InputEntry
    {
        using RaceProxy = rcs::config::RawConfigEntry::RaceProxy;

        std::string_view                                    name;
        RaceProxy                                           race;
        std::vector<RaceProxy>                              variants;
        RaceProxy                                           vampireRace;
        std::variant<std::string, std::vector<std::string>> headPart;
    };

    template <auto Opts>
    static void op(T& config, auto&& ctx, auto&& it, auto&& end)
    {
        InputEntry input{};
        glz::from<glz::JSON, InputEntry>::template op<Opts>(input, ctx, it, end);
        if (glz::parse_failed(ctx.error)) {
            return;
        }

        auto& race = input.race;
        auto& vampireRace = input.vampireRace;
        glz::meta<InputEntry::RaceProxy>::ReadHeadPart(race, std::move(input.headPart));
        if (!vampireRace.form.empty()) {
            vampireRace.headPart.reserve(race.headPart.size());
            for (const auto& type : race.headPart) {
                vampireRace.headPart.emplace_back(type + "Vampire");
            }
            input.variants.emplace_back(std::move(vampireRace));
        }
        config = { input.name, std::move(race), std::move(input.variants) };
    }
};

template <>
struct glz::meta<rcs::config::RawRaceConfigFileContent>
{
    using T = rcs::config::RawRaceConfigFileContent;

    static constexpr auto value = glz::object(
        "$schema", glz::skip{},
        rcs::CONFIG_KEY, &T::entries);
};

template <>
struct glz::meta<rcs::config::RawPluginConfigFileContent>
{
    using T = rcs::config::RawPluginConfigFileContent;

    static constexpr auto value = glz::object(
        "$schema", glz::skip{},
        rcs::CONFIG_KEY, &T::settings);
};
