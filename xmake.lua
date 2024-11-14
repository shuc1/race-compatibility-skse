-- set minimum xmake version
set_xmakever("2.8.6")

-- includes
includes("@builtin/xpack")
includes("xmake-extra.lua")
includes("res/build/commonlib")

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
set_version("1.0.0", {build = "%Y-%m-%d"})
set_license("GPL-3.0")

-- set configs
-- project source
set_configvar("CONFIG_KEY", "RCS")
set_configvar("CONFIG_DIR", path.join("data", plugin_dir, string.lower("RCS")))
set_configvar("PROJECT_TITLE", project_title)
set_configvar("PROJECT_NAME", project_name)
set_configvar("PROJECT_NAME_CAMEL", to_camel(project_name))
-- fomod
set_configvar("FOMOD_REQUIRED_DIR", required_dir)
set_configvar("FOMOD_PLUGIN_DIR", plugin_dir)
set_configvar("FOMOD_SE_PLUGIN_DIR", se_plugin_dir)
set_configvar("FOMOD_AE_PLUGIN_DIR", ae_plugin_dir)

-- add config file
set_configdir("$(projectdir)")
-- add_configfiles("res/versions.h.in", {prefixdir = "src/"})
-- add_configfiles("res/*.xml.in", {prefixdir = "res/fomod/"})

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
-- gen config files
target("config-files")
    set_kind("phony")
    add_configfiles("res/versions.h.in", {prefixdir = "src/"})
    add_configfiles("res/*.xml.in", {prefixdir = "res/fomod/"})
target_end()


-- rcs se
target(project_name .. "-" .. se_suffix)
    -- set project build info
    set_basename(project_name)
    set_targetdir("$(buildir)/" .. se_suffix)
    set_default(true)
    add_undefines("SKYRIM_SUPPORT_AE")

    -- add dependencies to target
    add_deps("config-files")
    add_deps("commonlibsse-" .. se_suffix)

    -- add commonlibsse plugin
    add_rules("commonlibsse.plugin", {
        name = project_name,
        description = "Plugin for race compatibility in dialogue, vampirism and so on."
    })
    
    -- add requires to target
    add_packages("srell")

    -- add src files
    add_files("src/**.cpp")
    add_headerfiles("src/**.h")
    add_includedirs(
        "src",
        "lib/ClibUtil/include")
    set_pcxxheader("src/pch.h")
target_end()

target(project_name .. "-" .. ae_suffix)
    -- set project build info
    set_basename(project_name)
    set_targetdir("$(buildir)/" .. ae_suffix)
    set_default(true)

    -- add dependencies to target
    add_deps("config-files")
    add_deps("commonlibsse-" .. ae_suffix)

    -- add commonlibsse plugin
    add_rules("commonlibsse.plugin", {
        name = project_name,
        description = "Plugin for race compatibility in dialogue, vampirism and so on."
    })
    
    -- add requires to target
    add_packages("srell")

    -- add src files
    add_files("src/**.cpp")
    add_headerfiles("src/**.h")
    add_includedirs(
        "src",
        "lib/ClibUtil/include")
    set_pcxxheader("src/pch.h")
target_end()

-- xpack
local skyrim_home = path.absolute(os.getenv("SKYRIM_HOME"))
local compiler_path = path.join(skyrim_home, "/Papyrus Compiler/PapyrusCompiler.exe")
local skyrim_source_dir = path.join(skyrim_home, "/data/scripts/source/")
local flag_path = path.join(skyrim_source_dir, "TESV_Papyrus_Flags.flg")
local core_papyrus_source_dir = path.join(os.projectdir(), "res/rcs/scripts/source/")
-- installation packs
xpack("fomod")
    -- compile core papyrus scripts
    before_package(function (package)
        os.cd(core_papyrus_source_dir)
        os.execv(compiler_path, {
            "./",
            "-i=" .. skyrim_source_dir, 
            "-o=../", 
            "-f=" .. flag_path, 
            "-a", "-q"})
        os.cd("$(projectdir)")
    end)

    -- package
    set_formats("zip")
    set_basename(project_title .. "-$(version)")
    -- fomod info
    add_installfiles("res/fomod/*.xml", {prefixdir = "fomod/"})
    add_installfiles("res/fomod/(images/*.png)", {prefixdir = "fomod/"})
    -- se plugin file
    add_installfiles("/**/" .. path.join(se_suffix, project_name .. ".dll"), {prefixdir = se_plugin_dir})
    -- ae plugin file
    add_installfiles("/**/" .. path.join(ae_suffix, project_name .. ".dll"), {prefixdir = ae_plugin_dir})
    -- script files
    add_installfiles("res/rcs/**.pex",  {prefixdir = required_dir .. "scripts/"})
    add_installfiles("res/rcs/**.psc",  {prefixdir = required_dir .. "scripts/source/"})

    -- after_package(function (package) 
    --     os.cp(package:outputfile(), "D:/Downloads/")
    -- end)

xpack("vanilla-scripts-addon")
    -- compile vanilla papyrus addon
    before_package(function (package)
        os.cd(path.join(os.projectdir(), "res/vanilla-scripts/scripts/source/"))
        os.runv(compiler_path, {
           "./",
            "-i=" .. skyrim_source_dir .. ";" .. core_papyrus_source_dir, 
            "-o=../", 
            "-f=" .. flag_path, 
            "-a", "-q"})
        os.cd("$(projectdir)")
    end)

    -- package
    set_formats("zip")
    set_basename(project_title .. " - Vanilla Scirpts Addon-$(version)")
    add_installfiles("res/vanilla-scripts/**.pex",  {prefixdir = "scripts"})
    add_installfiles("res/vanilla-scripts/**.psc",  {prefixdir = "scripts/source"})

    -- after_package(function (package) 
    --     os.cp(package:outputfile(), "D:/Downloads/")
    -- end)