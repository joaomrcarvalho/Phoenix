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
    Functions function;
    function.commandLineParser(argc, argv); // parse the command line
    
//
//    int index = 1;
//    int *ar = new int[10];
//    for (int i = 0; i < 10; ++i)    ar[ i ] = i;
//
//    int *p = ar;
//    int sum = 0;
//    for (int j = 0; j < ALPHABET_SIZE; ++j) sum += *(p + index*ALPHABET_SIZE + j);
//
//    cout << sum;
    
    
    
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
