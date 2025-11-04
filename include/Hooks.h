#pragma once

#ifdef DETOURS
#	include <windows.h>
#	include <detours.h>
#endif

namespace rcs::hook
{
	template <typename T>
	concept HasThunk = requires {
		T::Thunk;
	} && std::is_function_v<std::remove_pointer_t<decltype(T::Thunk)>>;

	template <typename T>
	concept HasPreInstall = requires {
		T::PreInstall;
	} && std::is_function_v<std::remove_pointer_t<decltype(T::PreInstall)>>;

	template <typename T>
	concept HasID = requires {
		T::id;
	} && std::is_same_v<decltype(T::id), const REL::ID>;

	template <typename T>
	concept HasOffset = requires {
		T::offset;
	} && std::is_same_v<decltype(T::offset), const std::ptrdiff_t>;

	template <typename T>
	concept Hookable = HasThunk<T> && HasID<T>;

	// Incompatible with hooks at the same position
	template <HasThunk T>
	void write_jump_to_thunk(std::uintptr_t a_src)
	{
#pragma pack(push, 1)
		struct Assembly
		{
			// 0x0: jmp [rip + 0]
			// 0x6: target
			std::uint8_t  jmp{ 0xFF };                                        // 0x0
			std::uint8_t  modrm{ 0x25 };                                      // 0x1
			std::int32_t  disp{ 0 };                                          // 0x2
			std::uint64_t addr{ reinterpret_cast<std::uint64_t>(T::Thunk) };  // 0x6
		} const assembly{};
		static_assert(offsetof(Assembly, jmp) == 0x0);
		static_assert(offsetof(Assembly, modrm) == 0x1);
		static_assert(offsetof(Assembly, disp) == 0x2);
		static_assert(offsetof(Assembly, addr) == 0x6);
		static_assert(sizeof(Assembly) == 0xE);
#pragma pack(pop)

		REL::safe_write(a_src, &assembly, sizeof(assembly));
	}

	template <HasThunk T>
	void write_call_to_thunk(std::uintptr_t a_src)
	{
#pragma pack(push, 1)
		struct Assembly
		{
			// 0x0: mov rax, addr
			// 0xA: call rax
			std::uint8_t  rex{ 0x48 };                                        // 0x0
			std::uint8_t  mov{ 0xB8 };                                        // 0x1
			std::uint64_t addr{ reinterpret_cast<std::uint64_t>(T::Thunk) };  // 0x2
			std::uint8_t  call{ 0xFF };                                       // 0xA
			std::uint8_t  modrm{ 0xD0 };                                      // 0xB
		} const assembly{};
		static_assert(offsetof(Assembly, rex) == 0x0);
		static_assert(offsetof(Assembly, mov) == 0x1);
		static_assert(offsetof(Assembly, addr) == 0x2);
		static_assert(offsetof(Assembly, call) == 0xA);
		static_assert(offsetof(Assembly, modrm) == 0xB);
		static_assert(sizeof(Assembly) == 0xC);
#pragma pack(pop)
		REL::safe_write(a_src, &assembly, sizeof(assembly));
	}

	template <typename... Ts>
	consteval auto make_hook_message_array()
	{
		constexpr auto count = sizeof...(Ts);
		static_assert(count);

		constexpr auto prefix = [] {
			if constexpr (count > 1) {
				return std::to_array("Installed hooks for ");
			} else {
				return std::to_array("Installed hook for ");
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
		static constexpr auto MESSAGE = make_hook_message_array<Ts...>();
		return std::string_view{ MESSAGE.data(), MESSAGE.size() - 1 };
	}

#ifdef DETOURS
	template <Hookable T>
	struct FuncStorage
	{
		static inline decltype(&T::Thunk) func{ nullptr };
	};
#endif

	template <Hookable T>
	void InstallHook()
	{
		if constexpr (HasPreInstall<T>) {
			T::PreInstall();
		}
		constexpr auto offset = [] {
			if constexpr (HasOffset<T>) {
				return T::offset;
			} else {
				return 0;
			}
		}();
		const REL::Relocation src{ T::id, offset };
#ifdef DETOURS
		FuncStorage<T>::func = reinterpret_cast<decltype(&T::Thunk)>(src.address());
		DetourAttach(reinterpret_cast<PVOID*>(&FuncStorage<T>::func), reinterpret_cast<PVOID>(T::Thunk));
#else
		write_jump_to_thunk<T>(src.address());
#endif

#ifndef NDEBUG
		logs::info("Installed hook for {} at address: 0x{:X}",
			std::string_view(stl::struct_name_for<T>.data(), stl::struct_name_for<T>.size() - 1),
			src.address());
#endif
	}

	template <Hookable... Ts>
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

	void TryInstall();
}