#include <spdlog/sinks/basic_file_sink.h>
#ifndef NDEBUG
#    include <spdlog/sinks/msvc_sink.h>
#endif

#include "Config.h"
#include "Hook.h"
#include "Papyrus.h"

namespace
{
    void InitLogging()
    {
        auto path = SKSE::log::log_directory();
        if (!path)
            return;

        *path /= std::format("{}.log", rcs::PROJECT_NAME);

        spdlog::sinks_init_list sinks{
            std::make_shared<spdlog::sinks::basic_file_sink_mt>(path->string(), true),
#ifndef NDEBUG
            std::make_shared<spdlog::sinks::msvc_sink_mt>()
#endif
        };

        auto logger = std::make_shared<spdlog::logger>("global", sinks);
        logger->set_level(spdlog::level::info);
        logger->flush_on(spdlog::level::info);

        spdlog::set_default_logger(std::move(logger));
        spdlog::set_pattern("[%^%L%$] %v");
    }

    void MessageHandler(SKSE::MessagingInterface::Message* a_message)
    {
        switch (a_message->type) {
        case SKSE::MessagingInterface::kDataLoaded:
            {
                logs::info("{:*^50}"sv, "DEPENDENCIES"sv);
                if (rcs::config::TryProcessConfigs()) {
                    rcs::hook::TryInstall();
                }
                break;
            }
        default:
            break;
        }
    }
}

#ifdef SKYRIM_SUPPORT_AE
extern "C" __declspec(dllexport) constinit auto SKSEPlugin_Version = [] {
    SKSE::PluginVersionData v;
    v.PluginVersion({ rcs::VERSION_MAJOR, rcs::VERSION_MINOR, rcs::VERSION_ALTER, 0 });
    v.PluginName(rcs::PROJECT_NAME);
    v.AuthorName("shuc");
    v.UsesAddressLibrary();
    v.UsesUpdatedStructs();
#    ifdef SKYRIM_AE_1_6_1170
    v.CompatibleVersions({ SKSE::RUNTIME_SSE_1_6_1170, SKSE::RUNTIME_SSE_1_6_1179 });
    v.MinimumRequiredXSEVersion({ 2, 2, 5, 0 });
#    else
    v.CompatibleVersions({ SKSE::RUNTIME_SSE_LATEST });
    v.MinimumRequiredXSEVersion({ 2, 3, 0, 0 });
#    endif
    return v;
}();
#else
#    ifdef SKYRIMVR
#        define LOG_CRITICAL SKSE::log::critical
#    else
#        define LOG_CRITICAL REX::CRITICAL
#    endif
extern "C" __declspec(dllexport) bool SKSEPlugin_Query(const SKSE::QueryInterface* a_skse, SKSE::PluginInfo* a_info)
{
    a_info->infoVersion = SKSE::PluginInfo::kVersion;
    a_info->name = rcs::PROJECT_NAME.data();
    a_info->version = REL::Version{ rcs::VERSION_MAJOR, rcs::VERSION_MINOR, rcs::VERSION_ALTER, 0 }.pack();

    if (a_skse->IsEditor()) {
        LOG_CRITICAL("Loaded in editor, marking as incompatible");
        return false;
    }

    const auto ver = a_skse->RuntimeVersion();

    if (ver
#    ifdef SKYRIMVR
        != SKSE::RUNTIME_VR_1_4_15_1
#    else
        < SKSE::RUNTIME_SSE_1_5_39
#    endif
    ) {
        LOG_CRITICAL("Unsupported runtime version {}", ver.string());
        return false;
    }

    return true;
}
#    undef LOG_CRITICAL
#endif

extern "C" __declspec(dllexport) bool __cdecl
    SKSEPlugin_Load(const SKSE::LoadInterface* a_skse)
{
    InitLogging();

    SKSE::Init(a_skse);
    SKSE::GetMessagingInterface()->RegisterListener(MessageHandler);
    logs::info("Build: {}"sv, rcs::VERSION_BUILD);
    logs::info("Game version : {}"sv, a_skse->RuntimeVersion().string());

    logs::info("{:*^50}"sv, "PAPYRUS"sv);
    SKSE::GetPapyrusInterface()->Register(rcs::papyrus::Bind);

    return true;
}
