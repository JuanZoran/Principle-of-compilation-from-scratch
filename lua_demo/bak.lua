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
