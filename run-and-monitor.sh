#!/bin/bash
stats1=$HOME/gem5/m5out/stats.txt
stats2=$HOME/gem5-origin/m5out/stats.txt

function print-ipc {
    line1=`sed -n 10p $stats1`
    line2=`sed -n 10p $stats2`
    ipc1=`echo $line1|cut -d " " -f 2`
    ipc2=`echo $line2|cut -d " " -f 2`
    echo "gem5-origin IPC: $ipc2"
    echo "gem5 IPC: $ipc1"
    awk 'BEGIN{printf "IPC improved: %.2f%\n",(('$ipc1'-'$ipc2')/'$ipc2')*100}'
}

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

    if [ -s $stats1 ] && [ -s $stats2 ]; then
        copy-to-datum.sh
        print-ipc
    else
        echo "One(Both) stats.txt is empty, done."
    fi
} &
