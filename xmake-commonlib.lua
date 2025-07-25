-- v2025-5-1
-- set minimum xmake version
set_xmakever("2.8.2")

-- set project
set_project("commonlib")
set_arch("x64")
set_languages("c++23")
set_warnings("allextra")
set_encodings("utf-8")

-- add rules
add_rules("mode.debug", "mode.releasedbg")

-- make custom rules available
-- includes("xmake-rules.lua")

-- define options
option("rex_ini", function()
    set_default(false)
    set_description("Enable ini config support for REX")
    add_defines("REX_OPTION_INI=1")
end)

option("rex_json", function()
    set_default(false)
    set_description("Enable json config support for REX")
    add_defines("REX_OPTION_JSON=1")
end)

option("rex_toml", function()
    set_default(false)
    set_description("Enable toml config support for REX")
    add_defines("REX_OPTION_TOML=1")
end)

option("skse_xbyak", function()
    set_default(false)
    set_description("Enable trampoline support for Xbyak")
    add_defines("SKSE_SUPPORT_XBYAK=1")
end)

-- require packages
add_requires("rsm-binary-io")
add_requires("spdlog", { configs = { header_only = false, wchar = true, std_format = true } })

if has_config("rex_ini") then
    add_requires("simpleini")
end

if has_config("rex_json") then
    add_requires("nlohmann_json")
end

if has_config("rex_toml") then
    add_requires("toml11")
end

if has_config("skse_xbyak") then
    add_requires("xbyak")
end

rule("commonlib", function()
    on_load(function(target)
        -- set target group
        target:set("group", "commonlib")

        -- set target kind
        target:set("kind", "static")

        -- set not build by default
        target:set("default", false)

        -- add packages
        target:add("packages", "rsm-binary-io", "spdlog", { public = true })
        
        -- add options
        target:add("options", "rex_ini", "rex_json", "rex_toml", "skse_xbyak", { public = true })
        
        -- add system links
        target:add("syslinks", "advapi32", "bcrypt", "d3d11", "d3dcompiler", "dbghelp", "dxgi", "ole32", "shell32", "user32", "version")
        
        -- add files and headers
        local libdir = target:values("lib_dir")
        local build_ver = target:values("build_ver")
        if build_ver == "se" then
            target:add("undefines", "SKYRIM_SUPPORT_AE", { public = true })
        elseif build_ver == "ae" then
            target:add("defines", "SKYRIM_SUPPORT_AE", { public = true })
        elseif build_ver == "vr" then
            target:add("undefines", "SKYRIM_SUPPORT_AE", { public = true })
            target:add("defines", "SKYRIMVR", { public = true })
            target:add("includedirs", libdir .. "/extern/openvr/headers", { public = true })
        end
        target:add("files", libdir .. "/src/**.cpp")
        target:add("includedirs", libdir .. "/include", { public = true })
        target:add("headerfiles",
            libdir .. "/include/(RE/**.h)",
            libdir .. "/include/(REL/**.h)",
            libdir .. "/include/(REX/**.h)",
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
            "cl::/Zc:templateScope"
        )

        -- add flags (cl: warnings -> errors)
        target:add("cxxflags", "cl::/we4715") -- `function` : not all control paths return a value

        -- add flags (cl: disable warnings)
        target:add("cxxflags",
            "cl::/wd4005", -- macro redefinition
            "cl::/wd4061", -- enumerator `identifier` in switch of enum `enumeration` is not explicitly handled by a case label
            "cl::/wd4068", -- unknown pragma 'clang'
            "cl::/wd4200", -- nonstandard extension used : zero-sized array in struct/union
            "cl::/wd4201", -- nonstandard extension used : nameless struct/union
            "cl::/wd4264", -- 'virtual_function' : no override available for virtual member function from base 'class'; function is hidden
            "cl::/wd4265", -- 'type': class has virtual functions, but its non-trivial destructor is not virtual; instances of this class may not be destructed correctly
            "cl::/wd4266", -- 'function' : no override available for virtual member function from base 'type'; function is hidden
            "cl::/wd4324", -- 'struct_name' : structure was padded due to __declspec(align())
            "cl::/wd4371", -- 'classname': layout of class may have changed from a previous version of the compiler due to better packing of member 'member'
            "cl::/wd4514", -- 'function' : unreferenced inline function has been removed
            "cl::/wd4582", -- 'type': constructor is not implicitly called
            "cl::/wd4583", -- 'type': destructor is not implicitly called
            "cl::/wd4623", -- 'derived class' : default constructor was implicitly defined as deleted because a base class default constructor is inaccessible or deleted
            "cl::/wd4625", -- 'derived class' : copy constructor was implicitly defined as deleted because a base class copy constructor is inaccessible or deleted
            "cl::/wd4626", -- 'derived class' : assignment operator was implicitly defined as deleted because a base class assignment operator is inaccessible or deleted
            "cl::/wd4686", -- 'user-defined type' : possible change in behavior, change in UDT return calling convention
            "cl::/wd4710", -- 'function' : function not inlined
            "cl::/wd4711", -- function 'function' selected for inline expansion
            "cl::/wd4820", -- 'bytes' bytes padding added after construct 'member_name'
            "cl::/wd5082", -- second argument to 'va_start' is not the last named parameter
            "cl::/wd5026", -- 'type': move constructor was implicitly defined as deleted
            "cl::/wd5027", -- 'type': move assignment operator was implicitly defined as deleted
            "cl::/wd5045", -- compiler will insert Spectre mitigation for memory load if /Qspectre switch specified
            "cl::/wd5053", -- support for 'explicit(<expr>)' in C++17 and earlier is a vendor extension
            "cl::/wd5105", -- macro expansion producing 'defined' has undefined behavior (workaround for older msvc bug)
            "cl::/wd5204", -- 'type-name': class has virtual functions, but its trivial destructor is not virtual; instances of objects derived from this class may not be destructed correctly
            "cl::/wd5220"  -- 'member': a non-static data member with a volatile qualified type no longer implies that compiler generated copy / move constructors and copy / move assignment operators are not trivial
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
            "clang_cl::-Wno-unused-private-field",
            { public = true }
        )
    end)

    on_config(function(target)
        -- add configs
        if has_config("rex_ini") then
            target:add("packages", "simpleini", { public = true })
        end

        if has_config("rex_json") then
            target:add("packages", "nlohmann_json", { public = true })
        end

        if has_config("rex_toml") then
            target:add("packages", "toml11", { public = true })
        end

        if has_config("skse_xbyak") then
            target:add("packages", "xbyak", { public = true })
        end
    end)
end)

-- define targets
target("commonlibsse.se", function()
    set_values("build_ver", "se")
    set_values("lib_dir", "extern/commonlibsse")
    add_rules("commonlib")
end)

target("commonlibsse.ae", function()
    set_values("build_ver", "ae")
    set_values("lib_dir", "extern/commonlibsse")
    add_rules("commonlib")
end)

target("commonlibvr", function()
    set_values("build_ver", "vr")
    set_values("lib_dir", "extern/commonlibvr")
    add_rules("commonlib")
end)
