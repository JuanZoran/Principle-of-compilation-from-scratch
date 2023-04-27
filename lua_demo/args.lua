-- TODO :Improve this solution
local args_opts = {
    [{
        '-o',
        '--output',
    }] = 'output file',
    [{
        '-s',
        '--string',
    }] = 'input string',
    [{
        '-a',
        '--append',
        no_arg = true,
    }] = 'append output to file',
    [{
        '-h',
        '--help',
        no_arg = true,
    }] = 'show help',
    [{
        '-d',
        '--debug',
        no_arg = true,
    }] = 'print debug message',
}


local function show_help()
    print(('Usage: lua regex.lua [options?] [regex?]'):green())
    print ''
    print 'Options:'
    for k, v in pairs(args_opts) do
        print(([[%5s %10s      %s]]):format(k[1], k[2], v))
    end

    os.exit()
end


local function contain(tbl, value)
    for _, v in ipairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end


local args = {}


local i, stop = 1, #arg
while i <= stop do
    local a = arg[i]

    if a:sub(1, 1) == '-' then
        local found = false
        for opts, _ in pairs(args_opts) do
            local name = opts[2]:sub(3)
            if contain(opts, a) then
                found = true

                if opts.no_arg then
                    args[name] = true
                else
                    assert(arg[i + 1] and arg[i + 1]:sub(1, 1) ~= '-', ('%s need an argument'):format(a))
                    args[name] = arg[i + 1]
                    i = i + 1
                end
            elseif opts.default then
                args[name] = opts.default
            end
        end


        if not found then
            print(('Unknown option: %s'):format(a):red())
            os.exit()
        end
    else
        print(('Unknown option: %s'):format(a):red())
        show_help()
    end


    i = i + 1
end


if args.help then
    show_help()
end

_G.args = args
