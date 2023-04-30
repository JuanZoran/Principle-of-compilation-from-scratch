local new = {}

---Join tables
---@param tables any[]
local function join(tables)
    local result = {}

    for _, v in ipairs(tables) do
        if type(v) == 'table' then
            for _, _v in ipairs(v) do
                result[#result + 1] = _v
            end
        else
            result[#result + 1] = v
        end
    end

    return result
end


---@alias state integer

new.simple_set = (function()
    ---@class state_set
    ---@field size integer The size of the set
    ---@field get_key fun(states: any):string | integer @The function to index the states
    local mt = {
        ---@param self state_set
        ---@param states any
        ---@return integer @the index of the states
        insert = function(self, states)
            self.size = self.size + 1
            self[self.get_key(states)] = self.size
            return self.size
        end,


        ---@param self state_set
        ---@param states any
        ---@return integer|nil
        index = function(self, states)
            return self[self.get_key(states)]
        end,
    }

    mt.__index = mt

    ---@param get_key fun(states: any[]): integer|string
    ---@param insert_hook function?
    ---@return state_set
    return function(get_key, insert_hook)
        return setmetatable({
            get_key = get_key,
            insert_hook = insert_hook,
            size = 0,
        }, mt)
    end
end)()

new.stack = (function()
    ---@class stack<T>: { [integer]: T}
    ---@field size integer
    local mt = {
        ---Pop the top element of the stack
        ---@param self stack
        ---@return any _ The top element
        pop = function(self)
            assert(not self:empty(), 'Stack is empty')

            local size = self.size
            local value = self[size]
            self[size] = nil
            self.size = size - 1
            return value
        end,
        ---Peek the top element of the stack
        ---@param self stack
        ---@return any # The top element
        top = function(self)
            return self[self.size]
        end,
        ---Push an element into the stack
        ---@param self stack
        ---@param value any _ The element to push
        push = function(self, value)
            self.size = self.size + 1
            self[self.size] = value
        end,
        ---Check if the stack is empty
        ---@param self stack
        ---@return boolean @True if the stack is empty
        empty = function(self)
            return self.size == 0
        end,
        ---Clear the stack
        ---@param self stack
        clear = function(self)
            -- for i = 1, self.size do
            --     self[i] = nil
            -- end
            self.size = 0
        end,
    }
    mt.__index = mt

    ---Stack constructor
    ---@return stack
    return function()
        return setmetatable({
            size = 0,
        }, mt)
    end
end)()

new.queue = (function()
    ---@class queue<T>: {[integer]: T}
    ---@field begin integer _ The index of the first element
    ---@field size integer _ The size of the queue
    local mt = {
        ---Pop the first element of the queue
        ---@param self queue
        ---@return `T` @ The first element
        pop = function(self)
            assert(not self:empty(), 'Queue is empty')
            local begin = self.begin
            local value = self[begin]
            self[begin] = nil

            self.begin  = begin + 1
            return value
        end,

        ---Peek the first element of the queue
        ---@param self queue
        ---@return `T` # The first element
        front = function(self)
            return self[self.begin]
        end,
        ---Peek the last element of the queue
        ---@param self queue
        ---@return `T` @ The last element
        back = function(self)
            return self[self.size]
        end,

        ---Push an element into the queue
        ---@param self queue
        ---@param value `T` The element to Push
        push = function(self, value)
            self.size = self.size + 1
            self[self.size] = value
        end,

        ---Check if the queue is empty
        empty = function(self)
            return self.begin - 1 == self.size
        end,
    }
    mt.__index = mt

    ---Queue constructor
    ---@return queue
    return function()
        return setmetatable({
            begin = 1,
            size = 0,
        }, mt)
    end
end)()


new.dfa = (function()
    ---@class dfa
    ---@field start integer The start state
    ---@field final integer[] The final state set
    ---@field transitions table<integer, table<string, integer>> The transitions table
    ---@field size integer The state count of the dfa
    local mt = {
        ---Add a transition to the dfa
        ---@param self dfa
        ---@param from integer
        ---@param to integer
        ---@param char string
        ---@param strict boolean?
        add_transition = function(self, from, to, char, strict)
            if strict == nil then strict = true end

            local transitions = self.transitions
            if strict and transitions[from][char] then
                error(([[
                want to add transition: %d -> %d
                there is an edge: %d -> %d,
                ]]):format(from, to, from, transitions[from][char]))
            end

            transitions[from][char] = to
        end,

        ---Return the string of dot language that represents the nfa
        ---@param self dfa
        ---@return string
        to_digraph = function(self)
            local result = new.queue()
            result:push '```dot'

            result:push 'digraph {'
            result:push 'rankdir = LR'

            -- pretty_print_table(self.transitions)
            -- NOTE : special node style
            -- result:push 'edge [color=green]'
            -- result:push(self.start.index .. ' [color=yellow]')
            -- result:push(self.final.index .. ' [color=green, peripheries=2]')
            for _, final in ipairs(self.final) do
                result:push(final .. ' [peripheries=2]')
            end


            for from, tos in ipairs(self.transitions) do
                for char, to in pairs(tos) do
                    result:push(from .. ' -> ' .. to .. ' [label="' .. char .. '"]')
                end
            end

            result:push '}'
            result:push '```'

            return table.concat(result, '\n')
        end,

        ---Check if the state is final
        ---@param self dfa
        ---@param state state
        ---@return true?
        is_final = function(self, state)
            for _, final in ipairs(self.final) do
                if final == state then
                    return true
                end
            end
        end,

        ---Get the minimal dfa
        ---@param self dfa
        ---@return dfa
        minimal = function(self)
            local new_dfa = new.dfa()

            local transitions = self.transitions
            local state_set = new.simple_set(function(trans_tbl)
                local tmp = {}
                for char, index in pairs(trans_tbl) do
                    tmp[#tmp + 1] = char .. index
                end

                return table.concat(tmp)
            end)

            ---Get the index of the new state set
            ---@param state state
            local index = function(state)
                local trans_tbl = transitions[state]

                local idx = state_set:index(trans_tbl)
                if not idx then
                    idx = state_set:insert(trans_tbl)
                    if self:is_final(state) then
                        new_dfa.final[#new_dfa.final + 1] = idx
                    end
                end

                return idx
            end

            for from, trans_tbl in ipairs(transitions) do
                for char, to in pairs(trans_tbl) do
                    new_dfa:add_transition(index(from), index(to), char, false)
                end
            end

            return new_dfa
        end,
    }
    mt.__index = mt

    ---Nfa constructor
    ---@return dfa
    return function()
        return setmetatable({
            start = 1,
            final = {},
            transitions = new.empty_list(),
        }, mt)
    end
end)()

new.nfa = (function()
    ---@class nfa
    ---@field start integer The start state
    ---@field final integer The final state
    ---@field transitions table<integer, table<string, integer>> The transitions table
    ---@field epsilon_transitions table<integer, integer[]> The transitions table
    ---@field size integer The state count of the nfa
    local mt = {
        ---Add a transition to the nfa
        ---@param self nfa
        ---@param from integer
        ---@param to integer
        ---@param char string @ The char of the transition
        add_transition = function(self, from, to, char)
            assert(from <= self.size and to <= self.size, 'Invalid state')

            local transitions = self.transitions
            if transitions[from][char] then
                error(([[
                want to add transition: %d -> %d
                there is an edge: %d -> %d,
                ]]):format(from, to, from, transitions[from][char]))
            end

            transitions[from][char] = to
        end,

        ---Add a transition to the nfa
        ---@param self nfa
        ---@param from integer
        ---@param to integer
        add_epsilon_transition = function(self, from, to)
            assert(from <= self.size and to <= self.size, 'Invalid state')

            local trans = self.epsilon_transitions[from]

            trans[#trans + 1] = to
        end,

        ---Add a state to the nfa
        ---@param self nfa
        ---@return integer @ The index of the new state
        new_state = function(self)
            self.size = self.size + 1
            self.transitions[self.size] = {}
            return self.size
        end,

        ---Return the string of dot language that represents the nfa
        ---@param self nfa
        ---@return string
        to_digraph = function(self)
            local result = new.queue()
            result:push '```dot'
            result:push('// Start State: ' .. self.start)
            result:push('// Final State: ' .. self.final)

            result:push 'digraph {'
            result:push 'rankdir = LR'

            -- NOTE : special node style
            result:push(self.start .. ' [color=green]')
            result:push(self.final .. ' [peripheries=2]')

            for from, tos in ipairs(self.transitions) do
                for char, to in pairs(tos) do
                    result:push(from .. ' -> ' .. to .. ' [label="' .. char .. '"]')
                end
            end

            for from, tos in pairs(self.epsilon_transitions) do
                for _, to in ipairs(tos) do
                    result:push(from .. ' -> ' .. to .. ' [style=dotted, label="ε"]')
                end
            end

            result:push '}'
            result:push '```'

            return table.concat(result, '\n')
        end,

        ---Get all the input character in the nfa
        ---@param self nfa
        ---@return table
        get_char_set = function(self)
            local result = {}
            for _, tos in ipairs(self.transitions) do
                for char, _ in pairs(tos) do
                    result[char] = true
                end
            end
            return result
        end,

        ---Get all of the states that can be reached from the given state via the given char
        ---@param self nfa
        ---@param state integer
        ---@return integer[]|nil @ The states that can be reached
        reached_states = function(self, state)
            assert(state <= self.size, 'Invalid state')
            local st = new.stack()
            local result = {}
            st:push(state)
            local check = function(s)
                if not s then return end
                if not result[s] then
                    result[s] = true
                    st:push(s)
                end
            end

            while not st:empty() do
                local s = st:pop()
                check(s)
                local epsilon_transitions = self.epsilon_transitions[s]
                for _, v in ipairs(epsilon_transitions) do
                    check(v)
                end
            end

            local states = {}
            for k, _ in pairs(result) do
                states[#states + 1] = k
            end

            return #states > 0 and states or nil
        end,

        ---convert a nfa to dfa
        ---@param self nfa
        to_dfa = function(self)
            local dfa      = new.dfa()
            local worklist = new.queue()
            local set      = new.simple_set(table.concat)


            local q0 = self:reached_states(self.start)

            worklist:push(q0)
            ---@diagnostic disable-next-line: param-type-mismatch
            set:insert(q0)

            local final = self.final
            local check_final = function(list)
                for _, v in ipairs(list) do
                    if v == final then
                        dfa.final[#dfa.final + 1] = set:index(list)
                        return
                    end
                end
            end

            check_final(q0)
            local char_set = self:get_char_set()
            debug(char_set, 'char_set')
            debug(q0, 'Dfa start state')

            -- TODO : Check all character in char_set and if there is a new state
            ---@param states integer[] the states set
            local function handle(states)
                local from = set:index(states)
                assert(from, 'want to index states:' .. inspect(states) .. '\nset:' .. inspect(set))

                for char, _ in pairs(char_set) do
                    local temp = {}

                    for _, state in ipairs(states) do
                        local to = self.transitions[state][char]
                        if to then
                            temp = join { temp, self:reached_states(to) }
                        end
                    end

                    debug(temp, 'handle state')
                    local to = set:index(temp)
                    if #temp > 0 and not to then
                        debug(temp, 'new state')

                        to = set:insert(temp)
                        worklist:push(temp)

                        check_final(temp)
                    end

                    ---@cast to integer
                    dfa:add_transition(from, to, char)
                end
            end

            while not worklist:empty() do
                handle(worklist:pop())
            end

            return dfa
        end,
    }


    mt.__index = mt

    ---Nfa constructor
    ---@return nfa
    return function()
        return setmetatable({
            size = 0,
            start = 0,
            final = 0,
            transitions = new.empty_list(),
            epsilon_transitions = new.empty_list(),
        }, mt)
    end
end)()


new.empty_list = (function()
    local mt = {
        __index = function(tbl, key)
            tbl[key] = {}
            return tbl[key]
        end,
    }

    return function()
        return setmetatable({}, mt)
    end
end)()

return new
