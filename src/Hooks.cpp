#include "Hooks.h"
#include "RaceManager.h"

#ifdef DETOURS
#	include <windows.h>
#	include <detours.h>
#endif

namespace
{
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
	constexpr auto MakeHookMessage()
	{
		static constexpr auto msg_array = make_hook_message_array<Ts...>();
		return std::string_view{ msg_array.data(), msg_array.size() - 1 };
	}

	template <stl::Hookable T>
	void InstallHook()
	{
		if constexpr (stl::HasPreInstall<T>) {
			T::PreInstall();
		}
		constexpr auto offset = [] {
			if constexpr (stl::HasOffset<T>) {
				return T::offset;
			} else {
				return 0;
			}
		}();
		const REL::Relocation src{ T::id, offset };
#ifdef DETOURS
		FuncStorage<T>::func = reinterpret_cast<decltype(&T::Thunk)>(src.address());
		DetourAttach(reinterpret_cast<PVOID*>(&FuncStorage<T>::func),
			reinterpret_cast<PVOID>(T::Thunk));
#else
		stl::write_jump_to_thunk<T>(src.address());
#endif
#ifndef NDEBUG
		logs::info("Installed hook for {} at address: 0x{:X}",
			std::string_view(stl::struct_name_for<T>.data(), stl::struct_name_for<T>.size() - 1),
			src.address());
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

namespace
{
	using namespace rcs;

#ifdef DETOURS
	template <stl::Hookable T>
	struct FuncStorage
	{
		static inline decltype(&T::Thunk) func{ nullptr };
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

			static bool Thunk(const RE::TESObjectREFR* obj, const RE::TESForm* race_form, [[maybe_unused]] void* unused, double& result)
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

			static bool Thunk(const RE::TESObjectREFR* obj1, const RE::TESObjectREFR* obj2, [[maybe_unused]] void* unused, double& result)
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
#	ifndef DETOURS
			// after loading player character into register
			static constexpr std::ptrdiff_t offset = 0x7;

			static void PreInstall()
			{
				const auto src = REL::Relocation{ id, 0 }.address();
				const auto pc = REL::Relocation{ RE::Offset::PlayerCharacter::Singleton, 0 }.address();
#		pragma pack(push, 1)
				struct Assembly
				{
					// mov r8,QWORD PTR [rip + (disp)] # address of PlayerCharacter*
					// 4c 8b 05 c1 9f e5 02, for example in 1.6.1170
					// rcx is marked [[maybe_unused]], but the test shows that a value is still loaded into it.
					std::uint8_t rex{ 0x4c };    // 0x0
					std::uint8_t mov{ 0x8b };    // 0x1
					std::uint8_t modrm{ 0x05 };  // 0x2, r8
					std::int32_t disp;           // 0x3
				} const assembly{
					.disp = static_cast<std::int32_t>(pc - (src + offset))
				};
				static_assert(offsetof(Assembly, rex) == 0x0);
				static_assert(offsetof(Assembly, mov) == 0x1);
				static_assert(offsetof(Assembly, modrm) == 0x2);
				static_assert(offsetof(Assembly, disp) == 0x3);
				static_assert(sizeof(Assembly) == offset);
#		pragma pack(pop)

				REL::safe_write(src, &assembly, sizeof(assembly));
			}
#	endif

			static bool Thunk([[maybe_unused]] const RE::TESObjectREFR* unused1, const RE::TESForm* race_form, [[maybe_unused]] void* unused2, double& result)
			{
				result = 0.0;
#	ifdef DETOURS
				const auto pc = RE::PlayerCharacter::GetSingleton();
#	else
				// used custom assembly to get PlayerCharacter*
				const auto pc = reinterpret_cast<const RE::PlayerCharacter*>(unused2);
#	endif
				if (pc && race_form) {
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
		struct IsValidRace
		{
			static constexpr auto id = RELOCATION_ID(17359, 17757);

			static bool Thunk(const RE::TESObjectARMA* armor_addon, const RE::TESRace* race)
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