#include "Hooks.h"
#include "RaceManager.h"

namespace
{
	using namespace rcs;

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
#		pragma pack(push, 1)
			// custom assembly to get PlayerCharacter*
			struct Assembly
			{
				// mov r8,QWORD PTR [rip + (disp)] # address of PlayerCharacter*
				// 4c 8b 05 c1 9f e5 02, for example in 1.6.1170
				// rcx is unused, but the test shows that a value is still loaded into it.
				std::uint8_t rex{ 0x4c };    // 0x0
				std::uint8_t mov{ 0x8b };    // 0x1
				std::uint8_t modrm{ 0x05 };  // 0x2, r8
				std::int32_t disp;           // 0x3
			};
			static_assert(offsetof(Assembly, rex) == 0x0);
			static_assert(offsetof(Assembly, mov) == 0x1);
			static_assert(offsetof(Assembly, modrm) == 0x2);
			static_assert(offsetof(Assembly, disp) == 0x3);
			static_assert(sizeof(Assembly) == 0x7);
#		pragma pack(pop)

			static constexpr std::ptrdiff_t offset = sizeof(Assembly);  // after loading player character into register

			static void PreInstall()
			{
				const auto src = REL::Relocation{ id, 0 }.address();
				const auto pc = REL::Relocation{ RE::Offset::PlayerCharacter::Singleton, 0 }.address();
				const auto assembly = Assembly{ .disp = static_cast<std::int32_t>(pc - (src + sizeof(Assembly))) };

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
				const auto pc = static_cast<const RE::PlayerCharacter*>(unused2);
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
		logs::info("{:*^30}", "HOOKS");
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