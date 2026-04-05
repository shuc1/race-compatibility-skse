
local prefixdir = path.basename(os.scriptdir())

-- generate files
-- fomod info files
set_configvar("PROJECT_TITLE", projecttitle)
set_configvar("FOMOD_PLUGIN_DIR", plugindir)
add_configfiles("(fomod/**.in)", {prefixdir = prefixdir})
-- papyrus
set_configvar("PAPYRUS_NAME", papyrusname)
add_configfiles("(scripts/source/RaceCompatibility.psc.in)", {prefixdir = prefixdir})


rule("papyrus", function()
    set_extensions(".psc")

    on_load(function(target)
        target:set("kind", "object")
        -- target:set("default", true)
    end)

    on_buildcmd_files(function(target, batchcmds, sourcebatch, opt)
        -- envs
        local skyrim_home = path.absolute(os.getenv("SKYRIM_HOME"))
        local papyrus_compiler = path.join(skyrim_home, "/Papyrus Compiler/PapyrusCompiler.exe")
        local tesv_includes = path.join(skyrim_home, "/Data/Scripts/Source/")
        local flags = path.join(tesv_includes, "TESV_Papyrus_Flags.flg")
        assert(os.exists(skyrim_home), "SKYRIM_HOME not found in environment")
        assert(os.exists(papyrus_compiler), "PapyrusCompiler.exe not found in " .. papyrus_compiler)
        assert(os.exists(tesv_includes), "Skyrim source directory not found in " .. tesv_includes)
        assert(os.exists(flags), "TESV_Papyrus_Flags.flg not found in " .. flags)

        -- includes
        local includes = ""
        for _, i in ipairs(target:get("includedirs")) do
            includes = includes .. i .. ";"
        end
        includes = includes .. tesv_includes
        -- batchcmds:show_progress(opt.progress, "${color.build.object}includes %s", includes)
        -- collect source files by directory
        local batchdirs = {}
        for _, sourcefile in ipairs(sourcebatch.sourcefiles) do
            local dir = path.directory(sourcefile)
            if batchdirs[dir] == nil then
                batchdirs[dir] = {}
            end
            table.insert(batchdirs[dir], sourcefile)
        end
        
        -- compile each directory
        for dir, files in pairs(batchdirs) do
            local outputdir = path.directory(dir)
            batchcmds:show_progress(opt.progress, "${color.build.object}compiling.papyrus %s", dir)
            batchcmds:vrunv(papyrus_compiler, {
                path.absolute(dir),
                "-i=" .. dir .. ";" .. includes,
                "-o=" .. outputdir,
                "-f=" .. flags,
                "-a"
            })

            -- add deps
            for _, file in ipairs(files) do
                local dependfile = target:dependfile(path.join(outputdir, path.basename(file) .. ".pex"))
                batchcmds:set_depmtime(os.mtime(dependfile))
                batchcmds:set_depcache(dependfile)
            end
        end
        -- add deps
        batchcmds:add_depfiles(sourcebatch.sourcefiles)
    end)
end)

target("papyrus", function()
    add_rules("papyrus")
    set_default(false)

    add_files("scripts/source/**.psc")
end)