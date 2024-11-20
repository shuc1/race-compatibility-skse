-- set minimum xmake version
set_xmakever("2.8.6")

-- includes
includes("@builtin/xpack")
includes("xmake-rules.lua")
includes("res/xmake/commonlibsse")
includes("lib/commonlibsse")

-- set project
local project_name = "race-compatibility"
local project_title = to_title(project_name)
local se_suffix = "se"
local ae_suffix = "ae"
local required_dir = "required/"
local plugin_dir = "skse/plugins/"
local se_plugin_dir = path.join(se_suffix, plugin_dir)
local ae_plugin_dir = path.join(ae_suffix, plugin_dir)

set_project(project_name)
set_version("1.0.4", {build = "%Y-%m-%d"})
set_license("GPL-3.0")

-- set configs
-- project source
set_configvar("CONFIG_KEY", "RCS")
set_configvar("CONFIG_DIR", path.join("data", plugin_dir, string.lower("RCS")))
set_configvar("PROJECT_TITLE", project_title)
set_configvar("PROJECT_NAME", project_name)
set_configvar("PROJECT_NAME_CAMEL", to_camel(project_name))

-- add config file
set_configdir("$(projectdir)")
-- add config files
add_configfiles("res/versions.h.in", {prefixdir = "include/"})

-- set config
set_config("commonlib_dir", "lib/commonlibsse")

-- set defaults
set_languages("c++23")
set_warnings("allextra", "error")
set_defaultmode("releasedbg")

-- add rules
add_rules("mode.debug", "mode.releasedbg")
add_rules("plugin.vsxmake.autoupdate")

-- set policies
set_policy("package.requires_lock", true)

-- add requires
add_requires("srell")

-- set encoding
set_encodings("utf-8")

-- targets
-- rcs se
target(project_name .. "-" .. se_suffix, function()
    add_undefines("SKYRIM_SUPPORT_AE")
    -- set project build info
    set_basename(project_name)
    set_targetdir("$(buildir)/" .. se_suffix)
    set_default(true)
    set_arch("x64")
    set_kind("shared")

    -- add dependencies to target
    add_deps("commonlibsse-" .. se_suffix)
    
    -- add requires to target
    add_packages("srell")

    -- add src files
    add_files("src/**.cpp")
    add_headerfiles("include/**.h")
    add_includedirs(
        "include/",
        "lib/ClibUtil/include/")
    set_pcxxheader("include/pch.h")
end)

target(project_name .. "-" .. ae_suffix, function()
    add_defines("SKYRIM_SUPPORT_AE=1")
    -- set project build info
    set_basename(project_name)
    set_targetdir("$(buildir)/" .. ae_suffix)
    set_default(true)
    set_arch("x64")
    set_kind("shared")

    -- add dependencies to target
    add_deps("commonlibsse-" .. ae_suffix)
    
    -- add requires to target
    add_packages("srell")

    -- add src files
    add_files("src/**.cpp")
    add_headerfiles("include/**.h")
    add_includedirs(
        "include/",
        "lib/ClibUtil/include/")
    set_pcxxheader("include/pch.h")
end)

-- papyrus
target("papyrus.main", function()
    set_kind("object")
    add_rules("papyrus")
    add_files("res/rcs/**.psc")
end)

target("papyrus.patch", function()
    set_kind("object")
    add_rules("papyrus")
    add_files("res/patch/**.psc")
    add_includedirs(
        "res/rcs/scripts/source/",
        "lib/skyui/dist/Data/Scripts/Source/",
        "res/papyrus/include/nightmare-night",
        "res/papyrus/include/sacrosanct")
end)


-- xpack
-- fomod
set_configvar("FOMOD_REQUIRED_DIR", required_dir)
set_configvar("FOMOD_PLUGIN_DIR", plugin_dir)
set_configvar("FOMOD_SE_PLUGIN_DIR", se_plugin_dir)
set_configvar("FOMOD_AE_PLUGIN_DIR", ae_plugin_dir)
add_configfiles("res/(**.xml.in)", {prefixdir = "res/"})

-- installation packs
xpack("main")
    -- package
    set_formats("zip")
    set_basename(project_title .. "-$(version)")
    -- fomod info
    add_installfiles("res/rcs/(fomod/**)|*.in")
    -- se plugin file
    add_installfiles("/**/" .. path.join(se_suffix, project_name .. ".dll"), {prefixdir = se_plugin_dir})
    -- ae plugin file
    add_installfiles("/**/" .. path.join(ae_suffix, project_name .. ".dll"), {prefixdir = ae_plugin_dir})
    -- script files
    add_installfiles("res/rcs/(scripts/**)",  {prefixdir = required_dir})


xpack("patch")
    -- package
    set_formats("zip")
    set_basename(project_title .. " - Patch Hub-$(version)")
    -- add fomod info and all files
    add_installfiles("res/patch/(**)|*.in")