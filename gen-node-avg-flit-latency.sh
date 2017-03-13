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
    --mesh-rows=$4 \
    --sim-cycles=$1 \
    --vcs-per-vnet=4 \
    --inj-vnet=0 \
    --link-latency=2 \
    --synthetic=$2 \
    --injectionrate=$3 &> /dev/null
    latency=()
    local i=0
    for (( i=0; i <= $[$num-1]; i++ ))
    do
        latency[$i]=$(grep-value average_flit_node_injected_latency::$i)
        printf "%-12s" ${latency[$i]}
        if [[ $((($i+1)%$rows)) -eq 0 ]];then
            echo
        fi
    done
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

for (( i=1; i <= 70; i++ ))
do
    rate=`printf "%.2f" $(bc<<<$rate+$step)`
    echo $rate
    run-synth-traffic $sim_cycles $synthetic $rate $rows
done
echo -e "\e[40;33;1mdone.\e[m"
tput bel
