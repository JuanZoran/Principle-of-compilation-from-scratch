#include <cassert>
#include <fstream>
#include <iostream>


using namespace std;

enum state {
    Init,
    Id,
    GT,
    GE,
    IntLiteral,
};

int main(int argc, char** argv)
{
    assert(argc == 2);
    string filename = argv[1];

    cout << "hello world!" << endl;
    return 0;
}
