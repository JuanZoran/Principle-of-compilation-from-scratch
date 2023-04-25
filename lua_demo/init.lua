require 'color'
local new = require 'data'
local sub = string.sub
local priority = {
    ['('] = 1,
    [')'] = 1,
    ['|'] = 2,
    ['^'] = 3,
    ['*'] = 4,
}


--- TODO : convert this function to a method of nfa

---Do pre-process on regular expression
---@param str string
---@return queue
local pre_process = function(str)
    -- INFO : Add concat operator
    local q = new.queue()
    local concat_operator = '^'
    local function should_concat()
        local back = q:back()
        return not priority[back] or back == '*'
    end

    for i = 1, #str do
        local char = sub(str, i, i)
        local not_operator = not priority[char]

        if q:empty() then
            assert((char == '(' or not_operator), 'Invalid regular expression')
        elseif (char == '(' or not_operator) and should_concat() then
            q:push(concat_operator)
        end

        q:push(char)
    end

    -- INFO : To PostFix
    local st = new.stack()
    local result = new.queue()
    while not q:empty() do
        local char = q:pop()

        if not priority[char] then
            result:push(char)
        else
            if char == '(' then
                st:push(char)
            elseif char == ')' then
                -- INFO :This will invoke assert failed when st empty
                while st:top() ~= '(' do
                    result:push(st:pop())
                end

                st:pop()
            else
                while not st:empty() and priority[st:top()] >= priority[char] do
                    result:push(st:pop())
                end
                st:push(char)
            end
        end
    end

    while not st:empty() do
        result:push(st:pop())
    end

    return result
end


-- Convert Postfix expression into NFA
---@param postfix_queue queue
---@return nfa
local function toNFA(postfix_queue)
    local nfa = new.nfa()
    local st = new.stack()
    local strategy = {
        ---Concat the nfa with another nfa
        ['^'] = function()
            local new_start, new_final = unpack(st:pop())
            local old_start, old_final = unpack(st:pop())

            nfa:add_epsilon_transition(old_final, new_start)
            st:push { old_start, new_final }
        end,
        ---Kleene star the nfa
        ['*'] = function()
            local old_start, old_final = unpack(st:pop())
            local new_start, new_final = nfa:new_state(), nfa:new_state()

            nfa:add_epsilon_transition(new_start, old_start)
            nfa:add_epsilon_transition(old_final, new_final)

            nfa:add_epsilon_transition(old_final, old_start)
            nfa:add_epsilon_transition(new_start, new_final)

            st:push { new_start, new_final }
        end,
        ---Union the nfa with another nfa
        ['|'] = function()
            local new_start, new_final = nfa:new_state(), nfa:new_state()
            local start1, final1 = unpack(st:pop())
            local start2, final2 = unpack(st:pop())

            nfa:add_epsilon_transition(new_start, start1)
            nfa:add_epsilon_transition(new_start, start2)

            nfa:add_epsilon_transition(final1, new_final)
            nfa:add_epsilon_transition(final2, new_final)

            st:push { new_start, new_final }
        end,
    }


    while not postfix_queue:empty() do
        local char = postfix_queue:pop()
        if not priority[char] then
            local start = nfa:new_state()
            local final = nfa:new_state()
            nfa:add_transition(start, final, char)

            st:push { start, final }
        else
            strategy[char]()
        end
    end

    assert(st.size == 1, 'Invalid regular expression')
    nfa.start, nfa.final = unpack(st:top())
    return nfa
end


-- INFO : This Version should be more efficient
-- -- Convert Postfix expression into NFA
-- ---@param postfix_queue queue
-- ---@return nfa
-- local function toNFA(postfix_queue)
--     local st = new.stack()
--     local strategy = {
--         ['^'] = function()
--             local nfa1 = st:pop()
--             local nfa2 = st:pop()

--             st:push(nfa1:concat(nfa2))
--         end,
--         ['*'] = function()
--             st:top():closure()
--         end,
--         ['|'] = function()
--             local nfa1 = st:pop()
--             local nfa2 = st:pop()

--             st:push(nfa1:union(nfa2))
--         end,
--     }


--     while not postfix_queue:empty() do
--         local char = postfix_queue:pop()
--         local not_operator = not priority[char]

--         if not_operator then
--             st:push(new.nfa(char))
--         else
--             strategy[char]()
--         end
--     end
--     assert(st.size == 1, 'Invalid regular expression')
--     return st:top()
-- end


-- Convert NFA into DFA


-- Convert DFA into Minimized DFA


-- Convert Minimized DFA into DFA table


local args_opts = {
    [{
        '-o',
        '--output',
    }] = 'output file',
    [{
        '-h',
        '--help',
        no_arg = true,
    }] = 'show help',
    [{
        '-f',
        '-format',
    }] = 'output format',
    [{
        '-s',
        '--string',
    }] = 'input string',
}

local function show_help()
    print(green 'Usage: lua regex.lua [options?] [regex?]')
    print ''
    print 'Options:'
    for k, v in pairs(args_opts) do
        print(([[%5s %10s      %s]]):format(k[1], k[2], v))
    end

    os.exit()
end

local function parse_args()
    local args = {}
    for i, a in ipairs(arg) do
        if a:sub(1, 1) == '-' then
            local opt = args_opts[a]
            if not opt then
                print(('Invalid option : %s'):format(a))
                os.exit()
            end

            if opt.no_arg then
                args[opt] = true
            else
                args[opt] = arg[i + 1]
                i = i + 1
            end
        else
            show_help()
        end
    end

    return args
end

local result = parse_args()

--- TODO : handle args

-- io.write(green(('请输入正则表达式 : ')))

local RE = io.read()

-- local q = pre_process(RE)
-- print '- 输入字符串 :'
-- print(RE)
-- print ''
local preprocess = pre_process(RE)
-- print '- 预处理并转成后缀表达式 :'
-- print(table.concat(preprocess))
-- print ''
local nfa = toNFA(preprocess)
-- print '- 构建得到NFA :'
-- print ''
print(nfa:to_digraph())
