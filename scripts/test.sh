#!/bin/bash

#***********************************************************
#   change directory to home
#***********************************************************
cd ..


#***********************************************************
#   parameters to install and run needed programs
#***********************************************************
ARCH_DAT="archive_dat"


DL_CHROMOSOMES=0        # download choromosomes
INSTALL_XS=0            # install "XS" from Github
INSTALL_goose=0         # install "goose" from Github
GEN_DATASETS=0          # generate datasets using "XS"
GEN_MUTATIONS=0         # generate mutations using "goose"
RUN=0                   # run the program
PLOT_RESULTS=1          # plot results using "gnuplot"
ARCHIVE_DATA=0          # archive data

# mutations list:   `seq -s' ' 1 10`
#MUT_LIST="1 2 3 4 5 6 7 8 9 10 12 14 16 18 20 25 30 35 40 45 50"
MUT_LIST="1"

HUMAN_CHR_PREFIX="hs_ref_GRCh38.p7_"
CHR="chr"
HUMAN_CHR="HS"
CURR_CHR="21"
chromosomes="$HUMAN_CHR_PREFIX$CHR$CURR_CHR"
chromosomes=""
#for i in {1..22} X Y
#do  chromosomes+=$HUMAN_CHR_PREFIX$CHR${i}" ";   done
datasets="$HUMAN_CHR$CURR_CHR"
#datasets="tmp"
#datasets=""
##for i in {4..22} X Y #alts unlocalized unplaced
#for i in {1..22} X Y
#do  datasets+=$HUMAN_CHR${i}" ";    done


INV_REPEATS="0"   # list of inverted repeats      "0 1"
ALPHA_DENS="1"    # list of alpha denominators    "1 20 100"
MIN_CTX=2         # min context size
MAX_CTX=3         # max context size   ->  real: -=1

PIX_FORMAT=svg    # output format: png, svg, eps, epslatex (set output x.y)
#rm -f *.$PIX_FORMAT# remove FORMAT pictures, if they exist

IR_NAME=i         # inverted repeat name
a_NAME=a          # alpha denominator name


#***********************************************************
#   download choromosomes
#***********************************************************
if [[ $DL_CHROMOSOMES == 1 ]]; then

for((x=1;x!=23;++x));
do wget ftp://ftp.ncbi.nlm.nih.gov/genomes/H_sapiens/Assembled_chromosomes/seq/hs_ref_GRCh38.p7_chr$x.fa.gz ; done
wget ftp://ftp.ncbi.nlm.nih.gov/genomes/H_sapiens/Assembled_chromosomes/seq/hs_ref_GRCh38.p7_chrX.fa.gz
wget ftp://ftp.ncbi.nlm.nih.gov/genomes/H_sapiens/Assembled_chromosomes/seq/hs_ref_GRCh38.p7_chrY.fa.gz
for((x=1;x!=23;++x));
do gunzip < hs_ref_GRCh38.p7_chr$x.fa.gz > chromosomes/hs_ref_GRCh38.p7_chr$x.fa; done
gunzip < hs_ref_GRCh38.p7_chrX.fa.gz > chromosomes/hs_ref_GRCh38.p7_chrX.fa;
gunzip < hs_ref_GRCh38.p7_chrY.fa.gz > chromosomes/hs_ref_GRCh38.p7_chrY.fa;
rm *.fa.gz


##zcat hs_ref_GRCh38_chrX.fa.gz | grep -v ">" | tr -d -c "ACGTN" > HSC23 ;
##zcat hs_ref_GRCh38_chrY.fa.gz | grep -v ">" | tr -d -c "ACGTN" > HSC24 ;
#cat HSC* > HS.acgt;
#rm -f *.fa.gz ;
##rm -f GRC*

fi  # end of download choromosomes


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

rm -fr goose
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

#NUM_MUTATIONS=1     # number of mutations to be generated:     real: -=1

