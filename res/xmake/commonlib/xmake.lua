-- set minimum xmake version
set_xmakever("2.8.2")

-- set project
set_project("commonlibsse")
set_arch("x64")
set_languages("c++23")
set_warnings("allextra")
set_encodings("utf-8")

-- add rules
add_rules("mode.debug", "mode.releasedbg")

-- make custom rules available
-- includes("xmake-rules.lua")

-- define options
option("commonlib_dir", function()
    set_default(false)
    set_description("commonlib directory")
end)

option("skse_xbyak", function()
    set_default(false)
    set_description("Enable trampoline support for Xbyak")
    add_defines("SKSE_SUPPORT_XBYAK=1")
end)

-- require packages
add_requires("rsm-binary-io")
add_requires("spdlog", { configs = { header_only = false, wchar = true, std_format = true } })

if has_config("skse_xbyak") then
    add_requires("xbyak")
end

-- define targets
target("commonlibsse-se", function()
    add_undefines("SKYRIM_SUPPORT_AE")

    -- set target kind
    set_kind("static")

    -- set build by default
    set_default(os.scriptdir() == os.projectdir())

    -- add packages
    add_packages("rsm-binary-io", "spdlog", { public = true })

    if has_config("skse_xbyak") then
        add_packages("xbyak", { public = true })
    end

    -- add options
    add_options("commonlib_dir", "skse_xbyak", { public = true })

    -- add system links
    add_syslinks("advapi32", "bcrypt", "d3d11", "d3dcompiler", "dbghelp", "dxgi", "ole32", "shell32", "user32", "version")

    -- add source files
    add_files("$(commonlib_dir)/src/**.cpp")

    -- add header files
    add_includedirs("$(commonlib_dir)/include", { public = true })
    add_headerfiles(
        "$(commonlib_dir)/include/(RE/**.h)",
        "$(commonlib_dir)/include/(REL/**.h)",
        "$(commonlib_dir)/include/(REX/**.h)",
        "$(commonlib_dir)/include/(SKSE/**.h)"
    )

    -- set precompiled header
    set_pcxxheader("$(commonlib_dir)/include/SKSE/Impl/PCH.h")

    -- add flags
    add_cxxflags("/EHsc", "/permissive-", { public = true })

    -- add flags (cl)
    add_cxxflags(
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
    add_cxxflags("cl::/we4715") -- `function` : not all control paths return a value

    -- add flags (cl: disable warnings)
    add_cxxflags(
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
    add_cxxflags(
        "clang_cl::-fms-compatibility",
        "clang_cl::-fms-extensions",
        { public = true }
    )

    -- add flags (clang-cl: disable warnings)
    add_cxxflags(
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

target("commonlibsse-ae", function()
    add_defines("SKYRIM_SUPPORT_AE=1")

    -- set target kind
    set_kind("static")

    -- set build by default
    set_default(os.scriptdir() == os.projectdir())

    -- add packages
    add_packages("rsm-binary-io", "spdlog", { public = true })

    if has_config("skse_xbyak") then
        add_packages("xbyak", { public = true })
    end

    -- add options
    add_options("commonlib_dir", "skse_xbyak", { public = true })

    -- add system links
    add_syslinks("advapi32", "bcrypt", "d3d11", "d3dcompiler", "dbghelp", "dxgi", "ole32", "shell32", "user32", "version")

    -- add source files
    add_files("$(commonlib_dir)/src/**.cpp")

    -- add header files
    add_includedirs("$(commonlib_dir)/include", { public = true })
    add_headerfiles(
        "$(commonlib_dir)/include/(RE/**.h)",
        "$(commonlib_dir)/include/(REL/**.h)",
        "$(commonlib_dir)/include/(REX/**.h)",
        "$(commonlib_dir)/include/(SKSE/**.h)"
    )

    -- set precompiled header
    set_pcxxheader("$(commonlib_dir)/include/SKSE/Impl/PCH.h")

    -- add flags
    add_cxxflags("/EHsc", "/permissive-", { public = true })

    -- add flags (cl)
    add_cxxflags(
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
    add_cxxflags("cl::/we4715") -- `function` : not all control paths return a value

    -- add flags (cl: disable warnings)
    add_cxxflags(
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
    add_cxxflags(
        "clang_cl::-fms-compatibility",
        "clang_cl::-fms-extensions",
        { public = true }
    )

    -- add flags (clang-cl: disable warnings)
    add_cxxflags(
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