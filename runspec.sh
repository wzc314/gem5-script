#!/bin/bash
myopt_dir=$HOME/gem5-garnet2.0
origin_dir=$HOME/gem5-garnet2.0-origin
tsrouter_dir=$HOME/gem5-garnet2.0-tsrouter2.0
#for benchmark in h264ref gcc soplex libquantum cactusADM sjeng GemsFDTD sphinx3 bzip2 namd
for benchmark in wrf mcf gobmk omnetpp leslie3d astar gromacs bwaves milc
do
    for working_dir in $myopt_dir $origin_dir $tsrouter_dir
    do
        cd $working_dir
        ./run-x86.sh -b $benchmark &
    done
done