for c in $chromosomes; do
    for x in $MUT_LIST; do      #((x=1; x<$NUM_MUTATIONS; x+=1));
    MRATE=`echo "scale=3;$x/100" | bc -l`;      # handle transition 0.09 -> 0.10
    goose/src/goose-mutatefasta -s $x -a5 -mr $MRATE " " < chromosomes/${c}.fa > temp;
    cat temp | grep -v ">" > $HUMAN_CHR${CURR_CHR}_$x      # remove the header line
    done
done
rm -f temp*    # remove temporary files

#-----------------------------------
#   move all generated mutations files to "datasets" folder
#-----------------------------------
##rm -fr datasets
#mkdir -p datasets
mv ${HUMAN_CHR}* datasets

fi  # end of generating mutations using "goose"


#***********************************************************
#   running the program
#***********************************************************
cmake source
make

if [[ $RUN == 1 ]]; then

for ir in $INV_REPEATS; do
    for alphaDen in $ALPHA_DENS; do
        for dataset in $datasets; do
##        rm -f $IR_NAME$ir-$a_NAME$alphaDen-${dataset}.dat
#        touch $IR_NAME$ir-$a_NAME$alphaDen-$dataset.dat
#        echo -e "# mut\tmin_bpb\tmin_ctx" >> $IR_NAME$ir-$a_NAME$alphaDen-$dataset.dat
            for mut in $MUT_LIST; do
#            rm -f $IR_NAME$ir-$a_NAME$alphaDen-${dataset}_$mut.dat
            touch $IR_NAME$ir-$a_NAME$alphaDen-${dataset}_$mut.dat
            echo -e "# ir\talpha\tctx\tbpb\ttime(s)" >> $IR_NAME$ir-$a_NAME$alphaDen-${dataset}_$mut.dat
                for((ctx=$MIN_CTX; ctx<$MAX_CTX; ctx+=1)); do
#                for ctx in {2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20}; do
                ./phoenix -m t,$ctx,$alphaDen,$ir -t archive_datasets/${dataset}_$mut -r archive_datasets/${dataset}_$mut \
                        #>> $IR_NAME$ir-$a_NAME$alphaDen-${dataset}_$mut.dat
                done
##                # save "min bpb" and "min ctx" for each dataset
#                minBpbCtx=$(awk 'NR==1 || $4 < minBpb {minBpb=$4; minCtx=$3}; \
#                            END {print minBpb"\t"minCtx}' $IR_NAME$ir-$a_NAME$alphaDen-${dataset}_$mut.dat)
#                echo -e "  $mut\t$minBpbCtx" >> $IR_NAME$ir-$a_NAME$alphaDen-$dataset.dat
            done
        done
    done
done

#-----------------------------------
#   create "dat" folder and save the results
#-----------------------------------
###rm -fr dat              # remove "dat" folder, if it already exists
##mkdir -p dat            # make "dat" folder
#mv ${IR_NAME}*.dat dat  # move all created dat files to the "dat" folder

fi  # end of running the program


#***********************************************************
#   plot results using "gnuplot"
#***********************************************************
if [[ $PLOT_RESULTS == 1 ]]; then

#for ir in $INV_REPEATS; do
for ir in 0 1; do
    for alphaDen in $ALPHA_DENS; do
    #    for dataset in $datasets; do
    #        for mut in $MUT_LIST; do

gnuplot <<- EOF
set term $PIX_FORMAT                    # set terminal for output picture format

