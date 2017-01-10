#include <iostream>
#include <fstream>
#include <algorithm>
#include <iomanip>      /// setw, setprecision
#include <cstring>      /// memset, memcpy
#include <stdlib.h>

#include "FCM.h"
#include "functions.h"

using std::cout;
using std::cerr;
using std::string;
using std::ifstream;
using std::getline;
using std::to_string;
using std::ios;
using std::memset;
using std::memmove;
using std::fixed;
using std::setprecision;

/// TODO TEST
//using std::chrono::high_resolution_clock;

/***********************************************************
    constructor
************************************************************/
FCM::FCM () {}


/***********************************************************
    build table
************************************************************/
void FCM::buildTable ()
{
    const uint8_t contextDepth  = getContextDepth();    /// get context depth
    const uint16_t alphaDen     = getAlphaDenom();      /// get alpha denominator
    const bool isInvertedRepeat = getInvertedRepeat();  /// get inverted repeat
    /// TODO: supprt for both target and reference file addresses
//    string fileName = getTarFileAddress();              /// get target file address
    string tarFileName = getTarFileAddress();           /// get target file address
    string refFileName = getRefFileAddress();           /// get reference file address


//    const char* filename= fileName.c_str();;
//    std::FILE *fp = std::fopen(filename, "rb");
//    if (fp)
//    {
//        std::string contents;
//        std::fseek(fp, 0, SEEK_END);
//        contents.resize(std::ftell(fp));
//        std::rewind(fp);
//        std::fread(&contents[ 0 ], 1, contents.size(), fp);
//        std::fclose(fp);
//    }
    
    
    ifstream tarFileIn(tarFileName, ios::in);   /// open target file located in fileName
    ifstream refFileIn(refFileName, ios::in);   /// open reference file located in fileName
    
    if (!tarFileIn)                             /// error occurred while opening file
    {
        cerr << "The file '" << tarFileName << "' cannot be opened, or it is empty.\n";
        refFileIn.close();                      /// close file
        return;                                 /// exit this function
    }
    else if (!refFileIn)                        /// error occurred while opening file
    {
        cerr << "The file '" << refFileName << "' cannot be opened, or it is empty.\n";
        refFileIn.close();                      /// close file
        return;                                 /// exit this function
    }

//    ifstream fileIn(fileName, ios::in);         /// open file located in fileName
//
//    if (!fileIn)                                /// error occurred while opening file
//    {
//        cerr << "The file '" << fileName << "' cannot be opened, or it is empty.\n";
//        fileIn.close();                         /// close file
//        return;                                 /// exit this function
//    }
    
    /// create table
    /// 5^TABLE_MAX_CONTEXT < 2^32 => uint32_t is used, otherwise uint64_t
    uint32_t maxPlaceValue = (uint32_t) pow(ALPHABET_SIZE, contextDepth);
    uint64_t tableSize = maxPlaceValue * ALPH_SUM_SIZE;
    uint64_t *table = new uint64_t[ tableSize ];
    
    /// initialize table with 0's
    memset(table, 0, sizeof(table[0]) * tableSize);
    
    uint32_t context = 0;                       /// context (integer), that slides in the dataset
    uint32_t invRepContext = maxPlaceValue - 1; /// inverted repeat context (integer)
    
    ////////////////////////////////
    uint64_t nSym;                      /// number of symbols (n_s). To calculate probability
    uint64_t sumNSyms;                  /// sum of number of symbols (sum n_a). To calculate probability
    double   probability = 0;           /// probability of a symbol, based on an identified context
    double   sumOfEntropies = 0;        /// sum of entropies for different symbols
    uint64_t totalNumberOfSymbols = 0;  /// number of all symbols in the sequence
    double   averageEntropy = 0;        /// average entropy (H)
    //////////////////////////////////
    
    string datasetLine;                 /// keep each line of the file
    
    while (getline(refFileIn, datasetLine))
    {
        
        //////////////////////////////////
        totalNumberOfSymbols += datasetLine.size();    /// number of symbols in each line of dataset
        //////////////////////////////////
        
        /// fill hash table by number of occurrences of symbols A, C, N, G, T
        for (string::iterator lineIter = datasetLine.begin(); lineIter != datasetLine.end(); ++lineIter)
        {
            /// htable includes an array of uint64_t numbers
            char ch = *lineIter;
            uint8_t currSymInt = (uint8_t) ((ch == 'A') ? 0 :
                                            (ch == 'C') ? 1 :
                                            (ch == 'G') ? 3 :
                                            (ch == 'T') ? 4 : 2);
            
//            uint8_t currSymInt = (ch == 'A') ? (uint8_t) 0 :
//                                 (ch == 'C') ? (uint8_t) 1 :
//                                 (ch == 'G') ? (uint8_t) 3 :
//                                 (ch == 'T') ? (uint8_t) 4 : (uint8_t) 2;
//            uint8_t currSymInt = ch % ALPHABET_SIZE;
//            uint8_t currSymInt = (ch == 'C') ? (uint8_t) 3 :
//                                 (ch == 'N') ? (uint8_t) 2 :
//                                 (uint8_t) (ch % ALPHABET_SIZE);
            
            /// update table
            nSym = table[ context * ALPH_SUM_SIZE + currSymInt ]++;
            
            /// considering inverted repeats to update hash table
            if (isInvertedRepeat)
            {
                /// concatenation of inverted repeat context and current symbol
                uint32_t iRCtxCurrSym = (4 - currSymInt) * maxPlaceValue + invRepContext;

//                /// to save quotient and reminder of a division
//                div_t iRCtxCurrSymDiv;
//                iRCtxCurrSymDiv = div(iRCtxCurrSym, ALPHABET_SIZE);

                /// update inverted repeat context (integer)
//                invRepContext = (uint32_t) iRCtxCurrSymDiv.quot;
                invRepContext = (uint32_t) iRCtxCurrSym / ALPHABET_SIZE;

                /// update table considering inverted repeats
//                ++table[ invRepContext*ALPHABET_SIZE + iRCtxCurrSymDiv.rem ];
//                ++table[ invRepContext * ALPHABET_SIZE + iRCtxCurrSym % ALPHABET_SIZE ];
                ++table[ invRepContext * ALPH_SUM_SIZE + iRCtxCurrSym % ALPHABET_SIZE ];
                ++table[ invRepContext * ALPH_SUM_SIZE + ALPHABET_SIZE ];
            }
            
            //////////////////////////////////
            /// sum(n_a)
//            uint64_t *pointerToTable = table;   /// pointer to the beginning of table
//            sumNSyms = 0;
//            for (uint8_t i = 0; i < ALPHABET_SIZE; ++i)
//                sumNSyms += *(pointerToTable + context*ALPHABET_SIZE + i);
            sumNSyms = ++table[ context * ALPH_SUM_SIZE + ALPHABET_SIZE ];

            /// P(s|c^t)
//            probability = (nSym + (double) 1/alphaDen) / (sumNSyms + (double) ALPHABET_SIZE/alphaDen);
            probability = (double) (alphaDen * nSym + 1) / (alphaDen * sumNSyms + ALPHABET_SIZE);

            /// sum( log_2 P(s|c^t) )
            sumOfEntropies += log2(probability);
            /////////////////////////////////
            
            /// update context
            context = (uint32_t) (context * ALPHABET_SIZE + currSymInt) % maxPlaceValue;
            
        }   /// end of for
    }   /// end of while
    
    refFileIn.close();          /// close file
    
    FCM::setTable(table);       /// save the built table
    
    
    ////////////////////////////////
    /// H_N = -1/N sum( log_2 P(s|c^t) )
    averageEntropy = (-1) * sumOfEntropies / totalNumberOfSymbols;

    cout
//            << sumOfEntropies << '\n'
//            << totalNumberOfSymbols << '\n'
            << "  "
            << getInvertedRepeat() << '\t'
            << (float) 1/alphaDen << '\t'
            << (int) contextDepth << '\t'
            << averageEntropy
//            << '\t'
//            << hTable.size()
//            << '\n'
            ;
    ////////////////////////////////
    
}


