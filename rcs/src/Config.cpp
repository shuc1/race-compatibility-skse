#include "Config.h"

namespace rcs::config
{
    bool ConfigProcessor::Run()
    {
        // check initialization
        if (!adder.IsInitialized()) {
            logs::error("HeadPartFormIdListAdder is not initialized"sv);
            return false;
        }
        if (!formCache.dataHandler) {
            logs::error("Data handler is not initialized"sv);
            return false;
        }
        // list and process config files
        auto files = ListConfigFiles(configDir);
        if (files.empty()) {
            logs::warn("{} does not exist or contains no config files"sv, configDir.string());
        }
        for (const auto& path : files) {
            ProcessRaceConfigFile(path);
        }
        for (const auto& path : ListConfigFiles(configDir / "config")) {
            ProcessPluginConfigFile(path);
        }
        // vanilla game config entries
        logs::info("default:"sv);
        ProcessRaceConfigEntries("default"sv,
            {
#define X(NAME)                                             \
    RawConfigEntry{                                         \
        .name = #NAME##sv,                                  \
        .race = { .form = (#NAME "Race"sv) },               \
        .variants = { { .form = (#NAME "RaceVampire"sv) } } \
    },
                VANILLA_RACES
#undef X
            });
        ProcessAlternateForms(
            { "WerewolfBeastRace"sv,
                "DLC1VampireBeastRace"sv,
                "DLC2WerebearBeastRace"sv });
        return true;
    }

    std::vector<std::filesystem::path> ConfigProcessor::ListConfigFiles(const std::filesystem::path& directory)
    {
        std::vector<std::filesystem::path> result{};
        if (!std::filesystem::exists(directory)) {
            return result;
        }
        // there should not be that many config files
        result.reserve(4);
        for (const auto& entry : std::filesystem::directory_iterator(directory)) {
            if (!entry.is_regular_file()) {
                continue;
            }
            const auto  ext = entry.path().extension();
            const auto& native = ext.native();
            if (native.size() == 5 &&
                native[0] == L'.' &&
                (native[1] == L'j' || native[1] == L'J') &&
                (native[2] == L's' || native[2] == L'S') &&
                (native[3] == L'o' || native[3] == L'O') &&
                (native[4] == L'n' || native[4] == L'N')) {
                result.emplace_back(entry.path());
            }
        }
        // sort files in descending order to have higher priority files processed first
        std::ranges::sort(result, std::ranges::greater{});
        return result;
    }

    void ConfigProcessor::ProcessPluginConfigFile(const std::filesystem::path& path)
    {
        const auto filename{ path.filename().string() };
        logs::info("{}:"sv, filename);
        auto buffer = glz::file_to_buffer(path.string());
        auto content = glz::read_json<RawPluginConfigFileContent>(buffer);
        if (!content) {
            logs::error("Failed to read config/{} for \"{}\""sv, filename, glz::format_error(content));
            return;
        }
        auto& settings = content.value().settings;
        if (!settings.alternateForms.empty()) {
            ProcessAlternateForms(settings.alternateForms);
        }
        if (!settings.getRaceExclusions.empty()) {
            ProcessGetRaceExclusions(settings.getRaceExclusions);
        }
    }

    void ConfigProcessor::ProcessAlternateForms(const std::vector<std::string_view>& forms)
    {
        for (const auto& form : forms) {
            const auto* race = LookupRace(form);
            logs::info("\t[Alternate Form]: {}"sv, form);
            if (!race) {
                logs::warn("\t\t[SKIP] Form {} not found"sv, form);
                continue;
            }
            manager::AddAlternateForm(race);
        }
    }

    void ConfigProcessor::ProcessGetRaceExclusions(const std::vector<GetRaceExclusion>& exclusions)
    {
        for (const auto& raw : exclusions | std::views::reverse) {
            manager::GetRaceExclusion rule{};
            // keep slot addresses stable while appending function bindings
            rule.functions.reserve(raw.functions.size());
            for (const auto& exclusion : raw.functions) {
                if (exclusion.state.empty()) {
                    logs::info("\t[GetRace Exclusion]: {}::{}"sv,
                        exclusion.script, exclusion.function);
                } else {
                    logs::info("\t[GetRace Exclusion]: {}::{} [{}]"sv,
                        exclusion.script, exclusion.function, exclusion.state);
                }

                const RE::BSFixedString scriptName{ std::string{ exclusion.script } };
                auto                    it = std::ranges::find(manager::scriptBindings, scriptName, &manager::ScriptBinding::name);
                auto&                   script = it == manager::scriptBindings.end() ?
                                                     manager::scriptBindings.emplace_back(scriptName) :
                                                     *it;

                RE::BSFixedString state{ std::string{ exclusion.state } };
                RE::BSFixedString name{ std::string{ exclusion.function } };
                if (std::ranges::any_of(script.functions, [&](const auto& existing) {
                        return existing.state == state && existing.name == name;
                    })) {
                    logs::warn("\t\t[SKIP] Function already excluded by another config"sv);
                    continue;
                }

                auto& slot = rule.functions.emplace_back(nullptr);
                script.functions.emplace_back(std::move(state), std::move(name), slot);
            }
            if (rule.functions.empty()) {
                continue;
            }
            rule.unlessProxyMatches.reserve(raw.unlessProxyMatches.size());
            for (const auto& form : raw.unlessProxyMatches) {
                const auto* race = LookupRace(form);
                if (!race) {
                    logs::warn("\t[GetRace Exclusion] Proxy race {} not found"sv, form);
                    continue;
                }
                rule.unlessProxyMatches.emplace_back(race);
            }
            manager::getRaceExclusions.emplace_back(std::move(rule));
        }
    }

    void ConfigProcessor::ProcessRaceConfigFile(const std::filesystem::path& path)
    {
        const auto filename{ path.filename().string() };
        logs::info("{}:"sv, filename);
        auto       buffer = glz::file_to_buffer(path.string());
        const auto content = glz::read_json<RawRaceConfigFileContent>(buffer);
        if (!content) {
            logs::error("Failed to read {} for \"{}\""sv, filename, glz::format_error(content));
            return;
        }
        ProcessRaceConfigEntries(filename, content.value().entries);
    }

    void ConfigProcessor::ProcessRaceConfigEntries(std::string_view filename, const std::vector<RawConfigEntry>& entries)
    {
        for (const auto& [entryName, raceString, variantStrings] :
            entries | std::views::reverse) {
            logs::info("\t[{}]: {} "sv, entryName, raceString.form);

            // Resolve races and reject duplicates.
            auto* race = LookupRace(raceString.form);
            if (!race) {
                logs::warn("\t\t[SKIP] Race not found"sv);
                continue;
            }
            if (const auto it = visitedRaces.find(race); it != visitedRaces.end()) {
                logs::warn("\t\t[SKIP] Race already used in {}"sv, it->second);
                continue;
            }
            std::string_view loc{ entryInfoPool.emplace_back(std::format("{}:{}"sv, filename, entryName)) };
            visitedRaces.emplace(race, loc);

            auto entry = ConfigEntry{
                .race = ParseRaceProxy(raceString, race),
                .variants = {}
            };

            std::vector<const RE::TESRace*> races;
            races.reserve(1 + variantStrings.size());
            races.emplace_back(race);
            entry.variants.reserve(variantStrings.size());
            for (const auto& raw : variantStrings) {
                logs::info("\t\t[Variant] {}"sv, raw.form);
                auto* variantRace = LookupRace(raw.form);
                if (!variantRace) {
                    logs::warn("\t\t\t[SKIP] Variant race not found"sv);
                    continue;
                }
                if (const auto [it, inserted] = visitedRaces.try_emplace(variantRace, loc); !inserted) {
                    logs::warn("\t\t\t[SKIP] Variant race already used in {}"sv, it->second);
                    continue;
                }
                races.emplace_back(variantRace);
                entry.variants.emplace_back(ParseRaceProxy(raw, variantRace));
            }

            // apply
            ApplyRaceProxy(std::move(entry.race));
            for (auto& variant : entry.variants) {
                ApplyRaceProxy(std::move(variant));
            }
            manager::EmplaceRaceGroup(std::move(races));
        }
    }

    auto ConfigProcessor::ParseRaceProxy(const RawRaceProxy& raw, RE::TESRace* race) -> RaceProxy
    {
        RaceProxy result{
            .form = race,
            .proxy{},
            .armor = {
                .race = LookupRace(raw.armor.race),
                .overrides{} },
            .headPart = raw.headPart,
        };
        // race proxy
        result.proxy = LookupRace(raw.proxy);
        // race armor proxy
        if (!raw.armor.overrides.empty()) {
            auto& overrides = result.armor.overrides;
            // reserve space to avoid multiple allocations; similar to allocating all at once and then resizing
            // refer to: https://godbolt.org/z/T9za7v1cb
            overrides.reserve(raw.armor.overrides.size());
            for (const auto& [slots, form] : raw.armor.overrides) {
                if (slots.empty()) {
                    continue;
                }
                const auto* varProxy = LookupRace(form);
                if (!varProxy) {
                    continue;
                }
                using Slot = RE::BGSBipedObjectForm::BipedObjectSlot;
#ifdef SKYRIMVR
#    define TEnumSet EnumSet
#endif
                auto slotSet = REX::TEnumSet<Slot, std::uint32_t>{};
#ifdef SKYRIMVR
#    undef TEnumSet
#endif
                for (const auto& slot : slots) {
                    if (slot >= 30 && slot <= 61) {
                        slotSet.set(static_cast<Slot>(1u << (slot - 30)));
                    }
                }
                if (slotSet.underlying()) {
                    overrides.emplace_back(varProxy, slotSet.get());
                }
            }
        }
        return result;
    }

    RE::TESRace* ConfigProcessor::LookupRace(const std::string_view form)
    {
        return form.empty() ? nullptr : form::LookupCachedForm(form, formCache);
    }

    void ConfigProcessor::ApplyRaceProxy(RaceProxy&& proxy) const
    {
        // proxy
        manager::EmplaceRaceProxy(proxy.form, proxy.proxy);
        // armor
        if (auto* armorRace = proxy.armor.race) {
            proxy.form->armorParentRace = armorRace;
        }
        manager::EmplaceArmorRaceProxies(proxy.form, std::move(proxy.armor.overrides));
        // headpart
        for (const auto& type : proxy.headPart) {
            adder.AddRace(proxy.form, type);
        }
    }

    bool ProcessConfigs()
    {
        logs::info("{:*^30}"sv, "CONFIGS"sv);
        ConfigProcessor processor{};
        const auto      start = std::chrono::system_clock::now();
        const auto      result = processor.Run();
        const auto      end = std::chrono::system_clock::now();
        const auto      ms = std::chrono::duration_cast<std::chrono::milliseconds>(end - start).count();
        logs::info("Processed configs in {}ms"sv, ms);
        manager::LogSummary();
        return result;
    }
}  // namespace rcs::config
