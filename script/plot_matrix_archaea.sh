#!/usr/bin/env bash


## Archaea
#for ir in $INV_REPEATS; do
 for alphaDen in $ALPHA_DENS; do

gnuplot <<- EOF
set terminal $PIX_FORMAT enhanced color size 8.3,3.7
set output "$REF_SPECIES-$TAR_SPECIES.$PIX_FORMAT"
set multiplot layout 1,2 columnsfirst margins 0.02,0.918,0.1065,0.992 spacing 0.03,0 # GGA-MGA, MGA-GGA

#set offset 0,0,graph 0.1, graph 0.1
xticsOffset=-1.2
yticsOffset=-0.875 #-2.3
xlabelOffset=0.9   # GGA-MGA, MGA-GGA
ylabelOffset=0 #-2.3
#set size ratio .9 #0.85
set key off
##set tmargin 2.1    ### with title
#set tmargin 0.5     ### without title
#set bmargin 2.7 #4
##set bmargin 7
#set lmargin 5
#set rmargin 1.35
#set pm3d map
set macros
fontLabelSpecies='font "Latin Modern Math-Italic, 13"'
fontLabel='font "Latin Modern Math, 13"'
fontTics='font "Latin Modern Sans, 10"'

#set nocbtics
set cblabel "NRC" @fontLabel offset -1.5,0
set cbtics scale 0.5 @fontTics offset -0.8,0
#set cbtics
set cbrange [ 0 : 1 ] noreverse nowriteback

#set palette defined (0 "red", 1 "yellow", 2 "green", 3 "white")
set palette defined (0 "red", 0.5 "green", 1 "white")

##set yrange [2:10]

### reference-target, i0
#set output "$REF_SPECIES-$TAR_SPECIES.$PIX_FORMAT"
#set title "Inverted repeats considered"
#set title "Relative compression: HS-PT\nReference: HS, Target: PT, inverted repeats: not considered"
unset colorbox      # remove color palette
#set rmargin 47.5
set xtics( "Th. sp." 0, "Th. bar. s." 1, "Th. bar. s." 2, "S. is. M.16." 3, "M. brk. CM1" 4, "M. maz. C16" 5, \
           "S. is. HVE." 6, "M. sp. WWM." 7, "M. brk. MS" 8, "M. brk. s. W." 9, "M. sp. WH1" 10, "M. brk. 227" 11, \
           "M. maz. WWM." 12, "M. maz. S-6" 13, "M. maz. SarPi" 14, "M. maz. LYC" 15, "Th. litor." 16, \
           "S. is. LAL." 17, "P. fu. COM1" 18, "S. is. M.16." 19, "S. is. Y.G." 20, "S. is. L.S." 21, \
           "M. brk. s. F." 22, "S. is. REY." 23, "Th. bar. MP" 24, "S. is. L.D." 25, "S. is. Y.N." 26, \
           "S. is. M.14." 27, "M. marip. C6" 28, "M. marip. C7" 29, "M. marip. C5" 30, "M. maz. s. G." 31, \
           "P. fu. DSM" 32, "S. solf." 33, "H. sp." 34 \
         ) right @fontTics rotate by 90 offset 0,xticsOffset
set xlabel "$TAR_SPECIES_NAME" offset 0,xlabelOffset @fontLabelSpecies
set ylabel "$REF_SPECIES_NAME" offset ylabelOffset,0 @fontLabelSpecies
unset ytics

plot "<awk 'NR>1' '$FLD_dat/tot-${IR_LBL}0-$REF_SPECIES-$TAR_SPECIES.$INF_FILE_TYPE' | cut -f2-" matrix with image
### ! before any command inside gnuplot lets bash command work (e.g. the followings)
##!awk 'NR>1' $FLD_dat/tot-${IR_LBL}0-$HUMAN_CHR-$CHIMPANZEE_CHR.$INF_FILE_TYPE | cut -f2- > temp
##plot "temp" matrix with image
##!rm temp

### reference-target, i1
#set output "${IR_LBL}1-$REF_SPECIES-$TAR_SPECIES.$PIX_FORMAT"
#set title "Inverted repeats not considered"
#set title "Relative compression: HS-PT\nReference: HS, Target: PT, inverted repeats: considered"
set colorbox        # draw color palette
set lmargin 57

set ytics( "Th. sp." 0, "Th. bar. s." 1, "Th. bar. s." 2, "S. is. M.16." 3, "M. brk. CM1" 4, "M. maz. C16" 5, \
           "S. is. HVE." 6, "M. sp. WWM." 7, "M. brk. MS" 8, "M. brk. s. W." 9, "M. sp. WH1" 10, "M. brk. 227" 11, \
           "M. maz. WWM." 12, "M. maz. S-6" 13, "M. maz. SarPi" 14, "M. maz. LYC" 15, "Th. litor." 16, \
           "S. is. LAL." 17, "P. fu. COM1" 18, "S. is. M.16." 19, "S. is. Y.G." 20, "S. is. L.S." 21, \
           "M. brk. s. F." 22, "S. is. REY." 23, "Th. bar. MP" 24, "S. is. L.D." 25, "S. is. Y.N." 26, \
           "S. is. M.14." 27, "M. marip. C6" 28, "M. marip. C7" 29, "M. marip. C5" 30, "M. maz. s. G." 31, \
           "P. fu. DSM" 32, "S. solf." 33, "H. sp." 34 \
         ) @fontTics offset yticsOffset,0