/***********************************************************
    build hash table
************************************************************/
void FCM::buildHashTable ()
{
    const uint8_t contextDepth  = getContextDepth();    /// get context depth
    const uint16_t alphaDen     = getAlphaDenom();      /// get alpha denominator
    const bool isInvertedRepeat = getInvertedRepeat();  /// get inverted repeat
    /// TODO: supprt for both target and reference file addresses
//    string fileName = getTarFileAddress();              /// get target file address
    string tarFileName = getTarFileAddress();           /// get target file address
    string refFileName = getRefFileAddress();           /// get reference file address
    

//    const char* filename= fileName.c_str();;
//    std::FILE *fp = std::fopen(filename, "rb");
//    if (fp)
//    {
//        std::string contents;
//        std::fseek(fp, 0, SEEK_END);
//        contents.resize(std::ftell(fp));
//        std::rewind(fp);
//        std::fread(&contents[ 0 ], 1, contents.size(), fp);
//        std::fclose(fp);
//    }
    
    
    ifstream tarFileIn(tarFileName, ios::in);   /// open target file located in fileName
    ifstream refFileIn(refFileName, ios::in);   /// open reference file located in fileName

    if (!tarFileIn)                             /// error occurred while opening file
    {
        cerr << "The file '" << tarFileName << "' cannot be opened, or it is empty.\n";
        refFileIn.close();                      /// close file
        return;                                 /// exit this function
    }
    else if (!refFileIn)                        /// error occurred while opening file
    {
        cerr << "The file '" << refFileName << "' cannot be opened, or it is empty.\n";
        refFileIn.close();                      /// close file
        return;                                 /// exit this function
    }
    
//    ifstream fileIn(fileName, ios::in);         /// open file located in fileName
//
//    if (!fileIn)                                /// error occurred while opening file
//    {
//        cerr << "The file '" << fileName << "' cannot be opened, or it is empty.\n";
//        fileIn.close();                         /// close file
//        return;                                 /// exit this function
//    }

    uint64_t context = 0;                       /// context, that slides in the dataset
    uint64_t maxPlaceValue = (uint64_t) pow(ALPHABET_SIZE, contextDepth);
    uint64_t invRepContext = maxPlaceValue - 1; /// inverted repeat context
    
    htable_t hTable;                            /// create hash table
    hTable.insert({context, {0, 0, 0, 0, 0}});  /// initialize hash table with 0's
    
    //////////////////////////////////
    uint64_t nSym;                     /// number of symbols (n_s). To calculate probability
    uint64_t sumNSyms;                 /// sum of number of symbols (sum n_a). To calculate probability
    double   probability = 0;          /// probability of a symbol, based on an identified context
    double   sumOfEntropies = 0;       /// sum of entropies for different symbols
    uint64_t totalNumberOfSymbols = 0; /// number of all symbols in the sequence
    double   averageEntropy = 0;       /// average entropy (H)
    //////////////////////////////////

    string datasetLine;                /// keep each line of the file

    while (getline(refFileIn, datasetLine))
    {

        //////////////////////////////////
        totalNumberOfSymbols += datasetLine.size();    /// number of symbols in each line of dataset
        //////////////////////////////////

        /// fill hash table by number of occurrences of symbols A, C, N, G, T
        for (string::iterator lineIter = datasetLine.begin(); lineIter != datasetLine.end(); ++lineIter)
        {
            /// htable includes an array of uint64_t numbers
            char ch = *lineIter;
            uint8_t currSymInt = (uint8_t) ((ch == 'A') ? 0 :
                                            (ch == 'C') ? 1 :
                                            (ch == 'G') ? 3 :
                                            (ch == 'T') ? 4 : 2);
    
//            uint8_t currSymInt = (ch == 'A') ? (uint8_t) 0 :
//                                 (ch == 'C') ? (uint8_t) 1 :
//                                 (ch == 'G') ? (uint8_t) 3 :
//                                 (ch == 'T') ? (uint8_t) 4 : (uint8_t) 2;
//            uint8_t currSymInt = ch % 5;
//            uint8_t currSymInt = (ch == 'C') ? (uint8_t) 3 :
//                                 (ch == 'N') ? (uint8_t) 2 :
//                                 (uint8_t) (ch % ALPHABET_SIZE);

            /// update hash table
            nSym = hTable[ context ][ currSymInt ]++;
    
            /// considering inverted repeats to update hash table
            if (isInvertedRepeat)
            {
                /// concatenation of inverted repeat context and current symbol
                uint64_t iRCtxCurrSym = (4 - currSymInt) * maxPlaceValue + invRepContext;
        
                /// to save quotient and reminder of a division
//                div_t iRCtxCurrSymDiv;
//                iRCtxCurrSymDiv = div(iRCtxCurrSym, ALPHABET_SIZE);
        
                /// update inverted repeat context (integer)
//                invRepContext =  iRCtxCurrSymDiv.quot;
                invRepContext = (uint64_t) iRCtxCurrSym / ALPHABET_SIZE;
                
                /// update table considering inverted repeats
//                ++hTable[ invRepContext ][ iRCtxCurrSymDiv.rem];
                ++hTable[ invRepContext ][ iRCtxCurrSym % ALPHABET_SIZE ];
            }

            //////////////////////////////////
            /// the idea of adding 'sum' column, makes hash table slower
            /// sum(n_a)
            sumNSyms = 0;
            for (uint64_t u : hTable[ context ])    sumNSyms += u;

            /// P(s|c^t)
//            probability = (nSym + (double) 1/alphaDen) / (sumNSyms + (double) ALPHABET_SIZE/alphaDen);
            probability = (double) (alphaDen * nSym + 1) / (alphaDen * sumNSyms + ALPHABET_SIZE);

            /// sum( log_2 P(s|c^t) )
            sumOfEntropies += log2(probability);
            /////////////////////////////////

            /// update context
            context = (uint64_t) (context * ALPHABET_SIZE + currSymInt) % maxPlaceValue;
            
        }   /// end of for
    }   /// end of while
    
    refFileIn.close();             /// close file

    FCM::setHashTable(hTable);  /// save the built hash table

    ////////////////////////////////
    /// H_N = -1/N sum( log_2 P(s|c^t) )
    averageEntropy = (-1) * sumOfEntropies / totalNumberOfSymbols;

    cout
//            << sumOfEntropies << '\n'
//            << totalNumberOfSymbols << '\n'
            << "  "
            << getInvertedRepeat() << '\t'
            << (float) 1/alphaDen << '\t'
            << (int) contextDepth << '\t'
            << averageEntropy
//            << '\t'
//            << hTable.size()
//            << '\n'
            ;
    ////////////////////////////////

}


