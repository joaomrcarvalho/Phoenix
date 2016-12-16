#!/bin/bash

#***********************************************************
#   change directory to "source" and make the project
#***********************************************************
cd ..
cmake source
make


#***********************************************************
#   parameters to install and run needed programs
#***********************************************************
INSTALL_XS=0    # to install "XS" from Github
INSTALL_goose=0 # to install "goose" from Github
GEN_DATASETS=0  # generate datasets using "XS"
GEN_MUTATIONS=1 # generate mutations using "goose"
RUN=0           # run the program
PLOT_RESULTS=0  # plot results using "gnuplot"

# mutations list:   `seq -s' ' 1 10`
#MUT_LIST="1 2 3 4 5 6 7 8 9 10 12 14 16 18 20 25 30 35 40 45 50"
MUT_LIST="1 2"

## datasets: human chromosomes full list
#for i in chr{1..22} chr{X,Y,MT} alts unlocalized unplaced
#do  datasets+="hs_ref_GRCh38.p7_"${i}".fa ";   done
HUMAN_CHR="hs_ref_GRCh38.p7_"
datasets="${HUMAN_CHR}chr21"

INV_REPEATS="0"     # list of inverted repeats      "0 1"
ALPHA_DENS="20"     # list of alpha denominators    "1 20 100"
MAX_CTX=3          # max context size              real: -=1

PIX_FORMAT=png      # output format: png, svg
#rm -f *.$PIX_FORMAT# remove FORMAT pictures, if they exist

IR_NAME=i           # inverted repeat name
a_NAME=a           # alpha denominator name


#***********************************************************
#   install "XS" from Github
#***********************************************************
if [[ $INSTALL_XS == 1 ]]; then

rm -fr XS
git clone https://github.com/pratas/XS.git
cd XS
make
cd ..

fi  # end of installing "XS"


#***********************************************************
#   install "goose" from Github
#***********************************************************
if [[ $INSTALL_goose == 1 ]]; then

rm -fr goose-* goose/ SAMPLE*
git clone https://github.com/pratas/goose.git
cd goose/src
make
cd ../../

fi  # end of installing "goose"


#***********************************************************
#   generate datasets using "XS"
#***********************************************************
if [[ $GEN_DATASETS == 1 ]]; then

XS/XS -ls 100 -n 100000 -rn 0 -f 0.20,0.20,0.20,0.20,0.20 -eh -eo -es datasetXS
# add ">X" as the header of the sequence (build "nonRepX")
echo ">X" > HEADER
cat HEADER datasetXS > dataset
rm -f HEADER

fi  # end of generating datasets using "XS"


#***********************************************************
#   generate mutations using "goose"
#***********************************************************
if [[ $GEN_MUTATIONS == 1 ]]; then

#NUM_MUTATIONS=1     # number of mutations to be generated

for d in $datasets; do
    for x in $MUT_LIST; do      #((x=1; x<$((NUM_MUTATIONS+1)); x+=1));
    MRATE=`echo "scale=3;$x/100" | bc -l`;      # handle transition 0.09 -> 0.10
    goose/src/goose-mutatefasta -s $x -a5 -mr $MRATE " " < ./chromosomes/${d}.fa > temp;
    cat temp | grep -v ">" > ${d}_$x      # remove the header line
    done
done
rm -f temp*    # remove temporary files

#-----------------------------------
#   move all generated mutations files to "datasets" folder
#-----------------------------------
rm -fr datasets
mkdir -p datasets
mv ./${HUMAN_CHR}* datasets

fi  # end of generating mutations using "goose"


#***********************************************************
#   running the program
#***********************************************************
if [[ $RUN == 1 ]]; then

for ir in $INV_REPEATS; do
    for alphaDen in $ALPHA_DENS; do
        for dataset in $datasets; do
#        rm -f $IR_NAME$ir-$a_NAME$alphaDen-${dataset}.dat
        touch $IR_NAME$ir-$a_NAME$alphaDen-$dataset.dat
        echo -e "# mut\tmin_bpb\tmin_ctx" >> $IR_NAME$ir-$a_NAME$alphaDen-$dataset.dat
            for mut in $MUT_LIST; do
#            rm -f $IR_NAME$ir-$a_NAME$alphaDen-${dataset}_$MUT_LIST.dat
            touch $IR_NAME$ir-$a_NAME$alphaDen-${dataset}_$MUT_LIST.dat
            echo -e "# ir\talpha\tctx\tbpb\ttime(s)" >> $IR_NAME$ir-$a_NAME$alphaDen-${dataset}_$MUT_LIST.dat
                for((ctx=2; ctx<$MAX_CTX; ++ctx)); do
                ./phoenix -m t,$ctx,$alphaDen,$ir -t datasets/${dataset}_$MUT_LIST >> $IR_NAME$ir-$a_NAME$alphaDen-${dataset}_$MUT_LIST.dat
                done
                # save "min bpb" and "min ctx" for each dataset
                minBpbCtx=$(awk 'NR==1 || $4 < minBpb {minBpb=$4; minCtx=$3}; \
                            END {print minBpb"\t"minCtx}' $IR_NAME$ir-$a_NAME$alphaDen-${dataset}_$MUT_LIST.dat)
                echo -e "  $mut\t$minBpbCtx" >> $IR_NAME$ir-$a_NAME$alphaDen-$dataset.dat
            done
        done
    done
done

fi  # end of running the program


#***********************************************************
#   plot results using "gnuplot"
#***********************************************************
if [[ $PLOT_RESULTS == 1 ]]; then

for ir in $INV_REPEATS; do
    for alphaDen in $ALPHA_DENS; do
        for dataset in $datasets; do

gnuplot <<- EOF
set xlabel "% mutation"                 # set label of x axis
set ylabel "bpb"                        # set label of y axis
#set xtics 0,5,100                       # set steps for x axis
set xtics add ("1" 1)
set key right                           # legend position
set term $PIX_FORMAT                    # set terminal for output picture format
set output "$dataset.$PIX_FORMAT"    # set output name
plot "$IR_NAME$ir-$a_NAME$ALPHA_DENS-$dataset.dat" using 1:2  with linespoints ls 7 title "ir=$ir, alpha=1/$ALPHA_DENS, $dataset"

set ylabel "context-order size"         # set label of y axis
set ytics 2,1,20                        # set steps for y axis
set output "$dataset-ctx.$PIX_FORMAT"    # set output name
plot "$IR_NAME$ir-$a_NAME$ALPHA_DENS-$dataset.dat" using 1:3  with linespoints ls 7 title "ir=$ir, alpha=1/$ALPHA_DENS, $dataset"

# the following line (EOF) MUST be left as it is; i.e. no space, etc
EOF

        done
    done
done

fi  #end of plot output using "gnuplot"


#-----------------------------------
#   create "dat" folder and save the results
#-----------------------------------
rm -fr dat              # remove "dat" folder, if it already exists
mkdir -p dat            # make "dat" folder
mv ${IR_NAME}*.dat dat    # move all created dat files to the "dat" folder
