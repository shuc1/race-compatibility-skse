-- set minimum xmake version
set_xmakever("2.8.2")

function to_camel(a_name)
    local result = ""
    for i, s in ipairs(a_name:split("-")) do
        result = result .. s:sub(1,1):upper() .. s:sub(2)
    end
    return result 
end

function to_package_name(a_name) 
    local result = ""
    for i, s in ipairs(a_name:split("-")) do
        result = result .. s:sub(1,1):upper() .. s:sub(2) .. " "
    end
    result = result .. "SKSE"
    return result
end

-- includes
includes("@builtin/xpack")
includes("lib/commonlibsse")

-- set project
local project_name = "race-compatibility"
local se_suffix = "se"
local ae_suffix = "ae"
set_project(project_name)
set_version("0.5.1", {build = "%Y-%m-%d"})
set_license("GPL-3.0")

-- set configs
set_configvar("CONFIG_KEY", "RCS")
set_configvar("PROJECT", project_name)
set_configvar("SCRIPT_NAME", to_camel(project_name))

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
target(project_name .. "-" .. se_suffix)
    set_basename(project_name)

    -- set configs
    set_configvar("skyrim_ae", false)

    -- add dependencies to target
    add_deps("commonlibsse")

    -- add commonlibsse plugin
    add_rules("commonlibsse.plugin", {
        name = project_name,
        author = "shuc",
        description = "Plugin for race compatibility in dialogue, vampirism and so on."
    })
    
    set_targetdir("$(buildir)/" .. se_suffix)

    -- add requires to target
    add_packages("srell")

    -- add config file
    set_configdir("src/")
    add_configfiles("res/versions.h.in")

    -- add src files
    add_files("src/**.cpp")
    add_headerfiles("src/**.h")
    add_includedirs(
        "src",
        "lib/ClibUtil/include")
    set_pcxxheader("src/pch.h")

    -- after_build(function (target) // compile psc files
        
    -- end)
target_end()

xpack(project_name)
    -- set_formats("7z")
    -- set_extension(".7z")
    -- on_package(function (package)
    --     local outputfile = package:outputfile()
    --     print("outputfile: " .. outputfile)
    --     print("basename: " .. path.basename())
    --     -- os.run("7z a -t7z -m0=lzma2 -mx=9 -mfb=64 -md=32m -ms=on", outputfile)
    -- end)
    set_formats("zip")

    set_basename(to_package_name(project_name) .. "-$(version)")
    add_installfiles("/**/" .. se_suffix .. "/" .. project_name .. ".dll", {prefixdir = "skse/plugins"})
    add_installfiles("res/rcs/**.psc",  {prefixdir = "scripts/source"})
    add_installfiles("res/rcs/**.pex",  {prefixdir = "scripts"})
    -- after_package(function (package) 
    --     os.cp(package:outputfile(), "D:/Downloads/")
    -- end)

xpack("papyrus")
    set_formats("zip")
    set_basename(to_package_name(project_name) .. " - Vanilla Scirpts Addon-$(version)")
    add_installfiles("res/papyrus/**.psc",  {prefixdir = "scripts/source"})
    add_installfiles("res/papyrus/**.pex",  {prefixdir = "scripts"})
    -- after_package(function (package) 
    --     os.cp(package:outputfile(), "D:/Downloads/")
    -- end)

-- copy build files to MODS or GAME paths (remove this if not needed)
    -- after_build(function(target)
    --     local copy = function(env, ext)
    --         for _, env in pairs(env:split(";")) do
    --             if os.exists(env) then
    --                 local plugins = path.join(env, ext, "SKSE/Plugins")
    --                 os.mkdir(plugins)
    --                 os.trycp(target:targetfile(), plugins)
    --                 os.trycp(target:symbolfile(), plugins)
    --             end
    --         end
    --     end
    --     if os.getenv("XSE_TES5_MODS_PATH") then
    --         copy(os.getenv("XSE_TES5_MODS_PATH"), target:name())
    --     elseif os.getenv("XSE_TES5_GAME_PATH") then
    --         copy(os.getenv("XSE_TES5_GAME_PATH"), "Data")
    --     end
    -- end)
