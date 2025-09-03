-- set minimum xmake version
set_xmakever("2.9.9")

-- includes
includes("xmake-rules.lua")
includes("xmake-commonlib.lua")

-- set project
project_name = "race-compatibility"
plugin_dir = "skse/plugins/"

set_project(project_name)
set_version("2.3.2", {build = "%Y-%m-%d"})
set_license("GPL-3.0")

-- set defaults
set_languages("cxxlatest")
set_warnings("allextra", "error")
set_defaultmode("releasedbg")

-- add rules
add_rules("mode.debug", "mode.releasedbg", "mode.release")
add_rules("plugin.vsxmake.autoupdate")

-- set policies
set_policy("package.requires_lock", true)
if is_mode("release", "releasedbg") then
    -- Enable LTO (Link Time Optimization) only in release and releasedbg modes
    -- This ensures that the releasedbg mode closely resembles the release mode
    set_policy("build.optimization.lto", true)
end

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
    ["se"]="commonlibsse.se",
    ["ae"]="commonlibsse.ae",
    ["vr"]="commonlibvr"
}

-- dll
for name, dep in pairs(targettable) do
    target(project_name .. "." .. name, function()
        add_deps(dep)
        set_targetdir(path.join("$(builddir)", "$(mode)", name))
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
project_title = to_title(project_name)
set_configvar("PROJECT_TITLE", project_title)
set_configvar("FOMOD_PLUGIN_DIR", plugin_dir)
add_configfiles("res/(fomod/**.in)", {prefixdir = "res/"})

pack_table = {
    -- mode, basename
    ["release"] = project_title .. "-$(version)",
    ["releasedbg"] = project_title .. " - Debug Build" .. "-$(version)"
}

for mode, basename in pairs(pack_table) do
    xpack(mode, function() 
        -- package
        set_formats("zip")
        set_basename(basename)

        add_installfiles("res/(**)|**.in|schema/*")
        -- $(builddir) not working
        -- add_installfiles(path.join("$(builddir)", mode, "(**.dll)"))
        filedir = path.join("build", mode)
        add_installfiles(path.join(filedir, "(**.dll)"))
        add_installfiles(path.join(filedir, "(**/" .. project_name .. ".pdb)"))


        after_package(function(package)
            os.mv(package:outputfile(), "$(builddir)/xpack/")
            os.rmdir(path.directory(package:outputfile()))
        end)
    end)
end
