-- set minimum xmake version
set_xmakever("3.0.6")

-- set project
plugindir = "skse/plugins/"

projectname = "race-compatibility-skse"
projecttitle = "Race Compatibility SKSE"
projectabbr = "RCS"
papyrusname = "RaceCompatibility" -- for potential overridden by papyrus implementation

set_project(projectname)
set_version("2.5.3", {build = "%Y-%m-%d"})
set_license("GPL-3.0")

set_policy("package.requires_lock", true)
add_rules("plugin.vsxmake.autoupdate")
set_configdir("./")

-- set compile modes
add_rules("mode.debug", "mode.releasedbg", "mode.release")
set_defaultmode("releasedbg")
if is_mode("release", "releasedbg") then
    -- Enable LTO (Link Time Optimization) only in release and releasedbg modes
    -- This ensures that the releasedbg mode closely resembles the release mode
    set_policy("build.optimization.lto", true)
end

-- includes
includes("*/xmake.lua")
includes("xpack.lua")