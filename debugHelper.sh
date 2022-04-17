#!/bin/bash

if [ -z ${DEBUG+x} ]; then
    exit
fi

commands=("apt" "pct")

echo "=== DEBUG ==="

for i in "${commands[@]}"
do 
    echo "Adding alias $i"
    alias $i="echo $i "
done

echo