#include "functions.h"
#include "messages.h"

#include <iostream>
#include <getopt.h>     // for command line parsing
#include <string>


/***********************************************************
    constructor
************************************************************/
Functions::Functions () {}


/***********************************************************
    command line parser
************************************************************/
int32_t Functions::commandLineParser (int argc, char **argv)
{
    // using these flags, if both short and long arguments
    // are entered, just one of them is considered
    static int h_flag;  // option 'h' (help)
    static int V_flag;  // option 'V' (version)
    static int v_flag;  // option 'v' (verbose)
    static int i_flag;  // option 'i' (inverted_repeat)
    
    static int n_flag;  // option 'i' (inverted_repeat)
    
    static int t_flag;                  // argument 't'

    int c;              // deal with getopt_long()
    int option_index;

    opterr = 0;         // force getopt_long() to remain silent when it finds a problem

    static struct option long_options[] =
            {
                    {"help",            no_argument, &h_flag, (int) 'h'},   // help
                    {"version",         no_argument, &V_flag, (int) 'V'},   // version
                    {"verbose",         no_argument, &v_flag, (int) 'v'},   // verbose
                    {"inverted_repeat", no_argument, &i_flag, (int) 'i'},   // inverted_repeat
                    {"number",    required_argument,      &n_flag, (int)      'n'},   // number (integer)
//                    {"number",    required_argument,       0,       'n'},   // number (integer)
                    {"fnumber",   required_argument,       0,       'd'},   // number (float)
//                    {"target",      required_argument, 0,       't'}, // target file
//                    {"reference",   required_argument, 0,       'r'}, // reference file
                    {"target", required_argument, &t_flag, (int)'t'},       // target file
                    {0, 0, 0, 0}
            };

    while (1)
    {
        /* getopt_long() stores the option index here. */
        option_index = 0;

        c = getopt_long(argc, argv, ":hVvin:d:t:r:", long_options, &option_index);

        /* Detect the end of the options. */
        if (c == -1)
            break;

        switch (c)
        {
            case 0:
                /* If this option set a flag, do nothing else now. */
                if (long_options[ option_index ].flag != 0)
                    break;

                std::cout << "option '" << long_options[ option_index ].name << "'\n";
                if (optarg)
                    std::cout << " with arg " << optarg << "\n";
                break;

            case 'h':   // shows usage guide
                h_flag = 1;
                break;

            case 'V':   // shows version number
                V_flag = 1;
                break;

            case 'v':   // verbose mode
                v_flag = 1;
                break;
    
            case 'i':   // inverted_repeat mode
                i_flag = 1;
                break;

            case 'n':   // needs an integer argument
                try
                {
                    if ( !std::stoi((std::string) optarg) );
                    else
                    {
                        n_flag = 1;
                        Messages::number(std::stoi((std::string) optarg));    //for test
                    }
                }
                catch (const std::invalid_argument& ia)
                {
                    std::cerr << "Option 'n' ('number') has an invalid argument.\n";
                }
                break;
    
            case 'd':   // needs a float argument
                try
                {
                    Messages::fnumber( std::stof((std::string) optarg) );   //for test
                }
                catch (const std::invalid_argument& ia)
                {
                    std::cerr << "Option 'd' ('fnumber') has an invalid argument.\n";
                }
                break;
    
            case 't':   // needs target file name
//                try
//                {
////                    std::cout << (std::string) optarg << "\n";//for test
//
                t_flag=1;
//                std::string q=(std::string) optarg;
//                    std::ifstream targetFile(q, std::ios::in);
    
//                    if (!targetFile)
//                    {
//                        std::cerr << "File could not be opened.\n";
//                        return 1;
//                    }
//
//                    std::string strEachLine;
//                    std::string strDataset;
//
//                    while (std::getline(targetFile, strEachLine))
//                        strDataset += strEachLine;
//
//                    targetFile.close();
//                    // file closed
//                }
//                catch (const std::invalid_argument& ia)
//                {
//                    std::cerr << "Option 't' ('target') has an invalid argument.\n";
//                }
                break;
    
            case 'r':   // needs reference file name
                try
                {
                    std::cout << (std::string) optarg << "\n";//for test
                }
                catch (const std::invalid_argument& ia)
                {
                    std::cerr << "Option 'r' ('reference') has an invalid argument.\n";
                }
                break;
                
            case ':':   /* missing option argument */
                std::cerr << "Option '" << (char) optopt << "' requires an argument.\n";
                break;

            case '?':   /* invalid option */
            default:
                std::cerr << "Option '" << (char) optopt << "' is invalid.\n";
                break;
        }
    }
    
    if (h_flag) Messages::help();
    if (V_flag) Messages::version();
    if (v_flag) Messages::verbose();
    if (i_flag) Messages::inverted_repeat();
    if (n_flag) Messages::number( 123 );
    
    /* Print any remaining command line arguments (not options). */
    if (optind < argc)
    {
        std::cerr << "non-option ARGV-element(s): ";
        while (optind < argc)
            std::cerr << argv[ optind++ ] << " ";
        std::cerr << std::endl;
    }
}
