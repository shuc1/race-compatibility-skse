-- add requires
add_requires("glaze")
add_requires("microsoft-detours")

-- set compile options
set_toolchains("msvc")
set_languages("cxxlatest")
set_warnings("allextra", "error")
set_encodings("utf-8")

-- set compile modes
add_rules("mode.debug", "mode.releasedbg", "mode.release")
set_defaultmode("releasedbg")
if is_mode("release", "releasedbg") then
    -- Enable LTO (Link Time Optimization) only in release and releasedbg modes
    -- This ensures that the releasedbg mode closely resembles the release mode
    set_policy("build.optimization.lto", true)
end

local currentdir = os.scriptdir()
-- generate Version.h
set_configvar("PROJECT_NAME", projectname)
set_configvar("PAPYRUS_NAME", papyrusname)
set_configvar("CONFIG_KEY", projectabbr)
set_configvar("CONFIG_DIR", path.join("data", plugindir, string.lower(projectabbr)))
add_configfiles("(include/Versions.h.in)", {prefixdir = path.basename(currentdir)})

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
        target:add("includedirs", path.join(currentdir, "include/"))
        -- for vs studio project
        target:add("headerfiles", path.join(currentdir, "include/*.h"))
        target:set("pcxxheader", path.join(currentdir, "include/pch.h"))

        target:add("cxxflags",
            "cl::/Zc:inline"
        )
    end)
end)

-- builds
local deptable = {
    -- ver, dep
    ["se"]="commonlibsse.se",
    ["ae"]="commonlibsse.ae",
    ["vr"]="commonlibvr"
}

-- dll
-- default build
for ver, dep in pairs(deptable) do
    target(string.lower(projectabbr) .. "." .. ver, function()
        set_group("default")
        add_deps(dep)
        set_targetdir(path.join("$(builddir)", "$(mode)", ver))
        add_rules("rcs")
    end)
end
-- detour build
for ver, dep in pairs(deptable) do
    target(string.lower(projectabbr) .. "." .. ver .. ".detours", function()
        set_group("detours")
        add_deps(dep)
        -- add detours specific rules
        add_packages("microsoft-detours")
        add_defines("DETOURS", { public = false })
        set_targetdir(path.join("$(builddir)", "detours", "$(mode)", ver))
        add_rules("rcs")
    end)
end