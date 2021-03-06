#!/bin/bash
file=m5out-synth/stats.txt
function get-value {
    echo $(sed -n $1p $file)|cut -d ' ' -f 2
}

function grep-value {
    echo $(grep $1 $file) | tr -s ' ' | cut -d ' ' -f 2
}

function run-synth-traffic {
    local num=$[$4*$4]
    ./build/NULL/gem5.opt --outdir=m5out-synth configs/example/garnet_synth_traffic.py \
    --num-cpus=$num \
    --num-dirs=$num \
    --network=garnet2.0 \
    --topology=Mesh_XY \
    --mesh-rows=$4  \
    --sim-cycles=$1 \
    --vcs-per-vnet=4 \
    --inj-vnet=-1 \
    --link-latency=2 \
    --synthetic=$2 \
    --injectionrate=$3 &> /dev/null
    flit_samples=$(grep-value flit_latency_hist::samples)
    flit_latency=$(grep-value flit_latency_hist::mean)
    flit_stdev=$(grep-value flit_latency_hist::stdev)
    flit_max=$(grep-value max_flit_latency)
    packet_samples=$(grep-value packet_latency_hist::samples)
    packet_latency=$(grep-value packet_latency_hist::mean)
    packet_stdev=$(grep-value packet_latency_hist::stdev)
    packet_max=$(grep-value max_packet_latency)
    printf "%-8s %16s %16s %16s %16s %16s %16s %16s %16s\n" \
        $3 $flit_samples $flit_latency $flit_max $flit_stdev $packet_samples $packet_latency $packet_max $packet_stdev \
        | tee m5out-synth/latency.txt -a
}

step=0.01
rate=0
sim_cycles=10000
synthetic=uniform_random
rows=4
while getopts c:s:w: opt
do
    case $opt in
        c) sim_cycles=$OPTARG;;
        s) synthetic=$OPTARG;;
        w) rows=$OPTARG;;
        *) echo "Unknown option: $opt";;
    esac
done

if [ ! -d m5out-synth ];then
    mkdir m5out-synth
elif [ -n "$(ls -A m5out-synth)" ];then
    rm m5out-synth/*
fi
cp $0 m5out-synth

printf "\e[40;33;1m%-8s %16s %16s %16s %16s %16s %16s %16s %16s\e[m\n" \
    "inj_rate" "flit_samples" "flit_latency" "flit_max" "flit_stdev" "packet_samples" "packet_latency" "packet_max" "packet_stdev" \
    | tee m5out-synth/latency.txt
for (( i=1; i <= 70; i++ ))
do
    rate=`printf "%.2f" $(bc<<<$rate+$step)`
    run-synth-traffic $sim_cycles $synthetic $rate $rows
done
echo -e "\e[40;33;1mdone.\e[m"
tput bel
