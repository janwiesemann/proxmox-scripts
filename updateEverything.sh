#!/bin/bash

ADDITIONAL_SCRIPTS_DIRECTORY="./updateEverything.d/"

source ./debugHelper.sh

#this script is used to update every system. This includes the Hos and Containers

executeHost=false
executeLXC=false
executeCustom=false

for var in "$@"
do
    if [[ "$var" =~ "all" ]]; then
        executeHost=true
        executeLXC=true
        executeCustom=true
    elif [[ "$var" =~ "host" ]]; then
        executeHost=true
    elif [[ "$var" =~ "lxc" ]]; then
        executeLXC=true
    elif [[ "$var" =~ "custom" ]]; then
        executeCustom=true
    fi
done

if [[ $executeHost = false && $executeHost = false && $executeCustom = false ]]; then
    executeHost=true
    executeLXC=true
    executeCustom=true
fi

if [[ $executeHost = true ]]; then
    echo "==== Host ===="
    apt update -y
    apt upgrade -y

    echo "Host Done!"
    echo
fi

if [[ $executeHost = true ]]; then
echo "Searching Containers...."
    snapshotName="updateSnapshot_$(date +%Y_%m_%d_%k_%M)"
    containers=$(pct list | tail -n +2 | cut -f1 -d' ')
    echo

    for container in $containers
    do
        status=`pct status $container`
        if [ "$status" == "status: running" ]; then
            echo "==== $container ===="

            echo "refreshing package feed..."
            pct exec $container -- bash -c "apt update -y 2>/dev/null" > /dev/null

            numOfUpdatesAvalible=$(pct exec $container -- bash -c "apt list --upgradable 2>/dev/null | wc -l")
            hasUpdateScript=$(pct exec $container -- bash -c "ls ~ | grep update.sh | wc -l")

            if [ $numOfUpdatesAvalible -gt 1 ] || [ $hasUpdateScript -gt 0 ]; then
                    echo "found updates! creating snapshot..."
                    pct snapshot $container $snapshotName > /dev/null

                    if [ $numOfUpdatesAvalible -gt 1 ]; then
                            echo "installing $((numOfUpdatesAvalible - 1)) updates..."
                            pct exec $container -- apt upgrade -y
                    fi

                    if [ $hasUpdateScript -gt 0 ]; then
                            "echo executing update.sh script"
                            pct exec $container -- bash ~/update.sh
                    fi
            fi

            echo "$container Done!"
            echo
        fi
    done;
fi

if [[ $executeCustom = true ]]; then
    if [[ -d $ADDITIONAL_SCRIPTS_DIRECTORY ]];
    then
        echo "Found directory $ADDITIONAL_SCRIPTS_DIRECTORY."
        echo "running additional scripts..."

        for file in "$ADDITIONAL_SCRIPTS_DIRECTORY*.sh"; do
            echo "==== $file ===="

            bash $file

            echo "$file Done!"
            echo
        done
    fi
fi