function to_camel(a_name)
    local result = ""
    for i, s in ipairs(a_name:split("-")) do
        result = result .. s:sub(1, 1):upper() .. s:sub(2)
    end
    return result
end

function to_title(a_name)
    local result = ""
    for i, s in ipairs(a_name:split("-")) do
        result = result .. s:sub(1, 1):upper() .. s:sub(2) .. " "
    end
    result = result .. "SKSE"
    return result
end

rule("race-compatibility", function()
    on_load(function(target)
        target:set("default", true)
        target:set("arch", "x64")
        target:set("kind", "shared")
        target:set("basename", "race-compatibility")
        
        target:add("packages", "glaze")

        target:add("files", "src/*.cpp")
        target:add("includedirs", "include/")
        -- for vs studio project
        target:add("headerfiles", "include/*.h")
        target:set("pcxxheader", "include/pch.h")
    end)
end)