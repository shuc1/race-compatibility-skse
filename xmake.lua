-- set minimum xmake version
set_xmakever("3.0.6")

-- includes
includes("xmake-rules.lua")
includes("xmake-commonlib.lua")

-- set project
projectname = "race-compatibility"
plugindir = "skse/plugins/"
set_project(projectname)
set_version("2.5.0", {build = "%Y-%m-%d"})
set_license("GPL-3.0")

-- add requires
add_requires("glaze")
add_requires("microsoft-detours")
set_policy("package.requires_lock", true)

-- set compile options
set_toolchains("msvc")
set_languages("cxxlatest")
set_warnings("allextra", "error")
set_encodings("utf-8")
-- set compile modes
add_rules("plugin.vsxmake.autoupdate")
add_rules("mode.debug", "mode.releasedbg", "mode.release")
set_defaultmode("releasedbg")
if is_mode("release", "releasedbg") then
    -- Enable LTO (Link Time Optimization) only in release and releasedbg modes
    -- This ensures that the releasedbg mode closely resembles the release mode
    set_policy("build.optimization.lto", true)
end

-- set configs
set_configdir("$(projectdir)")
-- project source
set_configvar("CONFIG_KEY", "RCS")
set_configvar("CONFIG_DIR", path.join("data", plugindir, string.lower("RCS")))
set_configvar("PROJECT_NAME", projectname)
set_configvar("PROJECT_NAME_CAMEL", to_camel(projectname))
-- add config files
add_configfiles("res/Versions.h.in", {prefixdir = "include/"})

-- builds
targettable = {
    -- name, dep
    ["se"]="commonlibsse.se",
    ["ae"]="commonlibsse.ae",
    ["vr"]="commonlibvr"
}

-- dll
-- default build
for name, dep in pairs(targettable) do
    target(projectname .. "." .. name, function()
        set_group("default")
        add_deps(dep)
        set_targetdir(path.join("$(builddir)", "$(mode)", name))
        add_rules("race-compatibility")
    end)
end
-- detour build
for name, dep in pairs(targettable) do
    target(projectname .. "." .. name .. ".detours", function()
        set_group("detours")
        add_deps(dep)
        -- add detours specific rules
        add_packages("microsoft-detours")
        add_defines("DETOURS", { public = false })
        set_targetdir(path.join("$(builddir)", "detours", "$(mode)", name))
        add_rules("race-compatibility")
    end)
end

-- papyrus
target("papyrus", function()
    add_rules("papyrus")
    set_default(false)

    add_files("res/scripts/source/**.psc")
end)

-- xpack
includes("@builtin/xpack")
-- fomod vars
projecttitle = to_title(projectname)
set_configvar("PROJECT_TITLE", projecttitle)
set_configvar("FOMOD_PLUGIN_DIR", plugindir)
add_configfiles("res/(fomod/**.in)", {prefixdir = "res/"})

packtable = {
    -- mode/path, basename
    ["release"] = projecttitle .. "-$(version)",
    ["releasedbg"] = projecttitle .. " - PDB Build" .. "-$(version)",
    ["detours/releasedbg"] = projecttitle .. " - PDB Build with Detours" .. "-$(version)",
}

for mode, basename in pairs(packtable) do
    xpack(mode, function() 
        -- package
        set_formats("zip")
        set_basename(basename)

        add_installfiles("res/(**)|**.in|schema/*")
        -- $(builddir) not working
        -- add_installfiles(path.join("$(builddir)", mode, "(**.dll)"))
        filedir = path.join("build", mode)
        add_installfiles(path.join(filedir, "(*/*.dll)"))
        add_installfiles(path.join(filedir, "(*/" .. projectname .. ".pdb)"))


        after_package(function(package)
            packdir = "build/xpack"
            os.mv(package:outputfile(), packdir)
            os.rmdir(path.join(packdir, path.split(mode)[1]))
        end)
    end)
end
