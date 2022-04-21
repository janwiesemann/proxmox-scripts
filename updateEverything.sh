#!/bin/bash

ADDITIONAL_SCRIPTS_DIRECTORY="./updateEverything.d/"

#debugging helper
if [[ -f "./debugHelper.sh" ]]; then
    source ./debugHelper.sh
fi

#this script is used to update every system. This includes the Host and Containers

executeHost=false
executeLXC=false
executeCustom=false

#Parse command line arguments
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

#if no arguement was set use 'all'
if [[ $executeHost = false && $executeHost = false && $executeCustom = false ]]; then
    executeHost=true
    executeLXC=true
    executeCustom=true
fi

#Update Host OS
if [[ $executeHost = true ]]; then
    echo "==== Host ===="
    apt update -y
    apt upgrade -y

    echo "Host Done!"
    echo
fi

snapshotName="updateSnapshot_$(date +%Y_%m_%d_%k_%M)"
export snapshotName

#update containers and create snapshots if updates are avalible
if [[ $executeHost = true ]]; then
echo "Searching Containers...."
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
                            echo "executing update.sh script"
                            pct exec $container -- bash ~/update.sh
                    fi
            fi

            echo "$container Done!"
            echo
        fi
    done;
fi

#executing custom scripts
if [[ $executeCustom = true ]]; then
    if [[ -d $ADDITIONAL_SCRIPTS_DIRECTORY ]]; then
        echo "Found directory $ADDITIONAL_SCRIPTS_DIRECTORY"
        echo "running additional scripts..."

        currentDir=$PWD

        for file in $ADDITIONAL_SCRIPTS_DIRECTORY*.sh; do
            if [[ "$file" != "$ADDITIONAL_SCRIPTS_DIRECTORY*.sh" ]]; then
                cd "$currentDir" #reset workdir for every subscript
                echo "==== $file ===="

                bash $file

                echo "$file Done!"
                echo
            fi
        done

        cd "$currentDir"
    fi
fi

unset snapshotName