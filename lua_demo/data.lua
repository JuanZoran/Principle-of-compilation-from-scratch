local new = {}

new.stack = (function()
    ---@class stack
    ---@field size number
    ---@field [integer] any
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
        ---@return boolean _ True if the stack is empty
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
    ---@class queue
    ---@field begin integer _ The index of the first element
    ---@field size integer _ The size of the queue
    ---@field [integer] any _ The elements
    local mt = {
        ---Pop the first element of the queue
        ---@param self queue
        ---@return any _ The first element
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
        ---@return any _ The first element
        front = function(self)
            return self[self.begin]
        end,

        ---Peek the last element of the queue
        ---@param self queue
        ---@return any _ The last element
        back = function(self)
            return self[self.size]
        end,

        ---Push an element into the queue
        ---@param self queue
        ---@param value any The element to Push
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
    return function()
        return setmetatable({
            begin = 1,
            size = 0,
        }, mt)
    end
end)()


new.state = (function()
    local index = 0

    ---@class state
    ---@field char string? The character that the state accepts
    ---@field index integer The index of the state
    ---@field [1] state? The first next state
    ---@field [2] state? The second next state
    local mt = {
        ---Add an edge to the state
        ---@param self state
        ---@param state state
        add_edge = function(self, state)
            self[#self + 1] = state
        end,

        ---Set the character that the state accepts
        ---@param self state
        ---@param char string
        set_accept = function(self, char)
            self.char = char
        end,

        ---Get transiton string for digraph
        ---@param self state
        ---@param result queue? the result for the transition
        get_transition = function(self, result, visited)
            visited = visited or {}

            if visited[self] then
                return
            else
                visited[self] = true
            end

            result = result or new.queue()
            for i = 1, #self do
                result:push(string.format('%s -> %s [label="%s"]', self.index, self[i].index, self.char))
                self[i]:get_transition(result, visited)
            end

            return table.concat(result)
        end,
    }
    mt.__index = mt


    ---@param opts { start: boolean?, final: boolean?, [1]: state?, [2]: state?, char: string?}
    ---@return state
    return function(opts)
        if type(opts) == 'string' then
            opts = {
                char = opts,
            }
        end
        index = index + 1

        return setmetatable({
            char = opts.char,
            index = index,
            [1] = opts[1],
            [2] = opts[2],
        }, mt)
    end
end)()

new.nfa = (function()
    local epsilon = 'ε'


    ---@class nfa
    ---@field start state The start state
    ---@field final state The final state
    local mt = {
        ---Union the nfa with another nfa
        ---@param self nfa
        ---@param other nfa
        union = function(self, other)
            local start = new.state {
                char = epsilon,
                [1]  = self.start,
                [2]  = other.start,
            }

            local final = new.state {
            }

            self.final:add_edge(final)
            self.final:set_accept(epsilon)

            other.final:add_edge(final)
            other.final:set_accept(epsilon)

            self.start = start
            self.final = final

            return self
        end,


        ---Concat the nfa with another nfa
        ---@param self nfa
        ---@param other nfa
        concat = function(self, other)
            --- INFO :as the stack data structure, so the other should be the first one
            local final = other.final
            final:add_edge(self.start)
            final:set_accept(epsilon)

            other.final = self.final
            return other
        end,

        ---Closure the nfa
        ---@param self nfa
        closure = function(self)
            local final = new.state {}

            local start = new.state {
                char = epsilon,
                [1] = self.start,
                [2] = final,
            }

            self.final:add_edge(self.start)
            self.final:add_edge(final)
            self.final:set_accept(epsilon)

            self.start = start
            self.final = final

            return self
        end,

        ---Return the string of dot language that represents the nfa
        ---@param self nfa
        ---@return string
        to_digraph = function(self)
            local result = new.queue()
            result:push '```dot'
            result:push('// Start State: ' .. self.start.index)
            result:push('// Final State: ' .. self.final.index)

            result:push 'digraph {'
            result:push 'rankdir = LR'
            -- NOTE : special node style

            -- result:push 'edge [color=green]'
            -- result:push(self.start.index .. ' [color=yellow]')
            -- result:push(self.final.index .. ' [color=green]')


            self.start:get_transition(result)
            result:push '}'
            result:push '```'
            return table.concat(result, '\n')
        end,
    }


    mt.__index = mt

    ---Nfa constructor
    ---@param char string
    ---@return nfa
    return function(char)
        local state2 = new.state {
        }

        local state1 = new.state {
            char = char,
            [1] = state2,
        }

        return setmetatable({
            start = state1,
            final = state2,
        }, mt)
    end
end)()


return new
