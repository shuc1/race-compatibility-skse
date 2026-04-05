-- xpack
includes("@builtin/xpack")
-- fomod vars

local packtable = {
    -- mode/path, basename
    ["release"] = projecttitle .. "-$(version)",
    ["releasedbg"] = projecttitle .. " - PDB Build" .. "-$(version)",
    ["detours/releasedbg"] = projecttitle .. " - PDB Build with Detours" .. "-$(version)",
}

for mode, basename in pairs(packtable) do
    xpack(mode, function() 
        -- package
        set_formats("zip")
        set_basename(basename)

        add_installfiles("res/(**)|**.in|schema/*")
        -- $(builddir) not working
        filedir = path.join("build", mode)
        add_installfiles(path.join(filedir, "(*/*.dll)"))
        add_installfiles(path.join(filedir, "(*/" .. projectname .. ".pdb)"))


        after_package(function(package)
            packdir = "build/xpack"
            os.mv(package:outputfile(), packdir)
            os.rmdir(path.join(packdir, path.split(mode)[1]))
        end)
    end)
end
