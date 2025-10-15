#include "Hooks.h"
#include "RaceManager.h"

#ifdef DETOURS
#	include <windows.h>
#	include <detours.h>
#endif

namespace
{
	using namespace rcs;
#ifdef DETOURS
	template <stl::Hookable T>
	struct FuncStorage
	{
		static inline decltype(&T::thunk) func{ nullptr };
	};
#endif

	namespace
	{
#define LOG_TO_CONSOLE(a_name)                                               \
	if (RE::GetStaticTLSData()->consoleMode) {                               \
		RE::ConsoleLog::GetSingleton()->Print(#a_name " >> %0.2lf", result); \
	}

		// thunk for GetIsRace
		struct GetIsRace
		{
			// VR shared GetIsRace/IsValidRace ids with SE
			static constexpr auto id = RELOCATION_ID(21028, 21478);

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
			static constexpr auto id = RELOCATION_ID(20978, 21428);

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
			static constexpr auto id = REL::ID(21484);

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
	}

	// thunk for TESObjectARMA::IsValidRace
	namespace TESObjectARMA
	{
		using namespace rcs;
		struct IsValidRace
		{
			static constexpr auto id = RELOCATION_ID(17359, 17757);

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

	template <typename... Ts>
	consteval auto make_hook_message_array()
	{
		constexpr auto count = sizeof...(Ts);
		static_assert(count);

		constexpr auto prefix = [] {
			if constexpr (count > 1) {
				return std::array<char, 21>{ "Installed hooks for " };
			} else {
				return std::array<char, 20>{ "Installed hook for " };
			}
		}();
		constexpr auto ps = prefix.size();
		constexpr auto size = ps + (stl::struct_name_for<Ts>.size() + ... + (count - 2));
		auto           result = std::array<char, size>{};
		std::copy_n(prefix.begin(), ps - 1, result.begin());

		// concat struct names
		std::size_t pos = ps - 1;
		([&] {
			constexpr auto tn = stl::struct_name_for<Ts>;
			std::copy_n(tn.begin(), tn.size() - 1, std::next(result.begin(), pos));
			pos += tn.size() - 1;
			if (pos != size - 1) {
				result[pos++] = ',';
				result[pos++] = ' ';
			}
		}(),
			...);
		return result;
	}

	template <typename... Ts>
	// consteval auto MakeHookMessage()
	constexpr auto MakeHookMessage()
	{
		// constexpr auto& msg_array = hook_msg_array_for<Ts...>;
		static constexpr auto msg_array = make_hook_message_array<Ts...>();
		return std::string_view{ msg_array.data(), msg_array.size() - 1 };
	}

	template <stl::Hookable T>
	void InstallHook()
	{
		const REL::Relocation target{ T::id, 0 };
#ifdef DETOURS
		FuncStorage<T>::func = reinterpret_cast<decltype(&T::thunk)>(target.address());
		DetourAttach(reinterpret_cast<PVOID*>(&FuncStorage<T>::func),
			reinterpret_cast<PVOID>(T::thunk));
#else
		stl::write_jump_to_thunk<T>(target.address());
#endif
	}

	template <stl::Hookable... Ts>
	void InstallHooks()
	{
#ifdef DETOURS
		DetourTransactionBegin();
		DetourUpdateThread(GetCurrentThread());
		(InstallHook<Ts>(), ...);
		if (auto error = DetourTransactionCommit(); error != NO_ERROR) {
			logs::error("DetourTransactionCommit failed with error code: {}", error);
			return;
		}
#else
		(InstallHook<Ts>(), ...);
#endif
		logs::info(MakeHookMessage<Ts...>());
	}
}

namespace rcs::hook
{
	void TryInstall()
	{
#ifdef DETOURS
		logs::info("Using Detours"sv);
#endif

		if (!manager::raceProxies.empty()) {
#ifdef SKYRIM_SUPPORT_AE
			InstallHooks<GetIsRace, SameRace, GetPCIsRace>();
#else
			InstallHooks<GetIsRace, SameRace>();
#endif
		}

		if (!manager::armorRaceProxies.empty()) {
			InstallHooks<TESObjectARMA::IsValidRace>();
		}
	}
}  // namespace rcs::hook