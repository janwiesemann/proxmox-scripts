#!/bin/bash

#this script is used to update every system. This includes the Hos and Containers

echo ==== Host ====
apt update -y
apt upgrade -y

echo Host Done!
echo

echo Searching Containers....
snapshotName="updateSnapshot_$(date +%Y_%m_%d_%k_%M)"
containers=$(pct list | tail -n +2 | cut -f1 -d' ')
echo

for container in $containers
do
  status=`pct status $container`
  if [ "$status" == "status: running" ]; then
    echo ==== $container ====

    echo refreshing package feed...
    pct exec $container -- bash -c "apt update -y 2>/dev/null" > /dev/null

    numOfUpdatesAvalible=$(pct exec $container -- bash -c "apt list --upgradable 2>/dev/null | wc -l")
    hasUpdateScript=$(pct exec $container -- bash -c "ls ~ | grep update.sh | wc -l")

    if [ $numOfUpdatesAvalible -gt 1 ] || [ $hasUpdateScript -gt 0 ]; then
        echo found updates! creating snapshot...
        pct snapshot $container $snapshotName > /dev/null

        if [ $numOfUpdatesAvalible -gt 1 ]; then
            echo installing $((numOfUpdatesAvalible - 1)) updates...
            pct exec $container -- apt upgrade -y
        fi

        if [ $hasUpdateScript -gt 0 ]; then
            echo executing update.sh script
            pct exec $container -- bash ~/update.sh
        fi
    fi

    echo $container Done!
    echo
  fi
done;