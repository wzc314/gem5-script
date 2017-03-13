#!/bin/bash
mode=opt
rate=0.1
sim_cycles=10000
synthetic=uniform_random
rows=4
while getopts m:r:c:s:w: opt
do
    case $opt in
        m) mode=$OPTARG;;
        r) rate=$OPTARG;;
        c) sim_cycles=$OPTARG;;
        s) synthetic=$OPTARG;;
        w) rows=$OPTARG;;
        *) echo "Unknown option: $opt";;
    esac
done

num=$[$rows*$rows]

if [ ! -d m5out-synth ];then
    mkdir m5out-synth
elif [ -n "$(ls -A m5out-synth)" ];then
    rm m5out-synth/*
fi
cp $0 m5out-synth

if [ $mode = debug ];then
    flag="--debug-flag=RubyNetwork"
fi

./build/NULL/gem5.$mode $flag \
--outdir=m5out-synth configs/example/garnet_synth_traffic.py \
--num-cpus=$num \
--num-dirs=$num \
--network=garnet2.0 \
--topology=Mesh_XY \
--mesh-rows=$rows \
--sim-cycles=$sim_cycles \
--synthetic=$synthetic \
--link-latency=2 \
--injectionrate=$rate
tput bel
