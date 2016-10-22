#!/bin/bash
rows=8
benchmark=bzip2
while getopts r:b: opt
do
    case $opt in
        r) rows=$OPTARG;;
        b) benchmark=$OPTARG;;
        *) echo "Unknown option: $opt";;
    esac
done
num=$[$rows*$rows]
benchmarks=$(awk 'BEGIN{OFS="'$benchmark',";NF='$num+1';print}' | sed 's/.$//')

if [ ! -d m5out ];then
    mkdir m5out
elif [ -n "$(ls -A m5out)" ];then
    rm m5out/*
fi
cp $0 m5out

./build/X86_MESI_Two_Level/gem5.opt \
--outdir=m5out configs/example/run_spec2006.py \
--benchmarks=$benchmarks \
--cpu-type=detailed --ruby --num-cpus=$num \
--caches --cacheline_size=128 \
--l1i_size=16kB --l1i_assoc=2 \
--l1d_size=16kB --l1d_assoc=2 \
--l2cache --l2_size=128kB --l2_assoc=4 --num-l2caches=$num \
--topology=MeshDirCorners_XY --mesh-rows=$rows \
--num-dirs=4 --mem-size=4GB \
--sys-clock=1GHz --ruby-clock=1GHz --cpu-clock=1GHz \
--output=m5out --errout=m5out \
--maxinsts=20000000 \
--network=garnet2.0 | tee m5out/runscript.log
sed -n 10p m5out/stats.txt
tput bel
