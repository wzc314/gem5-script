#!/bin/bash
vim -O $* +"windo 1" +"windo set nowrap" +"windo set scrollbind" +"wincmd h"
