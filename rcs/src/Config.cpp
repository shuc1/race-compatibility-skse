#include "Config.h"

namespace
{
    using namespace rcs::config;
    auto ParseHeadPartTypes(const std::variant<std::string_view, std::vector<std::string_view>>& raw)
        -> std::vector<ConfigEntry::HeadPartType>
    {
        std::vector<ConfigEntry::HeadPartType> result{};
        std::visit([&]<typename T>(const T& t) {
            using namespace rcs::manager;
            using u = std::remove_cvref_t<T>;
            if constexpr (std::is_same_v<u, std::string_view>) {
                result.emplace_back(headpart::StringToHeadPartType(t));
            } else if constexpr (std::is_same_v<u, std::vector<std::string_view>>) {
                for (const auto& _ : t) {
                    result.emplace_back(headpart::StringToHeadPartType(_));
                }
            }
        },
            raw);
        return result;
    }
}  // namespace anonymous

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
        auto files = ListConfigFiles();
        if (files.empty()) {
            logs::warn("{} does not exist or contains no config files"sv, configDir.string());
        }
        // sort files in descending order to have higher priority files processed first
        std::ranges::sort(files, std::ranges::greater{});
        for (const auto& path : files) {
            ProcessConfigFile(path);
        }
        // vanilla game config entries
        logs::info("default:"sv);
        ProcessFileEntries("default"sv,
            {
#define X(NAME)                                             \
    RawConfigEntry{                                         \
        .name = #NAME##sv,                                  \
        .race = { .form = (#NAME "Race"sv) },               \
        .vampireRace = { .form = (#NAME "RaceVampire"sv) }, \
        .headPart = #NAME##sv                               \
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

    std::vector<std::filesystem::path> ConfigProcessor::ListConfigFiles() const
    {
        std::vector<std::filesystem::path> result{};
        if (!std::filesystem::exists(configDir)) {
            return result;
        }
        // there should not be that many config files
        result.reserve(4);
        for (const auto& entry : std::filesystem::directory_iterator(configDir)) {
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
        return result;
    }

    void ConfigProcessor::ProcessConfigFile(const std::filesystem::path& path)
    {
        const auto filename{ path.filename().string() };
        logs::info("{}:"sv, filename);
        auto       buffer = glz::file_to_buffer(path.string());
        const auto content = glz::read_json<RawConfigFileContent>(buffer);
        if (!content) {
            logs::error("Failed to read {} for \"{}\""sv, filename, glz::format_error(content));
            return;
        }
        std::visit([&](const auto& entries) {
            using T = std::decay_t<decltype(entries)>;
            if constexpr (std::is_same_v<T, RawConfigFileContent::RaceEntries>) {
                ProcessFileEntries(filename, entries);
            } else {
                ProcessAlternateForms(entries);
            }
        },
            content.value().entries);
    }

    void ConfigProcessor::ProcessAlternateForms(const std::vector<std::string_view>& forms)
    {
        logs::info("\tAlternate forms:"sv);
        for (const auto& form : forms) {
            const auto* race = LookupRace(form);
            if (!race) {
                logs::warn("\t\t[SKIP] Alternate form {} not found"sv, form);
                continue;
            }
            if (manager::AddAlternateForm(race)) {
                logs::info("\t\t{}"sv, form);
            }
        }
    }

    void ConfigProcessor::ProcessFileEntries(std::string_view filename, const std::vector<RawConfigEntry>& entries)
    {
        for (const auto& [entryName, raceString, vampireRaceString, headPartVariant] :
            entries | std::views::reverse) {
            logs::info("\t{}: {}, {}"sv, entryName, raceString.form,
                vampireRaceString.form.empty() ? "N/A"sv : vampireRaceString.form);

            // Resolve races and reject duplicates.
            const auto* race = LookupRace(raceString.form);
            if (!race) {
                logs::warn("\t\t[SKIP] Race not found"sv);
                continue;
            }
            if (auto itRace = visitedMap.find(race); itRace != visitedMap.end()) {
                logs::warn("\t\t[SKIP] Race already used in {}"sv, itRace->second);
                continue;
            }
            const auto* vampireRace = LookupRace(vampireRaceString.form);
            if (vampireRace) {
                if (auto itRaceVamp = visitedMap.find(vampireRace); itRaceVamp != visitedMap.end()) {
                    logs::warn("\t\t[SKIP] Vampire race already used in {}"sv, itRaceVamp->second);
                    continue;
                }
            }

            auto entry = ConfigEntry{
                .race = ParseRaceProxy(raceString),
                .vampireRace = ParseRaceProxy(vampireRaceString),
                .headPartTypes = ParseHeadPartTypes(headPartVariant)
            };
            ApplyConfigEntry(entry);

            // add to visited map
            std::string_view info{ entryInfoPool.emplace_back(std::format("{}:{}"sv, filename, entryName)) };
            visitedMap.emplace(race, info);
            if (vampireRace) {
                visitedMap.emplace(vampireRace, info);
            }
        }
    }

    auto ConfigProcessor::ParseRaceProxy(const RawRaceProxy& raw) -> RaceProxy
    {
        RaceProxy result{
            .form = LookupRace(raw.form),
            .proxy{},
            .armor = {
                .race = LookupRace(raw.armor.race),
                .variants{} },
        };
        // race not found, no need to parse further
        if (!result.form) {
            return result;
        }
        // race proxy
        result.proxy = LookupRace(raw.proxy);
        // race armor proxy
        if (!raw.armor.variants.empty()) {
            auto& variants = result.armor.variants;
            // reserve space to avoid multiple allocations; similar to allocating all at once and then resizing
            // refer to: https://godbolt.org/z/T9za7v1cb
            variants.reserve(raw.armor.variants.size());
            for (const auto& [slots, form] : raw.armor.variants) {
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
                    variants.emplace_back(varProxy, slotSet.get());
                }
            }
        }
        return result;
    }

    RE::TESRace* ConfigProcessor::LookupRace(const std::string_view form)
    {
        return form.empty() ? nullptr : form::LookupCachedForm(form, formCache);
    }

    void ConfigProcessor::ApplyConfigEntry(ConfigEntry& entry) const
    {
        auto *race = entry.race.form, *vampireRace = entry.vampireRace.form;
        ApplyRaceProxy(entry.race);
        if (vampireRace) {
            ApplyRaceProxy(entry.vampireRace);
            manager::EmplaceVampirismRacePair(race, vampireRace);
        }
        for (const auto& type : entry.headPartTypes) {
            adder.AddRacePair(race, vampireRace, type);
        }
    }

    void ConfigProcessor::ApplyRaceProxy(RaceProxy& proxy)
    {
        manager::EmplaceRaceProxy(proxy.form, proxy.proxy);
        if (auto* armorRace = proxy.armor.race) {
            proxy.form->armorParentRace = armorRace;
        }

        manager::EmplaceArmorRaceProxies(proxy.form, std::move(proxy.armor.variants));
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
