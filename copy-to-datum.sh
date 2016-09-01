#!/bin/bash
# Copying m5out to datum.
GEM5=$HOME/gem5/m5out
GEM5_ORIGIN=$HOME/gem5-origin/m5out
DIR_FORMAT="^[0-9]+_[0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{2}:[0-9]{2}:[0-9]{2}$" 
data_dir=$HOME/datum
num=0

function backup {
    if [ ! -d "$data_dir" ]; then
        mkdir $data_dir
        echo "Create folder $data_dir."
    fi

    for file in $data_dir/*
    do
        file_name=`basename $file`
        if [[ $file_name =~ $DIR_FORMAT ]]; then
            file_num=${file_name%%_*}
            if [ $file_num -gt $num ]; then
                num=$file_num
            fi
        fi
    done

    num=$[$num + 1]
    data_dir=$data_dir/$num`date +"_%Y-%m-%d_%H:%M:%S"`
    mkdir $data_dir
    cp $GEM5 $data_dir -r
    cp $GEM5_ORIGIN $data_dir/m5out-origin -r
    tree $data_dir
    echo "Copying m5out to datum finish."
}

function remove {
    if [ ! -d "$data_dir" ]; then
        echo "$data_dir is not existed, done."
    else
        for file in $data_dir/*
        do
            file_name=`basename $file`
            if [[ $file_name =~ $DIR_FORMAT ]]; then
                file_num=${file_name%%_*}
                if [ $file_num -gt $num ]; then
                    num=$file_num
                    file_remove=$file
                fi
            fi
        done
        if [ $num -eq 0 ]; then
            echo "No directory removed, done."
        else
            read -p "Remove directory $file_remove, continue [Y/N]? " answer
            case $answer in
                "" | Y | y) 
                    rm $file_remove -rf
                    echo "$file_remove removed, done.";;
                N | n)
                    echo "Remove operation cancelled, done.";;
            esac
        fi
    fi
}

if [ $# -gt 1 ]; then
    echo "Usage: copy-to-datum [-r]"
elif [ $# -eq 0 ]; then
    backup
else
    case "$1" in
        -r) remove;;
        *) echo "Argument \"$1\" is invalid.";;
    esac
fi
