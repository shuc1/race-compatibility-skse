-- set minimum xmake version
set_xmakever("2.8.6")

-- includes
includes("@builtin/xpack")
includes("xmake-rules.lua")
includes("res/xmake/commonlibsse")

-- set project
local project_name = "race-compatibility"
local project_title = to_title(project_name)
local required_dir = "required/"
local plugin_dir = "skse/plugins/"

set_project(project_name)
set_version("2.0.1", {build = "%Y-%m-%d"})
set_license("GPL-3.0")

-- set configs
set_configdir("$(projectdir)")
-- project source
set_configvar("CONFIG_KEY", "RCS")
set_configvar("CONFIG_DIR", path.join("data", plugin_dir, string.lower("RCS")))
set_configvar("PROJECT_NAME", project_name)
set_configvar("PROJECT_NAME_CAMEL", to_camel(project_name))
-- add config files
add_configfiles("res/Versions.h.in", {prefixdir = "include/"})

-- set config
set_config("commonlib_dir", "lib/commonlibsse")

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

-- rcs se
target(project_name .. ".se", function()
    add_undefines("SKYRIM_SUPPORT_AE")
    add_deps("commonlibsse-se")
    set_targetdir("$(buildir)/main/se")

    add_rules(project_name)
end)

target(project_name .. ".ae", function()
    add_defines("SKYRIM_SUPPORT_AE=1")
    add_deps("commonlibsse-ae")
    set_targetdir("$(buildir)/main/ae")
    
    add_rules(project_name)
end)

-- papyrus
target("papyrus.main", function()
    set_default(true)
    add_files("res/rcs/**.psc")
    add_rules("papyrus")
end)

-- patches
local patch_targets = {}
for subdir, _ in pairs(get_papyrus_source_subdirs("res/patch")) do
    -- print("Adding patch subdir: " .. subdir)
    target_name = path.basename(path.directory(path.directory(subdir)))
    target_full_name = "papyrus.patch." .. target_name
    target(target_full_name, function()
        set_default(false)

        add_files(subdir .. "/**.psc")
        potential_include = "res/papyrus/include/" .. target_name
        -- print("Potential include: " .. potential_include)
        if os.exists(potential_include) then
            add_includedirs(potential_include)
        end

        add_rules("papyrus")
    end)
    table.insert(patch_targets, target_full_name)
end

target("papyrus.patch", function()
    set_kind("phony")
    add_deps(patch_targets)
end)

-- xpack
-- fomod
set_configvar("PROJECT_TITLE", project_title)
set_configvar("FOMOD_REQUIRED_DIR", required_dir)
set_configvar("FOMOD_PLUGIN_DIR", plugin_dir)
set_configvar("FOMOD_SE_PLUGIN_DIR", "main/se")
set_configvar("FOMOD_AE_PLUGIN_DIR", "main/ae")
add_configfiles("res/(**.xml.in)", {prefixdir = "res/"})

-- installation packs
xpack("main", function() 
    -- package
    set_formats("zip")
    set_basename(project_title .. "-$(version)")
    -- fomod info
    add_installfiles("res/rcs/(fomod/**)|*.in")
    -- plugin files
    add_installfiles("build/(main/**.dll)")
    -- script files
    add_installfiles("res/rcs/(scripts/**)",  {prefixdir = required_dir})
end)   

local patch_version = "2.0.1"
set_configvar("PATCH_VERSION", patch_version)
xpack("patch", function() 
    -- package
    set_formats("zip")
    set_version(patch_version)
    set_basename(project_title .. " - Patch Hub-" .. patch_version)
    -- add fomod info and all files
    add_installfiles("res/patch/(**)|**.in")
end)