#include <experimental/generator>
#include <spdlog/sinks/basic_file_sink.h>
#include <spdlog/sinks/msvc_sink.h>

#include "configs.h"
#include "hooks.h"

namespace logs = SKSE::log;

namespace detail
{
	using generator_t = std::experimental::generator<bool>;
	static generator_t ProcessMessage()
	{
		// kPostLoad
		auto files = rcs::ini::GetConfigFiles();
		logs::info("{:*^30}", "INI");
		if (files.empty()) {
			logs::warn("No .ini files with _RCS suffix were found within the Data folder, aborting...");
			co_yield false;
		} else {
			logs::info("{:*^30}", "HOOKS");
			rcs::hook::Install();
			co_yield true;
		}
		// kPostPostLoad
		// TODO: add support for mergemapper

		// kDataLoaded
		logs::info("{:*^30}", "CONFIGS");
		co_yield rcs::ini::ParseConfigs(files);
	}
	static std::unique_ptr<generator_t>           handler_ptr{ std::make_unique<generator_t>(ProcessMessage()) };
	static std::unique_ptr<generator_t::iterator> iter_ptr{};

	static inline void initialize_handler()
	{
		iter_ptr = std::make_unique<generator_t::iterator>(handler_ptr->begin());
		if (!(**iter_ptr)) {  // handler return false, should abort
			handler_ptr.reset();
			iter_ptr.reset();
		}
	}

	static inline void call_handler()
	{
		//if (iter_ptr != nullptr) [[likely]] {
		if (iter_ptr != nullptr) {
			(*iter_ptr)++;
			if (*iter_ptr != handler_ptr->end() && **iter_ptr) {  // handler return true, should continue
				return;
			}
		}
		// finally, destory the handler and its iter
		handler_ptr.reset();
		iter_ptr.reset();
	}
}

static void MessageHandler(SKSE::MessagingInterface::Message* a_message)
{
	//static auto should_log_erros{ false };
	//static auto should_look_up_forms{ false };
	switch (a_message->type) {
	case SKSE::MessagingInterface::kPostLoad:
		logs::info("{:*^50}", "DEPENDENCIES");
		detail::initialize_handler();
		/*using func_t = bool(RE::TESObjectREFR* a_thisObj, void* a_param1, void* a_param2, double& a_result);
			RE::FUNCTION_DATA d;
			d.function = RE::FUNCTION_DATA::FunctionID::kGetIsRace;
			d.params[0] = RE::PlayerCharacter::GetSingleton();*/
		break;
	case SKSE::MessagingInterface::kDataLoaded:
		detail::call_handler();
		break;
	default:
		break;
	}
}

static inline void InitLogging()
{
	auto path = logs::log_directory();
	if (!path)
		return;

	*path /= "race-compatibility.log";

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

extern "C" __declspec(dllexport) bool SKSEAPI
	SKSEPlugin_Load(const SKSE::LoadInterface* a_skse)
{
	InitLogging();

	logs::info("race-compatibility is loading...");

	SKSE::Init(a_skse);

	logs::info("race-compatibility loaded.");

	logs::info("Game version : {}", a_skse->RuntimeVersion().string());

	const auto messaging = SKSE::GetMessagingInterface();
	messaging->RegisterListener(MessageHandler);

	return true;
}