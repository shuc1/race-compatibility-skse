function to_camel(a_name)
    local result = ""
    for i, s in ipairs(a_name:split("-")) do
        result = result .. s:sub(1,1):upper() .. s:sub(2)
    end
    return result 
end

function to_title(a_name)
    local result = ""
    for i, s in ipairs(a_name:split("-")) do
        result = result .. s:sub(1,1):upper() .. s:sub(2) .. " "
    end
    result = result .. "SKSE"
    return result
end

rule("papyrus", function()
    set_extensions(".psc")
    on_buildcmd_files(function (target, batchcmds, sourcebatch, opt)
        -- envs
        local skyrim_home = path.absolute(os.getenv("SKYRIM_HOME"))
        local papyrus_compiler = path.join(skyrim_home, "/Papyrus Compiler/PapyrusCompiler.exe")
        local tesv_includes = path.join(skyrim_home, "/data/scripts/source/")
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
            batchcmds:show_progress(opt.progress, "${color.build.object}compiling.papyrus %s", dir)
            local output = path.directory(dir)
            -- batchcmds:mkdir(output)
            batchcmds:vrunv(papyrus_compiler, {
                path.absolute(dir),
                "-i=" .. dir .. ";" .. includes,
                "-o=" .. output,
                "-f=" .. flags,
                "-a"
            })
            -- add dependfile
            for _, file in ipairs(files) do
                local dependfile = target:dependfile(path.join(output, path.basename(file) .. ".pex"))
                batchcmds:set_depmtime(os.mtime(dependfile))
                batchcmds:set_depcache(dependfile)
            end
        end

        -- add deps
        batchcmds:add_depfiles(sourcebatch.sourcefiles)
    end)
end)