///***********************************************************
//    build hash table (string key)
//************************************************************/
/* COMMENT

void FCM::buildHashTable_str ()
{
    const uint8_t contextDepth  = getContextDepth();    /// get context depth
    const uint16_t alphaDen     = getAlphaDenom();      /// get alpha denominator
    const bool isInvertedRepeat = getInvertedRepeat();  /// get inverted repeat
    /// TODO: supprt for both target and reference file addresses
    string fileName = getTarFileAddress();              /// get target file address


//    const char* filename= fileName.c_str();;
//    std::FILE *fp = std::fopen(filename, "rb");
//    if (fp)
//    {
//        std::string contents;
//        std::fseek(fp, 0, SEEK_END);
//        contents.resize(std::ftell(fp));
//        std::rewind(fp);
//        std::fread(&contents[ 0 ], 1, contents.size(), fp);
//        std::fclose(fp);
//    }


    ifstream fileIn(fileName, ios::in);         /// open file located in fileName

    if (!fileIn)                                /// error occurred while opening file
    {
        cerr << "The file '" << fileName << "' cannot be opened, or it is empty.\n";
        fileIn.close();                         /// close file
        return;                                 /// exit this function
    }

    string context(contextDepth, '0');          /// context, that slides in the dataset

    htable_str_t hTable;                        /// create hash table
    hTable.insert({context, {0, 0, 0, 0, 0}});  /// initialize hash table with 0'z

    ////////////////////////////////
    uint64_t nSym;                     /// number of symbols (n_s). To calculate probability
    uint64_t sumNSyms;                 /// sum of number of symbols (sum n_a). To calculate probability
    double   probability = 0;          /// probability of a symbol, based on an identified context
    double   sumOfEntropies = 0;       /// sum of entropies for different symbols
    uint64_t totalNumberOfSymbols = 0; /// number of all symbols in the sequence
    double   averageEntropy = 0;       /// average entropy (H)
    //////////////////////////////////

    string datasetLine;                /// keep each line of the file

    while (getline(fileIn, datasetLine))
    {

        //////////////////////////////////
        totalNumberOfSymbols += datasetLine.size();    /// number of symbols in each line of dataset
        //////////////////////////////////

        /// fill hash table by number of occurrences of symbols A, C, N, G, T
        for (string::iterator lineIter = datasetLine.begin(); lineIter != datasetLine.end(); ++lineIter)
        {
            /// htable includes an array of uint64_t numbers
            char c = *lineIter;
            uint8_t currSymInt = (c == 'A') ? (uint8_t) 0 :
                                 (c == 'C') ? (uint8_t) 1 :
                                 (c == 'G') ? (uint8_t) 3 :
                                 (c == 'T') ? (uint8_t) 4 : (uint8_t) 2;
//            const uint8_t currSymInt = c % 5;

            /// update hash table
            nSym = hTable[ context ][ currSymInt ]++;

            /// considering inverted repeats to update hash table
            if (isInvertedRepeat)
            {
                /// save inverted repeat context
                string invRepeatContext = to_string(4 - currSymInt);
                /// convert a number from char into integer format. '0'->0. '4'->4 by
                /// 4 - (context[ i ] - 48) = 52 - context[ i ]. 48 is ASCII code of '0'
                for (string::iterator it = context.end() - 1; it != context.begin(); --it)
                    invRepeatContext += to_string(52 - *it);
                /// update hash table considering inverted repeats
                ++hTable[ invRepeatContext ][ 52 - context[ 0 ]];
            }

            //////////////////////////////////
            /// sum(n_a)
            sumNSyms = 0;
            for (uint64_t u : hTable[ context ])    sumNSyms += u;

            /// P(s|c^t)
//            probability = (nSym + (double) 1/alphaDen) / (sumNSyms + (double) ALPHABET_SIZE/alphaDen);
            probability = (double) (alphaDen * nSym + 1) / (alphaDen * sumNSyms + ALPHABET_SIZE);

            /// sum( log_2 P(s|c^t) )
            sumOfEntropies += log2(probability);
            /////////////////////////////////

            /// update context
            context = context.substr(1, (unsigned) contextDepth - 1) + to_string(currSymInt);

////            *context.end() = currSymInt;

//////            memcpy(context, context + 1, contextDepth - 1);
//////            context[ contextDepth-1 ] = currSymInt;
//////              *(context+contextDepth-1) = currSymInt;

        }   /// end of for
    }   /// end of while

    fileIn.close();                 /// close file

    FCM::setHashTable_str(hTable);  /// save the built hash table

    ////////////////////////////////
    /// H_N = -1/N sum( log_2 P(s|c^t) )
    averageEntropy = (-1) * sumOfEntropies / totalNumberOfSymbols;

    cout
//            << sumOfEntropies << '\n'
//            << totalNumberOfSymbols << '\n'
            << "  "
            << getInvertedRepeat() << '\t'
//            << (float) 1/alphaDen << '\t'
            << (int) contextDepth << '\t'
            << averageEntropy
//            << '\t'
//            << hTable.size()
//            << '\n'
            ;
    ////////////////////////////////

}

*/ // end of COMMENT


