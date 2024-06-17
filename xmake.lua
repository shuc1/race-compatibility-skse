-- set minimum xmake version
set_xmakever("2.8.2")
local project_name = "race-compatibility"

-- includes
includes("lib/commonlibsse")

-- set project
set_project(project_name)
set_version("0.1.0", {build = "%Y-%m-%d"})
set_license("GPL-3.0")

-- set defaults
set_languages("c++23")
set_warnings("allextra", "error")
set_defaultmode("releasedbg")

-- add rules
add_rules("mode.debug", "mode.releasedbg")
add_rules("plugin.vsxmake.autoupdate")

-- set policies
set_policy("package.requires_lock", true)

-- set configs
set_config("skyrim_se", true)
set_config("skyrim_ae", false)

-- add requires
add_requires("srell")

-- set encoding
set_encodings("utf-8")

-- targets
target(project_name)
    -- add dependencies to target
    add_deps("commonlibsse")

    -- add commonlibsse plugin
    add_rules("commonlibsse.plugin", {
        name = project_name,
        author = "shuc",
        description = "Plugin for race compatibility in dialogue, vampirism and so on."
    })
    
    -- add requires to target
    add_packages("srell")

    -- add config file
    set_configdir("src/")
    set_configvar("CONFIG_KEY", "RCS")
    set_configvar("PROJECT", project_name)
    add_configfiles("res/versions.h.in")

    -- add src files
    add_files("src/**.cpp")
    add_headerfiles("src/**.h")
    add_includedirs("src")
    add_includedirs("lib/ClibUtil/include")
    set_pcxxheader("src/pch.h")

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
target_end()