##########################    bpb    ##########################
#set xlabel "% mutation"                 # set label of x axis
#set ylabel "bpb"                        # set label of y axis
##set xtics 0,5,100                      # set steps for x axis
#set xtics add ("1" 1)
#set key bottom right                    # legend position
##set output "$IR_NAME$ir-$a_NAME$alphaDen-$dataset-bpb.$PIX_FORMAT"       # set output name
##plot "dat/$IR_NAME$ir-$a_NAME$alphaDen-${dataset}.dat" using 1:2  with linespoints ls 7 title "$IR_NAME=$ir, $a_NAME=1/$alphaDen, $CHR$CURR_CHR"
##set output "$a_NAME$alphaDen-$dataset-bpb.$PIX_FORMAT"       # set output name
##plot "dat/${IR_NAME}0-$a_NAME$alphaDen-${dataset}.dat" using 1:2  with linespoints ls 6 title "$IR_NAME=0, $a_NAME=1/$alphaDen, $CHR$CURR_CHR", \
##     "dat/${IR_NAME}1-$a_NAME$alphaDen-${dataset}.dat" using 1:2  with linespoints ls 7 title "$IR_NAME=1, $a_NAME=1/$alphaDen, $CHR$CURR_CHR"
#set output "$IR_NAME$ir-$a_NAME$alphaDen-bpb.$PIX_FORMAT"       # set output name
#set title "IR=$ir,   Alpha=$alphaDen"
##plot for [i=1:22] "$ARCH_DAT/$IR_NAME$ir-$a_NAME$alphaDen-HS".i.".dat" using 1:2  with linespoints ls "".i."" title "${CHR} ".i."", \
##     "$ARCH_DAT/$IR_NAME$ir-$a_NAME$alphaDen-HSX.dat" using 1:2  with linespoints ls 23 title "${CHR} X", \
##     "$ARCH_DAT/$IR_NAME$ir-$a_NAME$alphaDen-HSY.dat" using 1:2  with linespoints ls 24 title "${CHR} Y", \
#
#plot \
#     for [i=1:8]    "$ARCH_DAT/$IR_NAME$ir-$a_NAME$alphaDen-HS".i.".dat" using 1:2  with linespoints ls "".i."" title "${CHR} ".i."", \
#     for [i=10:12]  "$ARCH_DAT/$IR_NAME$ir-$a_NAME$alphaDen-HS".i.".dat" using 1:2  with linespoints ls "".i."" title "${CHR} ".i."", \
#     for [i=18:18]  "$ARCH_DAT/$IR_NAME$ir-$a_NAME$alphaDen-HS".i.".dat" using 1:2  with linespoints ls "".i."" title "${CHR} ".i."", \
#                    "$ARCH_DAT/$IR_NAME$ir-$a_NAME$alphaDen-HSX.dat" using 1:2  with linespoints ls 23 title "${CHR} X", \
#     for [i=9:9]    "$ARCH_DAT/$IR_NAME$ir-$a_NAME$alphaDen-HS".i.".dat" using 1:2  with linespoints ls "".i."" title "${CHR} ".i."", \
#     for [i=16:16]  "$ARCH_DAT/$IR_NAME$ir-$a_NAME$alphaDen-HS".i.".dat" using 1:2  with linespoints ls "".i."" title "${CHR} ".i."", \
#     for [i=19:19]  "$ARCH_DAT/$IR_NAME$ir-$a_NAME$alphaDen-HS".i.".dat" using 1:2  with linespoints ls "".i."" title "${CHR} ".i."", \
##     for [i=17:17]  "$ARCH_DAT/$IR_NAME$ir-$a_NAME$alphaDen-HS".i.".dat" using 1:2  with linespoints ls "".i."" title "${CHR} ".i."", \
##     for [i=21:21]  "$ARCH_DAT/$IR_NAME$ir-$a_NAME$alphaDen-HS".i.".dat" using 1:2  with linespoints ls "".i."" title "${CHR} ".i."", \
##     for [i=22:22]  "$ARCH_DAT/$IR_NAME$ir-$a_NAME$alphaDen-HS".i.".dat" using 1:2  with linespoints ls "".i."" title "${CHR} ".i."", \
##     "$ARCH_DAT/$IR_NAME$ir-$a_NAME$alphaDen-HSY.dat" using 1:2  with linespoints ls 24 title "${CHR} Y", \
##     for [i=13:15]  "$ARCH_DAT/$IR_NAME$ir-$a_NAME$alphaDen-HS".i.".dat" using 1:2  with linespoints ls "".i."" title "${CHR} ".i."", \