/***********************************************************
    print hash table
************************************************************/
void FCM::printHashTable () const
{
    htable_t hTable = this->getHashTable();
    
    string tar_or_ref = (this->getTargetOrReference() == 't' ? "target" : "reference");
    string Tar_or_Ref = (this->getTargetOrReference() == 't' ? "Target" : "Reference");
    
    cout
         << " >>> Context model:\t\tBuilt from "  << tar_or_ref << '\n'
         << " >>> Context order size:\t" << (uint16_t) this->getContextDepth() << '\n'
         << " >>> Alpha denominator:\t\t" << (uint16_t) this->getAlphaDenom() << '\n'
         << " >>> Inverted repeat:\t\t" << (this->getInvertedRepeat() ? "Considered"
                                                                      : "Not considered")
         << '\n'
         << " >>> " << Tar_or_Ref << " file address:\t"
         /// TODO: this line must be changed
         // << ( tar_or_ref == "target" ? this->getTarFileAddress() : this->getRefFileAddress() )
         << ( tar_or_ref == "target" ? this->getTarFileAddress() : this->getTarFileAddress() )
         << "\n\n";
    
    cout << "\tA\tC\tN\tG\tT"
         //              << "\tP_A\tP_C\tP_N\tP_G\tP_T"
         << '\n'
         << "\t-----------------------------------"
         //              << "------------------------------------------"
         << '\n';

    for (htable_t::iterator it = hTable.begin(); it != hTable.end(); ++it)
    {
        cout << it->first;
        cout << "\t";
        for (uint64_t i : it->second)    cout << i << "\t";
        cout << '\n';
    }
    cout << '\n';
}


