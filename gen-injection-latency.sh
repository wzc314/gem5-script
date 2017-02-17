#!/bin/bash
file=m5out-synth/stats.txt
function get-value {
    echo $(sed -n $1p $file)|cut -d " " -f 2
}

function run-synth-traffic {
    ./build/Garnet_standalone/gem5.opt --outdir=m5out-synth configs/example/garnet_synth_traffic.py \
    --num-cpus=64 \
    --num-dirs=64 \
    --network=garnet2.0 \
    --topology=Mesh_XY \
    --mesh-rows=8  \
    --sim-cycles=$1 \
    --vcs-per-vnet=4 \
    --synthetic=$2 \
    --injectionrate=$3 &> /dev/null
    latency=`get-value 13805`
    flits_latency=`grep 'flit_latency_hist::mean' $file | tr -s ' ' | cut -d ' ' -f 2`
    latency_stdev=`grep 'flit_latency_hist::stdev' $file | tr -s ' ' | cut -d ' ' -f 2`
    latency_max=`grep 'max_flit_latency' $file | tr -s ' ' | cut -d ' ' -f 2`
    in_arb_activity=`get-value 13824`
    out_arb_activity=`get-value 13825`
    pkt_received=`get-value 13796`
    pkt_injected=`get-value 13798`
    flits_received=`get-value 13807`
    flits_injected=`get-value 13809`
    printf "%-8s %16s %16s %16s %16s %16s %16s %16s %16s %16s %16s\n" \
        $3 $latency $flits_latency $in_arb_activity $out_arb_activity $pkt_received $pkt_injected $flits_received $flits_injected $latency_max $latency_stdev \
        | tee m5out-synth/latency.txt -a
}

step=0.01
rate=0.11
sim_cycles=10000
synthetic=uniform_random
while getopts c:s: opt
do
    case $opt in
        c) sim_cycles=$OPTARG;;
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

printf "\e[40;33;1m%-8s %16s %16s %16s %16s %16s %16s %16s %16s %16s %16s\e[m\n" \
    "inj_rate" "latency" "flits_latency" "in_arb_activity" "out_arb_activity" "pkt_received" "pkt_injected" "flits_received" "flits_injected" "latency_max" "latency_stdev" \
    | tee m5out-synth/latency.txt
for (( i=1; i <= 1; i++ ))
do
    rate=`printf "%.2f" $(bc<<<$rate+$step)`
    run-synth-traffic $sim_cycles $synthetic $rate
done
echo -e "\e[40;33;1mdone.\e[m"
tput bel
