#pragma once

#ifdef DETOURS
#    include <windows.h>
#    include <detours.h>
#endif

namespace rcs::hook
{
    template <typename T>
    concept HasJmpThunk = requires {
        T::JmpThunk;
        requires std::is_function_v<std::remove_pointer_t<decltype(T::JmpThunk)>>;
    };

    template <typename T>
    concept HasCallThunk = requires {
        T::CallThunk;
        requires std::is_function_v<std::remove_pointer_t<decltype(T::CallThunk)>>;
    };

    template <typename T>
    concept HasPreInstall = requires {
        T::PreInstall;
        requires std::is_function_v<std::remove_pointer_t<decltype(T::PreInstall)>>;
    };

    template <typename T>
    concept HasID = requires {
        requires std::same_as<decltype(T::id), const REL::ID>;
    };

    template <typename T>
    concept HasOffset = requires {
        requires std::same_as<decltype(T::offset), const std::ptrdiff_t>;
    };

    template <typename T>
    concept Hookable = (HasJmpThunk<T> != HasCallThunk<T>) && HasID<T>;

    // Incompatible with hooks at the same position
    template <HasJmpThunk T>
    void WriteJumpToThunk(std::uintptr_t a_src)
    {
#pragma pack(push, 1)
        struct Assembly
        {
            // 0x0: jmp [rip + 0]
            // 0x6: target
            std::uint8_t  jmp{ 0xFF };                                           // 0x0
            std::uint8_t  modrm{ 0x25 };                                         // 0x1
            std::int32_t  disp{ 0 };                                             // 0x2
            std::uint64_t addr{ reinterpret_cast<std::uint64_t>(T::JmpThunk) };  // 0x6
        } const assembly{};
        static_assert(offsetof(Assembly, jmp) == 0x0);
        static_assert(offsetof(Assembly, modrm) == 0x1);
        static_assert(offsetof(Assembly, disp) == 0x2);
        static_assert(offsetof(Assembly, addr) == 0x6);
        static_assert(sizeof(Assembly) == 0xE);
#pragma pack(pop)

#ifdef SKYRIMVR
        REL::safe_write(a_src, &assembly, sizeof(assembly));
#else
        REL::WriteSafe(a_src, &assembly, sizeof(assembly));
#endif
    }

    template <HasCallThunk T>
    auto WriteCallToThunk(std::uintptr_t a_src) -> std::uintptr_t
    {
#ifdef SKYRIMVR
        static SKSE::Trampoline trampoline;
#else
        static REL::Trampoline trampoline;
#endif
        trampoline.create(14);
        return trampoline.write_call<5>(a_src, T::CallThunk);
    }

    template <typename... Ts>
    consteval auto MakeHookMessageArray()
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
        static constexpr auto MESSAGE = MakeHookMessageArray<Ts...>();
        return std::string_view{ MESSAGE.data(), MESSAGE.size() - 1 };
    }

#ifdef DETOURS
    template <Hookable T>
    struct FuncStorage
    {
        static inline auto func = [] {
            if constexpr (HasCallThunk<T>) {
                return static_cast<decltype(&T::CallThunk)>(nullptr);
            } else {
                return static_cast<decltype(&T::JmpThunk)>(nullptr);
            }
        }();
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
        if constexpr (HasCallThunk<T>) {
            FuncStorage<T>::func = reinterpret_cast<decltype(FuncStorage<T>::func)>(WriteCallToThunk<T>(src.address()));
        } else {
            FuncStorage<T>::func = reinterpret_cast<decltype(FuncStorage<T>::func)>(src.address());
            DetourAttach(reinterpret_cast<PVOID*>(&FuncStorage<T>::func), reinterpret_cast<PVOID>(T::JmpThunk));
        }
#else
        if constexpr (HasCallThunk<T>) {
            WriteCallToThunk<T>(src.address());
        } else {
            WriteJumpToThunk<T>(src.address());
        }
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

    void Install();
}