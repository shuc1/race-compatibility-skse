-- xpack
includes("@builtin/xpack")
-- fomod vars

local packtable = {
    -- main file
    {mode="release", name=projecttitle, file_id=3210595, category="main",description=[[
Main file, supports Skyrim SE 1.5.97, AE 1.6.1170/1.6.1179(GOG), AE 1.7.99+, and VR 1.4.15.1.

The .dll files are built using GitHub Actions, and their integrity and build provenance can be verified using file hashes and GitHub Artifact Attestations.]]},

    -- pdb build
    {mode="releasedbg", name=projecttitle .. "-PDB Build", file_id=3210601, category="miscellaneous", description=[[
Main file built in releasedbg mode with .pdb files included for debugging or CrashLogger.]]},

    -- pdb build with detours
    {mode="detours/releasedbg", name=projecttitle .. "-PDB Build with Detours", file_id=6184117, category="miscellaneous", description=[[
Main file built in releasedbg mode with .pdb files included, uses Detours for hooking to achieve max compatibility with other plugins that modify the same functions.

Do not use this version unless explicitly instructed.]]},
}

for _, pack in ipairs(packtable) do
    xpack(pack.mode, function()
        set_formats("zip")

        on_load(function(package)
            import("core.project.project")
            import("core.project.config")
            
            package:set("basename", pack.name:gsub("%s+", "-") .. "-" .. project.version())

            -- res files
            package:add("installfiles", "res/(**)|**.in|**.lua|schema/*")
            -- main files
            local filedir = path.join(config.builddir(), pack.mode)
            package:add("installfiles", path.join(filedir, "(*/*.dll)"))
            package:add("installfiles", path.join(filedir, "(*/" .. project.name() .. ".pdb)"))
        end)

        after_package(function(package)
            -- move the zip file to xpack/
            local outdir = path.normalize(path.directory(package:outputfile()))
            local pattern = path.normalize(pack.mode):gsub("(%W)", "%%%1") .. "$"
            local packdir = outdir:gsub(pattern, "")
            os.mv(package:outputfile(), packdir)
            os.rmdir(path.join(packdir, path.split(pack.mode)[1]))

            -- summary
            import("core.base.json")
            print("[package]: " .. json.encode({
                filename = package:basename() .. package:extension(),
                name = pack.name,
                file_id = pack.file_id,
                category = pack.category,
                description = pack.description,
            }))
        end)
    end)
end
