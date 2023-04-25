#include <iostream>
#include <map>
#include <set>
#include <stack>
#include <string>
#include <vector>

using namespace std;

constexpr char epsilon = -1;

class NFA
{
public:
    int num_states;
    int start_state;
    set<int> accept_states;
    map<pair<int, char>, set<int>> transitions;
    map<pair<int, char>, set<int>> epsilon_transitions;

    NFA():
        num_states(0),
        start_state(-1) { }

    int add_state() {
        int new_state = num_states++;
        return new_state;
    }

    void add_transition(int from, char input, int to) {
        transitions[make_pair(from, input)].insert(to);
    }

    void add_epsilon_transition(int from, int to) {
        epsilon_transitions[make_pair(from, epsilon)].insert(to);
    }
};

NFA construct_NFA_from_postfix(const string& postfix) {
    NFA nfa;
    stack<pair<int, int>> state_stack;

    for (char c : postfix) {
        if (islower(c)) {
            int start = nfa.add_state();
            int end = nfa.add_state();
            nfa.add_transition(start, c, end);
            state_stack.push({ start, end });
        }
        else {
            if (c == '*') {
                int old_start, old_end;
                tie(old_start, old_end) = state_stack.top();
                state_stack.pop();

                int new_start = nfa.add_state();
                int new_end = nfa.add_state();
                nfa.add_epsilon_transition(new_start, new_end);
                nfa.add_epsilon_transition(new_start, old_start);
                nfa.add_epsilon_transition(old_end, new_end);
                nfa.add_epsilon_transition(old_end, old_start);
                state_stack.push({ new_start, new_end });
            }
            else if (c == '.') {
                int start2, end2, start1, end1;
                tie(start2, end2) = state_stack.top();
                state_stack.pop();
                tie(start1, end1) = state_stack.top();
                state_stack.pop();

                nfa.add_epsilon_transition(end1, start2);
                state_stack.push({ start1, end2 });
            }
            else if (c == '|') {
                int start2, end2, start1, end1;
                tie(start2, end2) = state_stack.top();
                state_stack.pop();
                tie(start1, end1) = state_stack.top();
                state_stack.pop();

                int new_start = nfa.add_state();
                int new_end = nfa.add_state();
                nfa.add_epsilon_transition(new_start, start1);
                nfa.add_epsilon_transition(new_start, start2);
                nfa.add_epsilon_transition(end1, new_end);
                nfa.add_epsilon_transition(end2, new_end);
                state_stack.push({ new_start, new_end });
            }
        }
    }

    nfa.start_state = state_stack.top().first;
    nfa.accept_states.insert(state_stack.top().second);
    return nfa;
}

int main() {
    string postfix = "ab.c*|"; // Corresponds to the regex (a|b*)c
    NFA nfa = construct_NFA_from_postfix(postfix);
    // NFA is now constructed and can be used for further processing (e.g., run on input strings)
}