/***********************************************************
    getters and setters
************************************************************/
char FCM::getTargetOrReference () const               { return targetOrReference;      }
void FCM::setTargetOrReference (char tOrR)            { FCM::targetOrReference = tOrR; }
uint8_t FCM::getContextDepth () const                 { return contextDepth;           }
void FCM::setContextDepth (uint8_t ctxDp)             { FCM::contextDepth = ctxDp;     }
uint16_t FCM::getAlphaDenom () const                  { return alphaDenom;             }
void FCM::setAlphaDenom (uint16_t alphaDen)           { FCM::alphaDenom = alphaDen;    }
bool FCM::getInvertedRepeat () const                  { return invertedRepeat;         }
void FCM::setInvertedRepeat (bool invRep)             { FCM::invertedRepeat = invRep;  }
uint64_t *FCM::getTable () const                      { return table;                  }
void FCM::setTable (uint64_t *tbl)                    { FCM::table = tbl;              }
const htable_t &FCM::getHashTable () const            { return hashTable;              }
void FCM::setHashTable (const htable_t &hT)           { FCM::hashTable = hT;           }
//const htable_str_t &FCM::getHashTable_str () const    { return hashTable_str;          }
//void FCM::setHashTable_str (const htable_str_t &hT_s) { FCM::hashTable_str = hT_s;     }
const string &FCM::getTarFileAddress () const         { return tarFileAddress;         }
void FCM::setTarFileAddress (const string &tFA)       { FCM::tarFileAddress = tFA;     }
const string &FCM::getRefFileAddress () const         { return refFileAddress;         }
void FCM::setRefFileAddress (const string &rFA)       { FCM::refFileAddress = rFA;     }
