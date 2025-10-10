#include "Hooks.h"
#include "RaceManager.h"

#ifdef DETOURS
#	include <windows.h>
#	include <detours.h>
#endif

namespace rcs::hook
{
	namespace
	{
		// forward declare thunk structs
		struct GetIsRace;
		struct SameRace;
#ifdef SKYRIM_SUPPORT_AE
		struct GetPCIsRace;
#endif
		struct IsValidRace;

		// initialize ids
		// VR shared GetIsRace/IsValidRace ids with SE
		template <stl::HasThunk T>
		constexpr std::uint64_t MakeID()
		{
			if constexpr (std::is_same_v<T, GetIsRace>)
				return ID(21028, 21478);
			else if constexpr (std::is_same_v<T, SameRace>)
				return ID(20978, 21428);
#ifdef SKYRIM_SUPPORT_AE
			else if constexpr (std::is_same_v<T, GetPCIsRace>)
				return 21484;
#endif
			else if constexpr (std::is_same_v<T, IsValidRace>)
				return ID(17359, 17757);
			else
				static_assert(false, "Unknown thunk");
		}

#ifdef DETOURS
		template <stl::HasThunk T>
		struct FuncStorage
		{
			static inline decltype(&T::thunk) func{ nullptr };
		};
#endif

		template <stl::HasThunk T>
		void InstallHook()
		{
			const REL::Relocation target{ REL::ID{ MakeID<T>() }, 0 };
#ifdef DETOURS
			FuncStorage<T>::func = reinterpret_cast<decltype(&T::thunk)>(target.address());
			DetourAttach(reinterpret_cast<PVOID*>(&FuncStorage<T>::func),
				reinterpret_cast<PVOID>(T::thunk));
#else
			stl::write_jump_to_thunk<T>(target.address());
#endif
		}

		template <stl::HasThunk... Ts>
		void InstallHooks()
		{
#ifdef DETOURS
			DetourTransactionBegin();
			DetourUpdateThread(GetCurrentThread());
			(InstallHook<Ts>(), ...);
			if (auto error = DetourTransactionCommit(); error != NO_ERROR) {
				logs::error("DetourTransactionCommit failed with error code: {}", error);
			}
#else
			(InstallHook<Ts>(), ...);
#endif
		}

#define LOG_TO_CONSOLE(a_name)                                               \
	if (RE::GetStaticTLSData()->consoleMode) {                               \
		RE::ConsoleLog::GetSingleton()->Print(#a_name " >> %0.2lf", result); \
	}

		// thunk for GetIsRace
		struct GetIsRace
		{
			static bool thunk(const RE::TESObjectREFR* obj, const RE::TESForm* race_form, [[maybe_unused]] void* unused, double& result)
			{
				result = 0.0;
				// check if obj is an NPC and has the same race
				if (obj && race_form) {
					const auto npc = obj->data.objectReference->As<RE::TESNPC>();
					const auto race = race_form->As<RE::TESRace>();
					if (npc && race && manager::GetIsRaceByProxy(npc->race, race)) {
						result = 1.0;
					}
				}
#ifdef DETOURS
				if (result == 0.0) {
					return FuncStorage<GetIsRace>::func(obj, race_form, unused, result);
				}
#endif
				LOG_TO_CONSOLE(GetIsRace)
				return true;
			}
		};

		// thunk for SameRace
		struct SameRace
		{
			static bool thunk(const RE::TESObjectREFR* obj1, const RE::TESObjectREFR* obj2, [[maybe_unused]] void* unused, double& result)
			{
				result = 0.0;
				if (obj1 && obj2) {
					// check if obj1 and obj2 are NPC
					const auto npc1 = obj1->data.objectReference->As<RE::TESNPC>();
					const auto npc2 = obj2->data.objectReference->As<RE::TESNPC>();
					if (npc1 && npc2 &&
						(manager::GetIsRaceByProxy(npc1->race, npc2->race) ||
							manager::GetIsRaceByProxy(npc2->race, npc1->race))) {
						result = 1.0;
					}
				}
#ifdef DETOURS
				if (result == 0.0) {
					return FuncStorage<SameRace>::func(obj1, obj2, unused, result);
				}
#endif
				LOG_TO_CONSOLE(SameRace)
				return true;
			}
		};

#ifdef SKYRIM_SUPPORT_AE
		// thunk for GetPCIsRace
		struct GetPCIsRace
		{
			static bool thunk([[maybe_unused]] const RE::TESObjectREFR* unused1, const RE::TESForm* race_form, [[maybe_unused]] void* unused2, double& result)
			{
				result = 0.0;
				if (const auto pc = RE::PlayerCharacter::GetSingleton(); pc && race_form) {
					if (const auto race = race_form->As<RE::TESRace>();
						race && manager::GetIsRaceByProxy(pc->race, race)) {
						result = 1.0;
					}
				}
#	ifdef DETOURS
				if (result == 0.0) {
					return FuncStorage<GetPCIsRace>::func(unused1, race_form, unused2, result);
				}
#	endif
				LOG_TO_CONSOLE(GetIsRace)
				return true;
			}
		};
#endif
#undef LOG_TO_CONSOLE

		// thunk for TESObjectARMA::IsValidRace
		struct IsValidRace
		{
			static bool thunk(const RE::TESObjectARMA* armor_addon, const RE::TESRace* race)
			{
				//auto* source_race = !race || !race->armorParentRace ? race : race->armorParentRace;
				if (!race) {
					return false;
				}
				// race not null
				auto* armorParentRace = manager::GetArmorParentRaceProxy(armor_addon, race);
				if (const auto* armorRace = armor_addon->race;
					race == armorRace || armorParentRace == armorRace) {
					return true;
				}
				const auto result = std::ranges::any_of(armor_addon->additionalRaces,
					[&](const auto& target_race) { return race == target_race || armorParentRace == target_race; });
#ifdef DETOURS
				if (!result) {
					return FuncStorage<IsValidRace>::func(armor_addon, race);
				}
#endif
				return result;
			}
		};
	}

	void TryInstall()
	{
#ifdef DETOURS
		logs::info("Using Detours"sv);
#endif

		if (!manager::raceProxies.empty()) {
#ifdef SKYRIM_SUPPORT_AE
			InstallHooks<GetIsRace, SameRace, GetPCIsRace>();
			logs::info("Installed hooks for GetIsRace, SameRace and GetPCIsRace"sv);
#else
			InstallHooks<GetIsRace, SameRace>();
			logs::info("Installed hooks for GetIsRace and SameRace"sv);
#endif
		}

		if (!manager::armorRaceProxies.empty()) {
			InstallHooks<IsValidRace>();
			logs::info("Installed hook for TESObjectARMA::IsValidRace"sv);
		}
	}
}  // namespace rcs::hook