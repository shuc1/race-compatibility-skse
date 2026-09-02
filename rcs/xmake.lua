-- add requires
add_requires("glaze")
add_requires("microsoft-detours")

-- set compile options
set_toolchains("msvc")
set_languages("cxxlatest")
set_warnings("allextra", "error")
set_encodings("utf-8")

local currentdir = os.scriptdir()
-- generate Version.h
set_configvar("PROJECT_NAME", projectname)
set_configvar("PAPYRUS_NAME", papyrusname)
set_configvar("CONFIG_KEY", projectabbr)
set_configvar("CONFIG_DIR", path.join("data", plugindir, string.lower(projectabbr)))
add_configfiles("(include/Version.h.in)", {prefixdir = path.basename(currentdir)})

-- add build configs
rule("rcs", function()
    on_load(function(target)
        import("core.project.project")

        target:set("default", true)
        target:set("arch", "x64")
        target:set("kind", "shared")
        target:set("basename", project.name()) -- dll name
        
        target:add("packages", "glaze", { public = false })

        target:add("files", path.join(currentdir, "src/*.cpp"))
        target:add("includedirs", path.join(currentdir, "include/"), { public = false })
        -- for vs studio project
        target:add("headerfiles", path.join(currentdir, "include/*.h"), { public = false })
        target:set("pcxxheader", path.join(currentdir, "include/PCH.h"), { public = false })

        target:add("cxxflags",
            "cl::/Zc:inline"
        )
    end)
end)

-- builds
local buildtable = {
    { ver = "se", dep = "commonlibsse.se", def = {} },
    { ver = "ae", dep = "commonlibsse.ae", def = {} },
    { ver = "ae1170", dep = "commonlibsse.ae1170", def = { "SKYRIM_AE_1_6_1170" } },
    { ver = "vr", dep = "commonlibvr", def = {} }
}

-- dll
-- default build
for _, build in ipairs(buildtable) do
    target(string.lower(projectabbr) .. "." .. build.ver, function()
        set_group("default")
        add_deps(build.dep)
        add_defines(build.def)
        set_targetdir(path.join("$(builddir)", "$(mode)", build.ver))
        add_rules("rcs")
    end)
end
-- detour build
for _, build in ipairs(buildtable) do
    target(string.lower(projectabbr) .. "." .. build.ver .. ".detours", function()
        set_group("detours")
        add_deps(build.dep)
        -- add detours specific rules
        add_packages("microsoft-detours")
        add_defines("DETOURS", { public = false })
        add_defines(build.def)
        set_targetdir(path.join("$(builddir)", "detours", "$(mode)", build.ver))
        add_rules("rcs")
    end)
end
