# proxmox-scripts

A collection of automations I'm using in my Homelab.

## How to use

1. install git on your proxmox host
    ```
    apt install -y git
    ```
2. clone this repo
    ```
    git clone https://github.com/janwiesemann/proxmox-scripts.git
    ````

3. enter directory
    ```
    cd proxmox-scripts
    ````

4. execute scripts

    1. using bash
        ```
        bash script.sh
        ```
    
    2. or

        ```
        chmod +x script.sh
        ./script.sh
        ```

## Available Scripts

- ### `debugHelper.sh`
    helper script for easy debugging
    
- ### `updateEverything.sh`
    This script can be used to update all PVE Nodes (Host systems), Container and VMs.
    
    All nodes in your cluster will be updated. This can be avoided by using the argument `currentNode`.

    _A cluster has to be created and `pvecm nodes` has to be working. Node names must resolve to the corresponding IPs. I.e. Node named Proxmox => 10.0.0.3_

    #### Stages/Arguments/Switches
    You can combine multiple arguments i.e. `./updateEverything host custom`
    Command | Function
    ---|---
    _`empty`_<br/>`all` | Update everything. All stages can be found below
    `host` | Update Host
    `lxc`| Update Containers. `apt update -y` will be executed inside every container. If updates are avalible a snapshot will be created and averything will be upgreaded using `apt upgrade -y`. If the file `/root/update.sh` is present, a snapshot is also is created and the script will be executed. This file has to be placed <b>inside</b> your container!
    `custom` | Executes custom scripts in the directory `./updateEverything.d/`. This can be used to enter and update VMs. You can use the enviorment variable `snapshotName` to get the default snapshot name also used on LXCs. A example can be found in the subdirectory `./updateEverything.d/example.sh` of this repository.
    `currentNode` | Execute the above stages only on the current node.