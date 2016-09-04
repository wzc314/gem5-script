#!/bin/bash
{
    cd $HOME/gem5
    ./run-cmesh.sh
} &> /dev/pts/1 &

{
    cd $HOME/gem5-origin
    ./run-cmesh.sh
} &> /dev/pts/2 &

{
    echo "Monitoring gem5 status..."
    echo "I will notice you as long as workload gets completed."
    flag=1
    while [ $flag -eq 1 ]
    do
        sleep 1s
        pid=`pidof gem5.opt`
        if [ -z "$pid" ]; then
            echo "Running gem5 is completed."
            tput bel
            flag=0
        fi
    done

    stats1=$HOME/gem5/m5out/stats.txt
    stats2=$HOME/gem5-origin/m5out/stats.txt
    if [ -s $stats1 ] && [ -s $stats2 ]; then
        copy-to-datum.sh
        compare-stats.sh
    else
        echo "One(Both) stats.txt is empty, done."
    fi
} &
