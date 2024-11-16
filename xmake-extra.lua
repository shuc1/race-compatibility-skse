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