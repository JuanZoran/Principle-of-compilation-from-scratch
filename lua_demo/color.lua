-- write some utility functions to print colorful text
-- I need: green yellow red blue magenta cyan white
function string.green(text)
    return '\27[32m' .. text .. '\27[0m'
end

function string.yellow(text)
    return '\27[33m' .. text .. '\27[0m'
end

function string.red(text)
    return '\27[31m' .. text .. '\27[0m'
end

function string.blue(text)
    return '\27[34m' .. text .. '\27[0m'
end

function string.magenta(text)
    return '\27[35m' .. text .. '\27[0m'
end

function string.cyan(text)
    return '\27[36m' .. text .. '\27[0m'
end

function string.white(text)
    return '\27[37m' .. text .. '\27[0m'
end

function _G.pretty_print_table(tbl, indent)
    indent = indent or ''
    print(indent .. '{')
    for k, v in pairs(tbl) do
        if type(v) == 'table' then
            print(indent .. '  ' .. k .. ' = ')
            pretty_print_table(v, indent .. '  ')
        else
            print(indent .. '  ' .. k .. ' = ' .. tostring(v))
        end
    end
    print(indent .. '}')
end

local indent_t = '    '
---Inspect a value
---@param value any
---@return string
function _G.inspect(value, indent)
    indent = indent or ''
    local t = type(value)

    if t == 'table' then
        local lines = {}
        for k, v in pairs(value) do
            local key = (type(k) == 'number') and '[' .. k .. ']' or k
            table.insert(lines, indent .. indent_t .. key .. ' = ' .. inspect(v, indent .. indent_t))
        end
        return '{\n' .. table.concat(lines, ',\n') .. '\n' .. indent .. '}'

    elseif t == 'string' then
        return string.format('%q', value)

    elseif t == 'number' or t == 'boolean' or t == 'nil' then
        return tostring(value)

    else
        return '<' .. t .. '>'
    end
end
