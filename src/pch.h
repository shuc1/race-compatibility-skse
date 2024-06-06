#pragma once

#include <RE/Skyrim.h>
#include <SKSE/SKSE.h>

namespace logs = SKSE::log;
using namespace std::literals;

namespace stl {
using namespace SKSE::stl;
template <class T>
void write_thunk_call(std::uintptr_t a_src) {
  auto& trampoline = SKSE::GetTrampoline();
  // SKSE::AllocTrampoline(1 << 10);
  T::func = trampoline.write_call<5>(a_src, T::thunk);
}
}  // namespace stl