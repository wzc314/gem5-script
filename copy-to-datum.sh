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
    if [[ $file_name =~ ^[0-9]+$ ]]; then
        if [ $file_name -gt $num ]; then
            num=$file_name
        fi
    fi
done

num=$[$num + 1]
DATA_DIR=$DATA_DIR/$num
mkdir $DATA_DIR
cp $GEM5 $DATA_DIR -r
cp $GEM5_ORIGIN $DATA_DIR/m5out-origin -r
tree $DATA_DIR
echo "Copying m5out to datum finish."
