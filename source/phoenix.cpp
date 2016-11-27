#include <iostream>
#include <fstream>
#include <cstring>
#include <chrono>               // dealing with time
#include <stdint.h>
#define __STDC_FORMAT_MACROS
#include <inttypes.h>
#if defined(_MSC_VER)
#include <io.h>
#else
#include <unistd.h>
#endif

#include "def.h"
#include "messages.h"
#include "functions.h"
#include "hash.h"



///////////////////////////////////////////////////////////
/////////                 M A I N                 /////////
///////////////////////////////////////////////////////////
#include <string>
int32_t main (int argc, char *argv[])
{
    // for calculating execution time
    typedef std::chrono::high_resolution_clock highResClock;

    // Record start time
    highResClock::time_point exeStartTime = highResClock::now();




    Functions function; // for access to Functions (object 'function' on memory stack)
    function.commandLineParser(argc, argv);
    
    
//    std::string s ="a";
//    std::cout << ""+s;
//    std::string secondlevel ("cplusplus");
//    std::cout << "www." + secondlevel + '.' << '\n';


    // Record end time
    highResClock::time_point exeFinishTime = highResClock::now();

    // calculate and show duration in seconds
    std::chrono::duration< double > elapsed = exeFinishTime - exeStartTime;
    std::cout << "\nElapsed time: " << elapsed.count() << " s\n";
    
    
    return 0;
}