unset ylabel

plot "<awk 'NR>1' '$FLD_dat/tot-${IR_LBL}1-$REF_SPECIES-$TAR_SPECIES.$INF_FILE_TYPE' | cut -f2-" matrix with image

unset multiplot; set output

EOF

 done
#done



### difference
#for ir in $INV_REPEATS; do
 for alphaDen in $ALPHA_DENS; do

gnuplot <<- EOF
set terminal $PIX_FORMAT enhanced color size 5,4.3
set output "diff-$REF_SPECIES-$TAR_SPECIES.$PIX_FORMAT"
#set multiplot layout 1,1 columnsfirst #margins 0.0255,0.9147,0.105,0.992 spacing 0.03,0
#set offset 0,0,graph 0.1, graph 0.1

xticsOffset=0.2
yticsOffset=0.2
xlabelOffset=2.7
ylabelOffset=4.4
#set size ratio .9 #0.85
set key off

##set tmargin 2.1    ### with title
set tmargin 0.18     ### without title
set bmargin 6.6
set lmargin 12
set rmargin 0.6
#set pm3d map
set macros
fontLabelSpecies='font "Latin Modern Math-Italic, 13"'
fontLabel='font "Latin Modern Math, 13"'
fontTics='font "Latin Modern Sans, 10"'

#set nocbtics
set cblabel "NRC_{IR=0} - NRC_{IR=1}" @fontLabel offset -1,0     #-0.25 or -1.5
set cbtics scale 0.5 @fontTics offset -0.65,0
#set cbtics
#unset colorbox
set cbrange [ -0.1 : 1 ] noreverse nowriteback

set palette defined (-0.1 "white", 0.45 "green", 1 "red")

#set title "The difference"
#set title "Relative compression: HS-PT\nDifference between considering and not considering inverted repeats\nReference: HS, Target: PT"

set xtics( "Th. sp." 0, "Th. bar. s." 1, "Th. bar. s." 2, "S. is. M.16." 3, "M. brk. CM1" 4, "M. maz. C16" 5, \
           "S. is. HVE." 6, "M. sp. WWM." 7, "M. brk. MS" 8, "M. brk. s. W." 9, "M. sp. WH1" 10, "M. brk. 227" 11, \
           "M. maz. WWM." 12, "M. maz. S-6" 13, "M. maz. SarPi" 14, "M. maz. LYC" 15, "Th. litor." 16, \
           "S. is. LAL." 17, "P. fu. COM1" 18, "S. is. M.16." 19, "S. is. Y.G." 20, "S. is. L.S." 21, \
           "M. brk. s. F." 22, "S. is. REY." 23, "Th. bar. MP" 24, "S. is. L.D." 25, "S. is. Y.N." 26, \
           "S. is. M.14." 27, "M. marip. C6" 28, "M. marip. C7" 29, "M. marip. C5" 30, "M. maz. s. G." 31, \
           "P. fu. DSM" 32, "S. solf." 33, "H. sp." 34 \
         ) right @fontTics rotate by 90 offset 0,xticsOffset
set ytics( "Th. sp." 0, "Th. bar. s." 1, "Th. bar. s." 2, "S. is. M.16." 3, "M. brk. CM1" 4, "M. maz. C16" 5, \
           "S. is. HVE." 6, "M. sp. WWM." 7, "M. brk. MS" 8, "M. brk. s. W." 9, "M. sp. WH1" 10, "M. brk. 227" 11, \
           "M. maz. WWM." 12, "M. maz. S-6" 13, "M. maz. SarPi" 14, "M. maz. LYC" 15, "Th. litor." 16, \
           "S. is. LAL." 17, "P. fu. COM1" 18, "S. is. M.16." 19, "S. is. Y.G." 20, "S. is. L.S." 21, \
           "M. brk. s. F." 22, "S. is. REY." 23, "Th. bar. MP" 24, "S. is. L.D." 25, "S. is. Y.N." 26, \
           "S. is. M.14." 27, "M. marip. C6" 28, "M. marip. C7" 29, "M. marip. C5" 30, "M. maz. s. G." 31, \
           "P. fu. DSM" 32, "S. solf." 33, "H. sp." 34 \
         ) @fontTics offset yticsOffset,0
set xlabel "$TAR_SPECIES_NAME" offset 0,xlabelOffset @fontLabelSpecies
set ylabel "$REF_SPECIES_NAME" offset ylabelOffset,0 @fontLabelSpecies

plot "<awk 'NR>1' '$FLD_dat/diff-$REF_SPECIES-$TAR_SPECIES.$INF_FILE_TYPE' | cut -f2-" matrix with image

unset multiplot; set output

EOF

 done
#done