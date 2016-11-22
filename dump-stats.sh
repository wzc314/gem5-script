#!/bin/bash
exec 2>/dev/null
stats_dir=$HOME/gem5-results/$1
printf "\e[40;33;1m%-8s %10s           %10s           %10s           %10s\e[m\n" "class" "latency" "ipc" "stdev" "max"
for benchmark_dir in $stats_dir/myopt/*
do
    benchmark_dir_name=$(basename $benchmark_dir)
    benchmark=${benchmark_dir_name:6}
    for class in myopt origin tsrouter
    do
        file=$stats_dir/$class/m5out-$benchmark/stats.txt
        ipc=`sed -n 10p $file | tr -s ' ' | cut -d ' ' -f 2`
        flit_latency=`grep 'delayHist::mean' $file | tr -s ' ' | cut -d ' ' -f 2`
        stdev=`grep 'delayHist::stdev' $file | tr -s ' ' | cut -d ' ' -f 2`
        max=`grep 'max_flit_latency' $file | tr -s ' ' | cut -d ' ' -f 2`
        case $class in
            myopt) 
                myopt_latency=$flit_latency
                myopt_ipc=$ipc
                myopt_stdev=$stdev
                myopt_max=$max;;
            origin)
                origin_latency=$flit_latency
                origin_ipc=$ipc
                origin_stdev=$stdev
                origin_max=$max;;
            tsrouter)
                tsrouter_latency=$flit_latency
                tsrouter_ipc=$ipc
                tsrouter_stdev=$stdev
                tsrouter_max=$max;;
            *)
                echo "Unknown class: $class";;
        esac
    done
    echo -e "\e[40;34;1m$benchmark\e[m"
    awk 'BEGIN{printf "%-8s %10.4f           %10.4f           %10.4f           %10d\n", "myopt", '$myopt_latency', '$myopt_ipc', '$myopt_stdev', '$myopt_max'}' 
    awk 'BEGIN{printf "%-8s %10.4f %8.2f%% %10.4f %8.2f%% %10.4f %8.2f%% %10d %10.2f%%\n", \
        "origin", \
        '$origin_latency', (('$origin_latency'-'$myopt_latency')/'$origin_latency')*100, \
        '$origin_ipc', (('$myopt_ipc'-'$origin_ipc')/'$origin_ipc')*100, \
        '$origin_stdev', (('$origin_stdev'-'$myopt_stdev')/'$origin_stdev')*100, \
        '$origin_max', (('$origin_max'-'$myopt_max')/'$origin_max')*100}'
    awk 'BEGIN{printf "%-8s %10.4f %8.2f%% %10.4f %8.2f%% %10.4f %8.2f%% %10d %10.2f%%\n", \
        "tsrouter", \
        '$tsrouter_latency', (('$tsrouter_latency'-'$myopt_latency')/'$tsrouter_latency')*100, \
        '$tsrouter_ipc', (('$myopt_ipc'-'$tsrouter_ipc')/'$tsrouter_ipc')*100, \
        '$tsrouter_stdev', (('$tsrouter_stdev'-'$myopt_stdev')/'$tsrouter_stdev')*100, \
        '$tsrouter_max', (('$tsrouter_max'-'$myopt_max')/'$tsrouter_max')*100}'
done
