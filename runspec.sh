#!/bin/bash
myopt_dir=$HOME/gem5
origin_dir=$HOME/gem5-origin
for benchmark in astar bwaves bzip2 gcc GemsFDTD gobmk h264ref leslie3d libquantum mcf milc namd omnetpp soplex sphinx3 wrf
do
    for working_dir in $myopt_dir #$origin_dir
    do
        cd $working_dir
        run-x86.sh -b $benchmark &
    done
done
