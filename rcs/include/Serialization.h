#pragma once

#include "RaceManager.h"

namespace rcs::serialization
{
    constexpr std::uint32_t PLUGIN_ID = 0x00534352;    // RCS
    constexpr std::uint32_t ORIGIN_RACE = 0x4749524F;  // ORIG
    constexpr std::uint32_t RECORD_VERSION = 1;

    struct OriginRaceRecord
    {
        RE::FormID actor;
        RE::FormID race;
    };

    inline void SaveOriginRaces(SKSE::SerializationInterface* a_interface)
    {
        // logs::info("{:*^30}"sv, "SAVE ORIGIN RACES"sv);
        for (const auto& [actor, race] : manager::originRaces) {
            if (!a_interface->WriteRecord(ORIGIN_RACE, RECORD_VERSION, OriginRaceRecord{ actor, race->GetFormID() })) {
                logs::error("Failed to save origin race record for actor 0x{:08X}"sv, actor);
                return;
            }
        }
        logs::info("Origin race records saved: {}"sv, manager::originRaces.size());
    }

    inline void LoadOriginRaces(SKSE::SerializationInterface* a_interface)
    {
        // logs::info("{:*^30}"sv, "LOAD ORIGIN RACES"sv);
        manager::originRaces.clear();
        std::uint32_t type, version, length;
        while (a_interface->GetNextRecordInfo(type, version, length)) {
            if (type != ORIGIN_RACE || version != RECORD_VERSION || length != sizeof(OriginRaceRecord)) {
                logs::warn("\t[SKIP] Unsupported record: type 0x{:08X}, version {}, length {}"sv, type, version, length);
                continue;
            }
            OriginRaceRecord record{};
            if (a_interface->ReadRecordData(record) != sizeof(record)) {
                logs::error("Failed to load origin race record"sv);
                continue;
            }
            RE::FormID actor, race;
            if (a_interface->ResolveFormID(record.actor, actor) &&
                a_interface->ResolveFormID(record.race, race)) {
                if (const auto* originRace = RE::TESForm::LookupByID<RE::TESRace>(race)) {
                    manager::originRaces.insert_or_assign(actor, originRace);
                } else {
                    logs::warn("\t[SKIP] Race 0x{:08X} not found for actor 0x{:08X}"sv, race, actor);
                }
            } else {
                logs::warn("\t[SKIP] Failed to resolve actor 0x{:08X} or race 0x{:08X}"sv, record.actor, record.race);
            }
        }
        logs::info("Origin race records loaded: {}"sv, manager::originRaces.size());
    }

    inline void RevertOriginRaces([[maybe_unused]] SKSE::SerializationInterface* a_interface)
    {
        manager::originRaces.clear();
        logs::info("Cleared origin race records"sv);
    }

    inline void Bind(const SKSE::SerializationInterface* a_interface)
    {
        a_interface->SetUniqueID(PLUGIN_ID);
        a_interface->SetSaveCallback(SaveOriginRaces);
        a_interface->SetLoadCallback(LoadOriginRaces);
        a_interface->SetRevertCallback(RevertOriginRaces);
        logs::info("Registered serialization callbacks"sv);
    }
}