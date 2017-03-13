#!/bin/bash
exec 2>/dev/null
stats_dir=$HOME/gem5-results/research_point_2/$1
printf "\e[40;33;1m%-10s %10s           %10s           %10s           %10s\e[m\n" "benchmark" "latency" "ipc" "stdev" "max"
for benchmark_dir in $stats_dir/myopt/*
do
    benchmark_dir_name=$(basename $benchmark_dir)
    benchmark=${benchmark_dir_name:6}
    for class in myopt origin
    do
        file=$stats_dir/$class/m5out-$benchmark/stats.txt
        ipc=`sed -n 10p $file | tr -s ' ' | cut -d ' ' -f 2`
        flit_latency=`grep 'delayHist::mean' $file | tr -s ' ' | cut -d ' ' -f 2`
        stdev=`grep 'delayHist::stdev' $file | tr -s ' ' | cut -d ' ' -f 2`
        max=`grep 'max_flit_latency' $file | tr -s ' ' | cut -d ' ' -f 2`
        eval ${class}_latency=$flit_latency
        eval ${class}_ipc=$ipc
        eval ${class}_stdev=$stdev
        eval ${class}_max=$max
    done
    #echo -e "\e[40;34;1m$benchmark\e[m"
    awk 'BEGIN{printf "%-10s %10.4f %8.2f%% %10.4f %8.2f%% %10.4f %8.2f%% %10d %10.2f%%\n",
        "'$benchmark'",
        '$myopt_latency', '$myopt_latency'/'$origin_latency'*100,
        '$myopt_ipc', '$myopt_ipc'/'$origin_ipc'*100,
        '$myopt_stdev', '$myopt_stdev'/'$origin_stdev'*100,
        '$myopt_max', '$myopt_max'/'$origin_max'*100}'
done
