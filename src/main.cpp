#include <spdlog/sinks/basic_file_sink.h>
#include <spdlog/sinks/msvc_sink.h>
#include "SKSE/API.h"
#include "SKSE/Interfaces.h"
#include "hooks.h"

namespace logs = SKSE::log;

void InitLogging() {
  auto path = logs::log_directory();
  if (!path)
    return;

  *path /= "race-compatibility.log";

  spdlog::sinks_init_list sinks{
      std::make_shared<spdlog::sinks::basic_file_sink_mt>(path->string(), true),
      std::make_shared<spdlog::sinks::msvc_sink_mt>()};

  auto logger = std::make_shared<spdlog::logger>("global", sinks);
  logger->set_level(spdlog::level::info);
  logger->flush_on(spdlog::level::info);

  spdlog::set_default_logger(std::move(logger));
  spdlog::set_pattern("[%^%L%$] %v");
}

void MessageHandler(SKSE::MessagingInterface::Message* a_message) {
  switch (a_message->type) {
    case SKSE::MessagingInterface::kPostLoad:
      // logs::info("Input loaded.");
      Hooks::Install();
      break;
    default:
      break;
  }
}

extern "C" __declspec(dllexport) bool SKSEAPI
SKSEPlugin_Load(const SKSE::LoadInterface* a_skse) {
  InitLogging();

  logs::info("race-compatibility is loading...");

  SKSE::Init(a_skse);
  // TODO: calc trampline size
  SKSE::AllocTrampoline(1 << 10);

  logs::info("race-compatibility loaded.");

  logs::info("Game version : {}", a_skse->RuntimeVersion().string());

  const auto messaging = SKSE::GetMessagingInterface();
  messaging->RegisterListener(MessageHandler);

  return true;
}