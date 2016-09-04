#!/bin/bash
rm m5out/*
cp run-cmesh.sh m5out
./build/ALPHA_MESI_Two_Level/gem5.opt \
--outdir=m5out configs/example/run_spec2006.py \
--benchmarks=specrand_i,specrand_i,specrand_i,specrand_i,specrand_i,specrand_i,specrand_i,specrand_i,specrand_i,specrand_i,specrand_i,specrand_i,specrand_i,specrand_i,specrand_i,specrand_i,specrand_i,specrand_i,specrand_i,specrand_i,specrand_i,specrand_i,specrand_i,specrand_i,specrand_i,specrand_i,specrand_i,specrand_i,specrand_i,specrand_i,specrand_i,specrand_i \
--cpu-type=detailed --ruby --num-cpus=32 \
--caches --cacheline_size=128 \
--l1i_size=16kB --l1i_assoc=2 \
--l1d_size=16kB --l1d_assoc=2 \
--l2cache --l2_size=128kB --l2_assoc=4 --num-l2caches=16 \
--topology=CMesh --concentration-factor=2 --mesh-rows=4 \
--num-dirs=4 --mem-size=16GB \
--sys-clock=1GHz --ruby-clock=1GHz --cpu-clock=1GHz \
--output=m5out --errout=m5out \
--maxinsts=1000000 \
--garnet-network=fixed |tee m5out/runscript.log