##########################    ctx    ##########################
##set xlabel "ctx"
#set ylabel "context-order size"         # set label of y axis
#set ytics 2,1,20                        # set steps for y axis
#set key top right                       # legend position
##set output "$IR_NAME$ir-$a_NAME$alphaDen-$dataset-ctx.$PIX_FORMAT"    # set output name
##plot "dat/$IR_NAME$ir-$a_NAME$alphaDen-${dataset}.dat" using 1:3  with linespoints ls 7 title "$IR_NAME=$ir, $a_NAME=1/$alphaDen, $CHR$CURR_CHR"
#set output "$IR_NAME$ir-$a_NAME$alphaDen-ctx.$PIX_FORMAT"       # set output name
#plot \
#     for [i=1:2]  "$ARCH_DAT/$IR_NAME$ir-$a_NAME$alphaDen-HS".i.".dat" using 1:3  with linespoints ls "".i."" title "${CHR} ".i."", \


#set terminal pngcairo size 600, 850
set terminal $PIX_FORMAT size 600, 850
set output "$IR_NAME$ir-$a_NAME$alphaDen-ctx.$PIX_FORMAT"       # set output name
#set multiplot
set multiplot layout 12,2 columnsfirst margins 0.08,0.98,0.06,0.98 spacing 0.013,0.0
set offset 0,0,graph 0.1, graph 0.1
set key top right samplen 2 spacing 1.5 font ",11"

LS=1    # line style

set grid
set label 1 '%mutation' at screen 0.47,0.015
set label 2 'context-order size' at screen 0.02,0.47 rotate by 90
set xtics 5,5,50 scale 0.35      # set steps for x axis
set ytics 2,2,10 scale 0.5 offset 0.4,0 font ",10"      # set steps for y axis
set yrange [ 2 : 10 ]

###   first column   ###
do for [i=1:11] {
set xtics format ''
plot "$ARCH_DAT/$IR_NAME$ir-$a_NAME$alphaDen-HS".i.".dat" using 1:3 with lines linetype 7 linewidth 2.0 title "".i.""
}
###   chromosome 12   ###
set xtics add ("1" 1, "5" 5, "10" 10, "15" 15, "20" 20, "25" 25, "30" 30, "35" 35, "40" 40, "45" 45, "50  " 50) \
    scale 0.35 offset 0.25,0.4 font ",10"
plot "$ARCH_DAT/$IR_NAME$ir-$a_NAME$alphaDen-HS12.dat" using 1:3 with lines linetype 7 linewidth 2.0 title "12"

###   second column   ###
do for [i=13:22] {
set xtics 5,5,50 scale 0.35      # set steps for x axis
set xtics format ''
set ytics format ''      # set steps for y axis
plot "$ARCH_DAT/$IR_NAME$ir-$a_NAME$alphaDen-HS".i.".dat" using 1:3 with lines linetype 7 linewidth 2.0 title "".i.""
}
###   chromosome X   ###
plot "$ARCH_DAT/$IR_NAME$ir-$a_NAME$alphaDen-HSX.dat" using 1:3 with lines linetype 7 linewidth 2.0 title "X"
###   chromosome Y   ###
set xtics add ("  1" 1, "5" 5, "10" 10, "15" 15, "20" 20, "25" 25, "30" 30, "35" 35, "40" 40, "45" 45, "50" 50) \
    scale 0.35 offset 0.25,0.4 font ",10"
plot "$ARCH_DAT/$IR_NAME$ir-$a_NAME$alphaDen-HSY.dat" using 1:3 with lines linetype 7 linewidth 2.0 title "Y"

unset multiplot; set output

# the following line (EOF) MUST be left as it is; i.e. no space, etc
EOF

    #        done
    #    done
    done
done

fi  #end of plot output using "gnuplot"


#***********************************************************
#   archive data
#***********************************************************
if [[ $ARCHIVE_DATA == 1 ]]; then

mkdir -p archive
mv dat/*.dat archive/

fi


########################
cd ./scripts
