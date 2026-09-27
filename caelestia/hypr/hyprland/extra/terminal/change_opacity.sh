#!/bin/bash
path="$home/.config/kitty/kitty.conf"
toSet=0.78
shopt -s nocasematch
if [[ -n $1 ]];then
    if (( $(echo "$1 > 1" | bc -l) )); then
        toSet=1

    elif (( $(echo "$1 < 0" | bc -l) )); then
        toSet=0
    else
        toSet=$1
    fi

    if [[ 
fi


echo "$toSet"

shopt -u nocasematch

