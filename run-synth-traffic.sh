#!/bin/bash
mode=opt
rate=0.1
synthetic=uniform_random
while getopts m:r:s: opt
do
    case $opt in
        m) mode=$OPTARG;;
        r) rate=$OPTARG;;
        s) synthetic=$OPTARG;;
        *) echo "Unknown option: $opt";;
    esac
done

if [ ! -d m5out-synth ];then
    mkdir m5out-synth
elif [ -n "$(ls -A m5out-synth)" ];then
    rm m5out-synth/*
fi
cp $0 m5out-synth

if [ $mode = debug ];then
    flag="--debug-flag=RubyNetwork"
fi

./build/Garnet_standalone/gem5.$mode $flag \
--outdir=m5out-synth configs/example/garnet_synth_traffic.py \
--num-cpus=64 \
--num-dirs=64 \
--network=garnet2.0 \
--topology=Mesh_XY \
--mesh-rows=8 \
--sim-cycles=10000 \
--synthetic=$synthetic \
--injectionrate=$rate
sed -n 13805p m5out-synth/stats.txt
tput bel
