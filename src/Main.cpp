#include <spdlog/sinks/basic_file_sink.h>
#include <spdlog/sinks/msvc_sink.h>

#include "Configs.h"
#include "Hooks.h"
#include "Papyrus.h"

namespace logs = SKSE::log;

#ifdef SKYRIM_SUPPORT_AE
extern "C" __declspec(dllexport) constinit auto SKSEPlugin_Version = [] {
	SKSE::PluginVersionData v;
	v.PluginVersion({ rcs::VERSION_MAJOR, rcs::VERSION_MINOR, rcs::VERSION_ALTER, 0 });
	v.PluginName(rcs::PROJECT_NAME);
	v.AuthorName("shuc");
	v.UsesAddressLibrary();
	v.UsesUpdatedStructs();
	v.CompatibleVersions({ SKSE::RUNTIME_LATEST });
	return v;
}();
#else
extern "C" __declspec(dllexport) bool SKSEPlugin_Query(const SKSE::QueryInterface* a_skse, SKSE::PluginInfo* a_info)
{
	a_info->infoVersion = SKSE::PluginInfo::kVersion;
	a_info->name = rcs::PROJECT_NAME.data();
	a_info->version = REL::Version{ rcs::VERSION_MAJOR, rcs::VERSION_MINOR, rcs::VERSION_ALTER, 0 }.pack();

	if (a_skse->IsEditor()) {
		SKSE::log::critical("Loaded in editor, marking as incompatible");
		return false;
	}

	const auto ver = a_skse->RuntimeVersion();
	if (ver < SKSE::RUNTIME_1_5_39) {
		SKSE::log::critical("Unsupported runtime version {}", ver.string());
		return false;
	}

	return true;
}
#endif

static inline void InitLogging()
{
	auto path = logs::log_directory();
	if (!path)
		return;

	*path /= std::format("{}.log", rcs::PROJECT_NAME);

	spdlog::sinks_init_list sinks{
		std::make_shared<spdlog::sinks::basic_file_sink_mt>(path->string(), true),
		std::make_shared<spdlog::sinks::msvc_sink_mt>()
	};

	auto logger = std::make_shared<spdlog::logger>("global", sinks);
	logger->set_level(spdlog::level::info);
	logger->flush_on(spdlog::level::info);

	spdlog::set_default_logger(std::move(logger));
	spdlog::set_pattern("[%^%L%$] %v");
}

static void MessageHandler(SKSE::MessagingInterface::Message* a_message)
{
	switch (a_message->type) {
	case SKSE::MessagingInterface::kDataLoaded:
		{
			logs::info("{:*^50}", "DEPENDENCIES");
			const auto start = std::chrono::system_clock::now();
			const auto should_install_hooks{ rcs::config::TryReadAndApplyConfigs() };
			logs::info("Loaded configs in {} ms",
				std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now() - start).count());
			if (should_install_hooks) {
				logs::info("{:*^30}", "HOOKS");
				rcs::hook::TryInstall();
			}
			break;
		}
	default:
		break;
	}
}

extern "C" __declspec(dllexport) bool SKSEAPI
	SKSEPlugin_Load(const SKSE::LoadInterface* a_skse)
{
	InitLogging();

	SKSE::Init(a_skse);
	SKSE::GetMessagingInterface()->RegisterListener(MessageHandler);
	logs::info("Build: {}", rcs::VERSION_BUILD);
	logs::info("Game version : {}", a_skse->RuntimeVersion().string());

	logs::info("{:*^50}", "PAPYRUS");
	SKSE::GetPapyrusInterface()->Register(rcs::papyrus::Bind);

	return true;
}