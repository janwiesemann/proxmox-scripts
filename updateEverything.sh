#!/bin/bash

ADDITIONAL_SCRIPTS_DIRECTORY=$(realpath "./updateEverything.d/")
TMP_DIR="~/.pvescripts_tmp"

#debugging helper
if [[ -f "./debugHelper.sh" ]]; then
    source ./debugHelper.sh
fi

#this script is used to update every system. This includes the Host and Containers

executeHost=false
executeLXC=false
executeCustom=false

#if this is true, the preparing will not be executed. The script will actually be invoked
isInvoke=false

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
    elif [[ "$var" =~ "currentNode" ]]; then
        isInvoke=true
    fi
done

#if no arguement was set use 'all'
if [[ $executeHost = false && $executeLXC = false && $executeCustom = false ]]; then
    executeHost=true
    executeLXC=true
    executeCustom=true
fi

snapshotName="updateSnapshot_$(date +%Y_%m_%d_%H_%M)"
export snapshotName

if [[ $isInvoke = false ]]; then
    echo "Searching Nodes..."
    nodes=$(pvecm nodes | tail -n +5 | cut -f21 -d' ')
    echo
    for node in $nodes
    do
        echo "====== $node ======"

        echo "preparing..."
        ssh -t root@$node "mkdir -p $TMP_DIR" 2> /dev/null
        scp "$(realpath "${BASH_SOURCE[0]}")" "root@$node:$TMP_DIR" > /dev/null #current file

        scriptFile="$TMP_DIR/$(basename $0)"
        echo "executing '$scriptFile' on $node..."

        #invoke update script
        ssh -t root@$node "bash $scriptFile currentNode $@"

        echo "cleanup...";
        ssh -t root@$node "rm -rf $TMP_DIR" 2> /dev/null
        echo
    done

    #executing custom scripts from $ADDITIONAL_SCRIPTS_DIRECTORY
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
else
    #Update Host OS
    if [[ $executeHost = true ]]; then
        echo "==== Host ===="
        apt update -y
        apt full-upgrade -y --autoremove

        echo "Host Done!"
        echo
    fi

    #update containers and create snapshots if updates are avalible
    if [[ $executeLXC = true ]]; then
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
                        pct snapshot $container $snapshotName

                        if [ $numOfUpdatesAvalible -gt 1 ]; then
                                echo "installing $((numOfUpdatesAvalible - 1)) updates..."
                                pct exec $container -- apt full-upgrade -y --autoremove
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
fi

unset snapshotName
