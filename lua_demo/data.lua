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


new.state_set = (function()
    local concat = table.concat
    ---@class state_set
    ---@field size integer The size of the set
    local mt = {
        ---insert states into the set
        ---@param self state_set
        ---@param states integer[]
        ---@return integer @the index of the states
        insert = function(self, states)
            assert(type(states) == 'table', 'this is special set for states')
            self.size = self.size + 1

            -- pretty_print_table(states)
            self[concat(states)] = self.size -- state index
            return self.size
        end,

        ---get the index of the states if not exist then return nil
        ---@param self state_set
        ---@param states integer[]
        ---@return integer|nil
        index = function(self, states)
            assert(type(states) == 'table', 'this is special set for states')
            return self[concat(states)]
        end,
    }

    mt.__index = mt
    return function()
        return setmetatable({
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
        add_transition = function(self, from, to, char)
            -- assert(from <= self.size and to <= self.size, 'Invalid state')

            local transitions = self.transitions
            if transitions[from][char] then
                error(([[
                want to add transition: %d -> %d
                there is an edge: %d -> %d,
                ]]):format(from, to, from, self.transitions[from][char]))
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
                ]]):format(from, to, from, self.transitions[from][char]))
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
            local set      = new.state_set()


            local q0 = self:reached_states(self.start)

            --- FIXME :
            worklist:push(q0)
            set:insert(q0)

            local final = self.final
            local check_final = function(list)
                for _, v in ipairs(list) do
                    if v == final then
                        table.insert(dfa.final, set:index(list))
                    end
                end
            end

            check_final(q0)
            local char_set = self:get_char_set()
            debug(char_set, 'char_set')
            debug(q0, 'Dfa start state')

            ---@param states integer[] the states set
            local function handle(states)
                -- TODO : Check all character in char_set and if there is a new state
                local from = set:index(states)
                assert(from)

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

-- INFO : this version build a nfa via build lots of states tree
-- new.nfa = (function()
--     ---@class nfa
--     ---@field start state The start state
--     ---@field final state The final state
--     local mt = {
--         ---Union the nfa with another nfa
--         ---@param self nfa
--         ---@param other nfa
--         union = function(self, other)
--             local start = new.state {
--                 char = epsilon,
--                 [1]  = self.start,
--                 [2]  = other.start,
--             }

--             local final = new.state {
--             }

--             self.final:add_edge(final)
--             self.final.char = epsilon

--             other.final:add_edge(final)
--             other.final.char = epsilon

--             self.start = start
--             self.final = final

--             return self
--         end,
--         ---Concat the nfa with another nfa
--         ---@param self nfa
--         ---@param other nfa
--         concat = function(self, other)
--             --- INFO :as the stack data structure, so the other should be the first one
--             local final = other.final
--             final:add_edge(self.start)
--             final.char = epsilon

--             other.final = self.final
--             return other
--         end,
--         ---Closure the nfa
--         ---@param self nfa
--         closure = function(self)
--             local final = new.state {}

--             local start = new.state {
--                 char = epsilon,
--                 [1] = self.start,
--                 [2] = final,
--             }

--             self.final:add_edge(self.start)
--             self.final:add_edge(final)
--             self.final.char = epsilon

--             self.start = start
--             self.final = final

--             return self
--         end,
--         ---Return the string of dot language that represents the nfa
--         ---@param self nfa
--         ---@return string
--         to_digraph = function(self)
--             local result = new.queue()
--             result:push '```dot'
--             result:push('// Start State: ' .. self.start.index)
--             result:push('// Final State: ' .. self.final.index)

--             result:push 'digraph {'
--             result:push 'rankdir = LR'

--             -- NOTE : special node style
--             -- result:push 'edge [color=green]'
--             -- result:push(self.start.index .. ' [color=yellow]')
--             -- result:push(self.final.index .. ' [color=green, peripheries=2]')
--             result:push(self.final.index .. ' [peripheries=2]')


--             self.start:get_transition(result)
--             result:push '}'
--             result:push '```'
--             return table.concat(result, '\n')
--         end,
--         ---Convert Nfa to Dfa
--         ---@param self nfa
--         to_dfa = function(self)
--             -- TODO :
--             --1.遍历所有的边
--             local init_state = self.start:get_epsilon()
--             local worklist = new.stack()

--             while not worklist:empty() do
--                 local state = worklist:pop()

--             end
--         end,
--     }


--     mt.__index = mt

--     ---Nfa constructor
--     ---@param char string
--     ---@return nfa
--     return function(char)
--         local state2 = new.state {}

--         local state1 = new.state {
--             char = char,
--             [1] = state2,
--         }

--         return setmetatable({
--             start = state1,
--             final = state2,
--         }, mt)
--     end
-- end)()
-- new.state = (function()
--     local index = 0
--     ---@class state
--     ---@field char string? The character that the state accepts
--     ---@field index integer The index of the state
--     ---@field [1] state? The first next state
--     ---@field [2] state? The second next state
--     local mt = {
--         ---Add an edge to the state
--         ---@param self state
--         ---@param state state
--         add_edge = function(self, state)
--             self[#self + 1] = state
--         end,
--         ---Get transiton string for digraph
--         ---@param self state
--         ---@param result queue? the result for the transition
--         get_transition = function(self, result, visited)
--             visited = visited or {}

--             if visited[self.index] then
--                 return
--             else
--                 visited[self.index] = true
--             end

--             result = result or new.queue()
--             for i = 1, #self do
--                 result:push(string.format('%s -> %s [label="%s"]', self.index, self[i].index, self.char))
--                 self[i]:get_transition(result, visited)
--             end

--             return table.concat(result)
--         end,

--         ---return all states that can be reached from this state via epsilon transition
--         ---@param self state
--         ---@return queue<state>
--         get_epsilon = function(self)
--             local result = new.queue()

--             local worklist = new.stack()
--             worklist:push(self)

--             while not worklist:empty() do
--                 local state = worklist:pop()
--                 result:push(state)
--                 if state.char == epsilon then
--                     for i = 1, #state do
--                         worklist:push(state[i])
--                     end
--                 end
--             end

--             return result
--         end,
--     }
--     mt.__index = mt


--     ---@param opts { start: boolean?, final: boolean?, [1]: state?, [2]: state?, char: string?}
--     ---@return state
--     return function(opts)
--         index = index + 1

--         return setmetatable({
--             char = opts.char,
--             index = index,
--             [1] = opts[1],
--             [2] = opts[2],
--         }, mt)
--     end
-- end)()

return new
