#!/bin/bash
stats1=$HOME/gem5/m5out/stats.txt
stats2=$HOME/gem5-origin/m5out/stats.txt
vim -O $stats2 $stats1 +"windo 1" +"windo set nowrap" +"windo set scrollbind" +"wincmd h"
