#include "Configs.h"

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
            if (entry.is_regular_file() && entry.path().extension() == ".json"sv) {
                result.emplace_back(entry.path());
            }
        }
        return result;
    }

    void ConfigProcessor::ProcessConfigFile(const std::filesystem::path& path)
    {
        const auto filename{ path.filename().string() };
        auto       buffer = glz::file_to_buffer(path.string());
        const auto content = glz::read_json<RawConfigFileContent>(buffer);
        if (!content) {
            logs::error("Failed to read {} for \"{}\""sv, filename, glz::format_error(content));
            return;
        }
        ProcessFileEntries(filename, content.value().entries);
    }

    void ConfigProcessor::ProcessFileEntries(std::string_view filename, const std::vector<RawConfigEntry>& entries)
    {
        logs::info("{}:"sv, filename);
        for (const auto& [entryName, raceString, vampireRaceString, headPartString] :
            entries | std::views::reverse) {
            logs::info("\t{}: {}, {}"sv, entryName, raceString.form,
                vampireRaceString.form.empty() ? "N/A"sv : vampireRaceString.form);

            // parse raw config entry
            auto entry = ConfigEntry{
                .race = ParseRaceProxy(raceString),
                .vampireRace = ParseRaceProxy(vampireRaceString),
                .headPart = manager::headpart::StringToHeadPartType(headPartString)
            };

            // check for duplicate
            const auto *race = entry.race.form, *vampireRace = entry.vampireRace.form;
            if (!race) {
                logs::warn("\t\t[SKIP] Race not found"sv);
                continue;
            }
            if (auto itRace = visitedMap.find(race); itRace != visitedMap.end()) {
                logs::warn("\t\t[SKIP] Race already used in {}"sv, itRace->second);
                continue;
            }
            if (vampireRace) {
                if (auto itRaceVamp = visitedMap.find(vampireRace); itRaceVamp != visitedMap.end()) {
                    logs::warn("\t\t[SKIP] Vampire race already used in {}"sv, itRaceVamp->second);
                    continue;
                }
            }

            // no duplicate, apply entry
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
            .armor = { .race = LookupRace(raw.armor.race) }
        };
        // race proxy
        for (const auto& proxy : raw.proxies) {
            if (const auto* race = LookupRace(proxy)) {
                result.proxies.insert(race);
            }
        }
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
                using BipedObjectSlot = RE::BGSBipedObjectForm::BipedObjectSlot;
                auto slotSet = REX::EnumSet<BipedObjectSlot, std::uint32_t>{};
                for (const auto& slot : slots) {
                    if (slot >= 30 && slot <= 61) {
                        slotSet.set(static_cast<BipedObjectSlot>(1u << (slot - 30)));
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
        adder.AddRacePair(race, vampireRace, entry.headPart);
    }

    void ConfigProcessor::ApplyRaceProxy(RaceProxy& proxy)
    {
        manager::EmplaceRaceProxies(proxy.form, std::move(proxy.proxies));
        if (auto* armorRace = proxy.armor.race) {
            proxy.form->armorParentRace = armorRace;
        }

        manager::EmplaceArmorRaceProxies(proxy.form, std::move(proxy.armor.variants));
    }

    bool TryProcessConfigs()
    {
        logs::info("{:*^30}"sv, "CONFIGS"sv);
        ConfigProcessor processor{};
        const auto      start = std::chrono::system_clock::now();
        const auto      result = processor.Run();
        const auto      end = std::chrono::system_clock::now();
        const auto      ms = std::chrono::duration_cast<std::chrono::milliseconds>(end - start).count();
        logs::info("Processed configs in {}ms"sv, ms);
        manager::Summary();
        return result;
    }
}  // namespace rcs::config