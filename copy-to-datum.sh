#!/bin/bash
# Copying m5out to datum.
GEM5=$HOME/gem5/m5out
GEM5_ORIGIN=$HOME/gem5-origin/m5out
DATA_DIR=$HOME/datum
num=0

if [ ! -d "$DATA_DIR" ]; then
    mkdir $DATA_DIR
    echo " Create folder $DATA_DIR."
fi

for file in $DATA_DIR/*
do
    file_name=`basename $file`
    if [[ $file_name =~ ^[0-9]+_[0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{2}:[0-9]{2}:[0-9]{2}$ ]]; then
        file_num=${file_name%%_*}
        if [ $file_num -gt $num ]; then
            num=$file_num
        fi
    fi
done

num=$[$num + 1]
DATA_DIR=$DATA_DIR/$num`date +"_%Y-%m-%d_%H:%M:%S"`
mkdir $DATA_DIR
cp $GEM5 $DATA_DIR -r
cp $GEM5_ORIGIN $DATA_DIR/m5out-origin -r
tree $DATA_DIR
echo "Copying m5out to datum finish."
