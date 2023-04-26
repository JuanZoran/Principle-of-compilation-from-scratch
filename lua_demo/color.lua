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

local function print_table(tbl, indent)
    indent = indent or ''
    print(indent .. '{')
    for k, v in pairs(tbl) do
        if type(v) == 'table' then
            print(indent .. '  ' .. k .. ' = ')
            print_table(v, indent .. '  ')
        else
            print(indent .. '  ' .. k .. ' = ' .. tostring(v))
        end
    end
    print(indent .. '}')
end


_G.pretty_print_table = print_table
