#include <cassert>
#include <color.h>
#include <fstream>
#include <iostream>
#include <vector>

using namespace std;
using namespace Zoran;

bool isalpha(char ch) {
    return (ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z');
}

bool isdigit(char ch) {
    return ch >= '0' && ch <= '9';
}

enum state {
    Init,
    Id,
    GT,
    GE,
    IntLiteral,
};

constexpr auto keyword = {
    "int",
    "char",
};


void initProcess(char ch);
void idProcess(char ch);
void gtProcess(char ch);
void geProcess(char ch);
void intLiteralProcess(char ch);

vector<string> Identifiers;
vector<string> Operators;
vector<string> Literals;
vector<string> Keywords;

state current = Init;
string token;

/* NOTE :
    标识符
    关键字
    比较运算符
    分隔符
    字面量
*/

bool isSeparator(char ch) {
    return ch == '\n' || ch == ' ' || ch == '\t';
}

void process(char ch) {
    if (ch == char(255)) { return; }

    if (current == Init) { initProcess(ch); }

    switch (current) {
        case Id:
            idProcess(ch);
            break;
        case GT:
            gtProcess(ch);
            break;
        case GE:
            geProcess(ch);
            break;
        case IntLiteral:
            intLiteralProcess(ch);
            break;
        default:
            break;
    }
}

void initProcess(char ch) {
    if (isSeparator(ch)) { return; }

    if (isalpha(ch)) { current = Id; }
    else if (ch == '>') { current = GT; }

    else if (ch == '=') { current = GE; }

    else if (isdigit(ch)) { current = IntLiteral; }
    else {
        cout << "check input string:" << ch << endl;
        exit(1);
    }
}

void init_state(char ch = -1) {
    current = Init;
    token.clear();
    initProcess(ch);
    if (ch > 0) { process(ch); }
}

void idProcess(char ch) {
    if (isalpha(ch)) {
        token += ch;
        return;
    }

    Identifiers.push_back(token);
    init_state(ch);
}

void gtProcess(char ch) {
    if (ch == '>' || ch == '=') {
        token += ch;
        return;
    }

    Operators.push_back(token);
    init_state(ch);
}

void geProcess(char ch) {
    if (ch == '=') {
        token += ch;
        return;
    }
    Operators.push_back(token);
    init_state(ch);
}

void intLiteralProcess(char ch) {
    if (isdigit(ch)) {
        token += ch;
        return;
    }

    Literals.push_back(token);
    init_state(ch);
}

void keywordProcess() {
    for (auto i = Identifiers.begin(); i != Identifiers.end(); i++) {
        for (auto& word : keyword) {
            if (*i == word) {
                Keywords.push_back(*i);
                Identifiers.erase(i);
            }
        }
    }
}

int main(int argc, char* argv[]) {
    string filename = argv[1];
    ifstream ifs(filename);
    assert(ifs.is_open());

    while (!ifs.eof())
        process(ifs.get());

    keywordProcess();
    auto sep = "======================";
    auto indent = "    ";

    auto print = [&](auto& vec, string name) {
        line(sep);
        line(name + ":", Purpor);
        for (auto& item : vec) {
            line(indent + item, Zoran::Green);
        }
    };
    line("");

    // clang-format off
    print(Identifiers , "Identifiers");
    print(Operators   , "Operators");
    print(Literals    , "Literals");
    print(Keywords    , "Keywords");

    return 0;
}
