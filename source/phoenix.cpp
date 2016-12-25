#include <iostream>
#include <fstream>
#include <cstring>
#include <chrono>       // time
#include <stdint.h>
#define __STDC_FORMAT_MACROS
#include <inttypes.h>
#if defined(_MSC_VER)
    #include <io.h>
#else
    #include <unistd.h>
#endif

#include "def.h"
#include "functions.h"

using std::cout;
using std::chrono::high_resolution_clock;


///////////////////////////////////////////////////////////
/////////                 M A I N                 /////////
///////////////////////////////////////////////////////////
#include <vector>
int32_t main (int argc, char *argv[])
{
    // Record start time
    high_resolution_clock::time_point exeStartTime = high_resolution_clock::now();

    // for access to Functions (object 'function' on memory stack)
//    Functions function;
//    function.commandLineParser(argc, argv); // parse the command line
    
    int a=30;
    int b=1;
    for (int i = 1; i < 3; ++i)
    {
        b*=5;
    }
    
    cout<<(a|b);
    
//    uint8_t u=(uint8_t) 2;
//    uint64_t contextInt = 0;
//    for (int i = 0; i < 3; ++i)
//    {
//        contextInt = contextInt * 5 + u;
//        cout<<contextInt<<'\t';
//    }
    
    
//    int a = 'A';
//    int c = 'C';
//    int g = 'G';
//    int n = 'N';
//    int t = 'T';
//
//    int arr[5] = {a, g, c, n, t};
//
//    for (int i = 0; i != 5; ++i)
//        cout << arr[ i ] << '\n';
    
    
    
    
    // Record end time
    high_resolution_clock::time_point exeFinishTime = high_resolution_clock::now();

    // calculate and show duration in seconds
    std::chrono::duration< double > elapsed = exeFinishTime - exeStartTime;
    cout
//            << '\n'
            << '\t'
//            << "Elapsed time: "
            << elapsed.count()
//            << " s"
            << '\n'
            ;
    
    
    return 0;
}
