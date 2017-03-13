#!/bin/bash
rows=4
benchmark=bzip2
maxinsts=20000000
while getopts r:b:o:m: opt
do
    case $opt in
        r) rows=$OPTARG;;
        b) benchmark=$OPTARG;;
        o) outdir=$OPTARG;;
        m) maxinsts=$OPTARG;;
        *) echo "Unknown option: $opt";;
    esac
done

if [ -z $outdir ];then #if the length of $outdir is zero
    outdir=m5out-$benchmark
fi
num=$[$rows*$rows]
benchmarks=$(awk 'BEGIN{OFS="'$benchmark',";NF='$num+1';print}' | sed 's/.$//')

if [ ! -d $outdir ];then
    mkdir $outdir
elif [ -n "$(ls -A $outdir)" ];then
    rm $outdir/*
fi
cp $0 $outdir

./build/X86_MESI_Two_Level/gem5.opt \
--outdir=$outdir configs/example/run_spec2006.py \
--benchmarks=$benchmarks \
--cpu-type=detailed --ruby --num-cpus=$num \
--caches --cacheline_size=128 \
--l1i_size=16kB --l1i_assoc=2 \
--l1d_size=16kB --l1d_assoc=2 \
--l2cache --l2_size=128kB --l2_assoc=4 --num-l2caches=$num \
--topology=MeshDirCorners_XY --mesh-rows=$rows \
--vcs-per-vnet=4 \
--num-dirs=4 --mem-size=8GB \
--sys-clock=1GHz --ruby-clock=2GHz --cpu-clock=2GHz \
--output=$outdir --errout=$outdir \
--maxinsts=$maxinsts \
--network=garnet2.0 &> $outdir/runscript.log

IPC=$(sed -n 10p $outdir/stats.txt | tr -s ' ' | cut -d ' ' -f 2)
printf "%-15s %12s %10.4f\n" $(basename $(pwd)) $benchmark $IPC
tput bel
