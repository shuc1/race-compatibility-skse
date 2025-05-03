-- set minimum xmake version
set_xmakever("2.9.9")

-- includes
includes("@builtin/xpack")
includes("xmake-rules.lua")
includes("xmake-commonlib.lua")

-- set project
project_name = "race-compatibility"
project_title = to_title(project_name)
required_dir = "required/"
plugin_dir = "skse/plugins/"

set_project(project_name)
set_version("2.2.0", {build = "%Y-%m-%d"})
patch_version = "2.1.2"
set_license("GPL-3.0")

-- set defaults
set_languages("cxxlatest")
set_warnings("allextra", "error")
set_defaultmode("releasedbg")
-- set_optimize("faster")

-- add rules
add_rules("mode.debug", "mode.releasedbg")
add_rules("plugin.vsxmake.autoupdate")

-- set policies
set_policy("package.requires_lock", true)

-- add requires
add_requires("glaze")

-- set encoding
set_encodings("utf-8")

-- targets
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
target(project_name .. ".se", function()
    add_deps("commonlibsse.se")
    set_targetdir("$(buildir)/main/se")

    add_rules("race-compatibility")
end)

target(project_name .. ".ae", function()
    add_deps("commonlibsse.ae")
    set_targetdir("$(buildir)/main/ae")
    
    add_rules("race-compatibility")
end)

target(project_name .. ".vr", function()
    add_deps("commonlibvr")
    set_targetdir("$(buildir)/main/vr")
    
    add_rules("race-compatibility")
end)

-- xpack
-- fomod
set_configvar("PROJECT_TITLE", project_title)
set_configvar("FOMOD_REQUIRED_DIR", required_dir)
set_configvar("FOMOD_PLUGIN_DIR", plugin_dir)
set_configvar("FOMOD_SE_PLUGIN_DIR", "main/se")
set_configvar("FOMOD_AE_PLUGIN_DIR", "main/ae")
set_configvar("FOMOD_VR_PLUGIN_DIR", "main/vr")
add_configfiles("res/(**.xml.in)", {prefixdir = "res/"})

-- installation packs
xpack("main", function() 
    -- package
    set_formats("zip")
    -- set_outputdir("build/xpack") 
    set_basename(project_title .. "-$(version)")
    -- fomod info
    add_installfiles("res/main/(fomod/**)|*.in")
    -- plugin files
    add_installfiles("build/(main/**.dll)")
    -- script files
    add_installfiles("extern/res/main/(scripts/**)",  {prefixdir = required_dir})
end)   

set_configvar("PATCH_VERSION", patch_version)
xpack("patch", function() 
    -- package
    set_formats("zip")
    set_version(patch_version)
    set_basename(project_title .. " - Patch Hub-" .. patch_version)
    -- add fomod info and all files
    add_installfiles("res/patch/(**)|**.in")
    add_installfiles("extern/res/patch/(**)")
end)