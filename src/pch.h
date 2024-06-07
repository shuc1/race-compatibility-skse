#pragma once

#define WIN32_LEAN_AND_MEAN
#define NOMINMAX
#define NOGDI

#include <RE/Skyrim.h>
#include <SKSE/SKSE.h>

namespace logs = SKSE::log;
using namespace std::literals;

namespace stl {
using namespace SKSE::stl;
template <class T>
void write_thunk_call(std::uintptr_t a_src) {
  auto& trampoline = SKSE::GetTrampoline();
  SKSE::AllocTrampoline(14);
  T::func = trampoline.write_call<5>(a_src, T::thunk);
}
}  // namespace stl