#!/bin/bash

if [[ "$DEBUG" = "yes" ]]; then
    commands=("apt" "pct")

    echo "=== DEBUG ==="

    for i in "${commands[@]}"
    do 
        echo "Adding alias $i"
        alias $i="echo $i "
    done

    echo
fi