-- v2025-5-1
-- set minimum xmake version
-- set_xmakever("2.8.2")

-- set project
-- set_project("commonlib")
-- set_arch("x64")
-- set_languages("c++23")
-- set_warnings("allextra")
-- set_encodings("utf-8")

-- add rules
add_rules("mode.debug", "mode.releasedbg")

-- define options
option("commonlib_ini", function()
    set_default(false)
    set_description("enable REX::INI settings support")
end)

option("commonlib_json", function()
    set_default(false)
    set_description("enable REX::JSON settings support")
end)

option("commonlib_toml", function()
    set_default(false)
    set_description("enable REX::TOML settings support")
end)

option("commonlib_xbyak", function()
    set_default(false)
    set_description("enable xbyak support for Trampoline")
end)

option("commonlib_random", function ()
    set_default(false)
    set_description("enable REX::TRandom support")
end)

-- require packages
add_requires("rsm-binary-io")
add_requires("spdlog", { configs = { header_only = false, wchar = true, std_format = true } })
if has_config("commonlib_ini") then add_requires("simpleini") end
if has_config("commonlib_json") then add_requires("glaze") end
if has_config("commonlib_toml") then add_requires("toml11") end
if has_config("commonlib_xbyak") then add_requires("xbyak") end
if has_config("commonlib_random") then add_requires("xoshiro-cpp 2021.08.04") end

local currentdir = os.scriptdir()

rule("commonlib", function()
    on_load(function(target)
        target:set("arch", "x64")
        target:set("languages", "c++23")
        target:set("warnings", "allextra")
        target:set("encodings", "utf-8")

        -- set target group
        target:set("group", "commonlib")

        -- set target kind
        target:set("kind", "static")

        -- set not build by default
        target:set("default", false)

        -- add packages
        target:add("packages", "rsm-binary-io", "spdlog", { public = true })
        
        -- add options
        target:add("options", "commonlib_ini", "commonlib_json", "commonlib_toml", "commonlib_xbyak", "commonlib_random", { public = true })
        
        -- add system links
        target:add("syslinks", "advapi32", "bcrypt", "d3d11", "d3dcompiler", "dbghelp", "dxgi", "ole32", "shell32", "user32", "version", "ws2_32")
        
        -- add files and headers
        local libdir = target:values("lib_dir")
        local shareddir = path.join(currentdir, "commonlib-shared")
        local build_ver = target:values("build_ver")
        if build_ver == "se" then
            target:add("undefines", "SKYRIM_SUPPORT_AE", { public = true })
            target:add("files", shareddir .. "/src/**.cpp")
            target:add("includedirs", shareddir .. "/include", { public = true })
            target:add("headerfiles",
                shareddir .. "/include/(REL/**.h)",
                shareddir .. "/include/(REX/**.h)",
                { public = true })
        elseif build_ver == "ae" then
            target:add("defines", "SKYRIM_SUPPORT_AE", { public = true })
            target:add("files", shareddir .. "/src/**.cpp")
            target:add("includedirs", shareddir .. "/include", { public = true })
            target:add("headerfiles",
                shareddir .. "/include/(REL/**.h)",
                shareddir .. "/include/(REX/**.h)",
                { public = true })
        elseif build_ver == "vr" then
            target:add("undefines", "SKYRIM_SUPPORT_AE", { public = true })
            target:add("defines", "SKYRIMVR", { public = true })
            target:add("includedirs", libdir .. "/extern/openvr/headers", { public = true })
        end
        target:add("files", libdir .. "/src/**.cpp")
        target:add("includedirs", libdir .. "/include", { public = true })
        target:add("headerfiles",
            libdir .. "/include/(RE/**.h)",
            libdir .. "/include/(SKSE/**.h)",
            { public = true }
        )

        -- set precompiled header
        target:set("pcxxheader", libdir .. "/include/SKSE/Impl/PCH.h")

        -- add flags
        target:add("cxxflags", "/EHsc", "/permissive-", { public = true })

        -- add flags (cl)
        target:add("cxxflags",
            "cl::/bigobj",
            "cl::/cgthreads8",
            "cl::/diagnostics:caret",
            "cl::/external:W0",
            "cl::/fp:contract",
            "cl::/fp:except-",
            "cl::/guard:cf-",
            "cl::/Zc:enumTypes",
            "cl::/Zc:preprocessor",
            "cl::/Zc:templateScope",
            "cl::/Zc:inline",
            { public = true }
        )

        -- add flags (cl: warnings -> errors)
        target:add("cxxflags", 
            "cl::/we4715", -- not all control paths return a value
            { public = true }
        )

        -- add flags (cl: disable warnings)
        target:add("cxxflags",
            "cl::/wd4200", -- nonstandard extension used : zero-sized array in struct/union
            "cl::/wd4201", -- nonstandard extension used : nameless struct/union
            "cl::/wd4324", -- structure was padded due to alignment specifier
            { public = true }
        )

        -- add flags (clang-cl)
        target:add("cxxflags",
            "clang_cl::-fms-compatibility",
            "clang_cl::-fms-extensions",
            { public = true }
        )

        -- add flags (clang-cl: disable warnings)
        target:add("cxxflags",
            "clang_cl::-Wno-delete-non-abstract-non-virtual-dtor",
            "clang_cl::-Wno-deprecated-volatile",
            "clang_cl::-Wno-ignored-qualifiers",
            "clang_cl::-Wno-inconsistent-missing-override",
            "clang_cl::-Wno-invalid-offsetof",
            "clang_cl::-Wno-microsoft-include",
            "clang_cl::-Wno-overloaded-virtual",
            "clang_cl::-Wno-pragma-system-header-outside-header",
            "clang_cl::-Wno-reinterpret-base-class",
            "clang_cl::-Wno-switch",
            "clang_cl::-Wno-unused-local-typedef",
            "clang_cl::-Wno-unused-private-field",
            { public = true }
        )
    end)

    on_config(function(target)
        -- add configs
        if has_config("commonlib_ini") then
            add_packages("simpleini", { public = true })
            add_defines("COMMONLIB_OPTION_INI=1", { public = true })
        end

        if has_config("commonlib_json") then
            add_packages("glaze", { public = true })
            add_defines("COMMONLIB_OPTION_JSON=1", { public = true })
        end

        if has_config("commonlib_toml") then
            add_packages("toml11", { public = true })
            add_defines("COMMONLIB_OPTION_TOML=1", { public = true })
        end

        if has_config("commonlib_xbyak") then
            add_packages("xbyak", { public = true })
            add_defines("COMMONLIB_OPTION_XBYAK=1", { public = true })
        end

        if has_config("commonlib_random") then
            add_packages("xoshiro-cpp", { public = true })
            add_defines("COMMONLIB_OPTION_RANDOM=1", { public = true })
        end
    end)
end)


-- define targets
target("commonlibsse.se", function()
    set_values("build_ver", "se")
    set_values("lib_dir", path.join(currentdir, "commonlibsse"))
    add_rules("commonlib")
end)

target("commonlibsse.ae", function()
    set_values("build_ver", "ae")
    set_values("lib_dir", path.join(currentdir, "commonlibsse"))
    add_rules("commonlib")
end)

target("commonlibsse.ae1170", function()
    set_values("build_ver", "ae")
    set_values("lib_dir", path.join(currentdir, "commonlibsse-1170"))
    add_rules("commonlib")
end)

target("commonlibvr", function()
    set_values("build_ver", "vr")
    set_values("lib_dir", path.join(currentdir, "commonlibvr"))
    add_rules("commonlib")
end)
