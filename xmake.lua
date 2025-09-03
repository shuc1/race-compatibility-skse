-- set minimum xmake version
set_xmakever("2.9.9")

-- includes
includes("@builtin/xpack")
includes("xmake-rules.lua")
includes("xmake-commonlib.lua")

-- set project
project_name = "race-compatibility"
plugin_dir = "skse/plugins/"

set_project(project_name)
set_version("2.3.1", {build = "%Y-%m-%d"})
set_license("GPL-3.0")

-- set defaults
set_languages("cxxlatest")
set_warnings("allextra", "error")
set_defaultmode("releasedbg")

-- add rules
add_rules("mode.debug", "mode.releasedbg")
add_rules("plugin.vsxmake.autoupdate")

-- set policies
set_policy("package.requires_lock", true)
set_policy("build.optimization.lto", true)

-- add requires
add_requires("glaze")

-- set encoding
set_encodings("utf-8")

-- set toolchain
set_toolchains("msvc")

-- set configs
set_configdir("$(projectdir)")
-- project source
set_configvar("CONFIG_KEY", "RCS")
set_configvar("CONFIG_DIR", path.join("data", plugin_dir, string.lower("RCS")))
set_configvar("PROJECT_NAME", project_name)
set_configvar("PROJECT_NAME_CAMEL", to_camel(project_name))
-- add config files
add_configfiles("res/Versions.h.in", {prefixdir = "include/"})

-- builds
targettable = {
    -- name, dep
    ['se']='commonlibsse.se',
    ['ae']='commonlibsse.ae',
    ['vr']='commonlibvr'
}

-- dll
for name, dep in pairs(targettable) do
    target(project_name .. "." .. name, function()
        add_deps(dep)
        set_targetdir("$(builddir)/main/" .. name)
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
-- fomod
project_title = to_title(project_name)
required_dir = "required/"
set_configvar("PROJECT_TITLE", project_title)
set_configvar("FOMOD_REQUIRED_DIR", required_dir)
set_configvar("FOMOD_PLUGIN_DIR", plugin_dir)
add_configfiles("res/(**.xml.in)", {prefixdir = "res/"})

-- main pack
xpack("main", function() 
    -- package
    set_formats("zip")
    -- set_outputdir("build/xpack") 
    set_basename(project_title .. "-$(version)")
    -- fomod info
    add_installfiles("res/(fomod/**)|*.in")
    -- plugin files
    add_installfiles("build/(main/**.dll)")
    -- script files
    add_installfiles("res/(scripts/**)",  {prefixdir = required_dir})
end)