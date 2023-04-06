#include <cassert>
#include <color.h>
#include <fstream>
#include <iostream>
#include <vector>

using namespace std;

bool isalpha(char ch)
{
    return (ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z');
}

bool isdigit(char ch)
{
    return ch >= '0' && ch <= '9';
}

enum state {
    Init,
    Id,
    GT,
    GE,
    IntLiteral,
};

vector<string> Identifiers;
vector<string> Operators;
vector<string> Separators;
vector<string> Literals;

state current = Init;
string token;

void init_state()
{
    current = Init;
    token.clear();
}

void initProcess(char ch)
{
    if (ch == ' ' || ch == '\n') { return; }
    token += ch;
    if (isalpha(ch))
        current = Id;
    else if (ch == '>')
        current = GT;

    else if (ch == '=')
        current = GE;

    else if (isdigit(ch))
        current = IntLiteral;
    else
    // assert(false);
    {
        cout << "check input string" << endl;
        exit(1);
    }
}

void idProcess(char ch)
{
    if (isalpha(ch)) {
        token += ch;
        return;
    }

    Identifiers.push_back(token);
    init_state();
    initProcess(ch);
}

void gtProcess(char ch)
{
    if (ch == '=') { token += ch; }
    Operators.push_back(token);
    init_state();

    if (ch != '=') initProcess(ch);
}

void geProcess(char ch)
{
    if (ch == '=') { token += ch; }
    Operators.push_back(token);
    init_state();


    if (ch != '=') initProcess(ch);
}

void intLiteralProcess(char ch)
{
    if (isdigit(ch)) {
        token += ch;
        return;
    }

    Literals.push_back(token);
    init_state();
    initProcess(ch);
}

void process(char ch)
{
    if (ch < 0) return;
    /*
        标识符
        关键字
        比较运算符
        分隔符
        字面量
    */
    switch (current) {
        case Init:
            initProcess(ch);
            break;
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
    }
}

int main(int argc, char* argv[])
{
    string filename = argv[1];
    ifstream ifs(filename);
    assert(ifs.is_open());


    while (!ifs.eof())
        process(ifs.get());


    auto line = [](auto obj, string color = Zoran::Dgreen) {
        cout << color << obj << Zoran::Endl;
    };



    auto sep = "======================";
    auto indent = "    ";

    auto print = [&](auto& vec, string name) {
        line(sep);
        line(name + ":", Zoran::Purpor);
        for (auto& item : vec) {
            line(indent + item, Zoran::Green);
        }
    };
    line("");

    // clang-format off
    print(Identifiers , "Identifiers");
    print(Operators   , "Operators");
    print(Separators  , "Separators");
    print(Literals    , "Literals");

    return 0;
}
