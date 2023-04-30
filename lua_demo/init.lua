require 'color'
require 'args'
local new = require 'data'

---print debug message
---@param message any
---@param desc string
---@param color string?
_G.debug = function(message, desc, color)
    if args.debug then
        color = color or 'yellow'
        message = inspect(message)

        print(desc:magenta())
        print(message[color](message))
        print ''
    end
end


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
        return not priority[back] or back == '*' or back == ')'
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


    if st.size ~= 1 then
        pretty_print_table(st)
        error 'Invalid regular expression'
    end

    -- assert(st.size == 1, 'Invalid regular expression')
    nfa.start, nfa.final = unpack(st:top())
    return nfa
end


-- Convert NFA into DFA


-- Convert DFA into Minimized DFA


-- Convert Minimized DFA into DFA table

local RE
if args.string then
    RE = args.string
else
    io.write(('请输入正则表达式 : '):green())
    RE = io.read()
end


local postfix_queue = pre_process(RE)
local postfix = table.concat(postfix_queue)
local nfa = toNFA(postfix_queue)


local file
local write = function(str, color)
    if file then
        file:write(str .. '\n')
    else
        if color then
            str = str[color](str)
        end
        print(str)
    end
end


if args.output then
    if not args.append then
        pcall(os.remove, args.output)
    end

    file = io.open(args.output, 'a')
    assert(file, 'Can not open file ' .. args.output)
end

write('- 正则表达式', 'green')
write ''
write(RE, 'blue')
write ''
write('- 后缀表达式', 'green')
write ''
write(postfix, 'blue')
write ''
write('- 构建得到NFA', 'green')
write ''
write(nfa:to_digraph(), 'blue')
write ''
write('- 构建得到DFA :', 'green')
local dfa = nfa:to_dfa()
write(dfa:to_digraph(), 'blue')
write ''
write('- 最小化DFA:', 'green')
write(dfa:minimal():to_digraph(), 'blue')

if file then file:close() end
