#!/bin/bash
exec 2>/dev/null
stats_dir=$HOME/gem5-results/$1
printf "\e[40;33;1m%-12s %12s %12s %12s %12s %12s %12s %12s %12s\e[m\n" "" "Round-Robin" "TS-Router" "FOSA" "Round-Robin" "TS-Router" "FOSA" "TS-Router" "Round-Robin"
for benchmark_dir in $stats_dir/myopt/*
do
    benchmark_dir_name=$(basename $benchmark_dir)
    benchmark=${benchmark_dir_name:6}
    for class in myopt origin tsrouter
    do
        file=$stats_dir/$class/m5out-$benchmark/stats.txt
        ipc=`sed -n 10p $file | tr -s ' ' | cut -d ' ' -f 2`
        flit_latency=`grep 'flit_latency_hist::mean' $file | tr -s ' ' | cut -d ' ' -f 2`
        stdev=`grep 'flit_latency_hist::stdev' $file | tr -s ' ' | cut -d ' ' -f 2`
        max=`grep 'max_flit_latency' $file | tr -s ' ' | cut -d ' ' -f 2`
        eval ${class}_latency=$flit_latency
        eval ${class}_ipc=$ipc
        eval ${class}_stdev=$stdev
        eval ${class}_max=$max
    done
    printf "\e[40;34;1m%-12s\e[m %12.4f %12.4f %12.4f %12d %12d %12d %12.3f %12.3f\n" $benchmark $origin_stdev $tsrouter_stdev $myopt_stdev $origin_max $tsrouter_max $myopt_max $(bc<<<"scale=3;$myopt_ipc/$tsrouter_ipc") $(bc<<<"scale=3;$myopt_ipc/$origin_ipc")
done
