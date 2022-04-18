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

## Avalible Scripts

<ul>
    <li>
        debugHelper.sh<br/>
        helper script for easy debugging
    </li>
    <li>
        updateEverything.sh<br/>
        This script can be used to update your Host, Containsers and VMs<br/><br/>
        <h3>Arguments/Switches</h3>
        You can combine multiple arguments <code>./updateEverything host custom</code>
        <table>
            <theader>
                <tr>
                    <td>Command</td>
                    <td>Function</td>
                </tr>
            </theader>
            <tbody>
                <tr>
                    <td>
                        empty<br/>
                        <code>all</code>
                    </td>
                    <td>Update everything. All stages can be found below</td>
                </tr>
                <tr>
                    <td><code>host</code></td>
                    <td>Update Host</td>
                </tr>
                <tr>
                    <td><code>lxc</code></td>
                    <td>Update Containers. <code>apt update -y</code> will be executed inside every container. If updates are avalible a snapshot will be created and averything will be upgreaded using <code>apt upgrade -y</code>. If the file <code>/root/update.sh</code> is present, a snapshot is also is created and the script will be executed. This file has to be placed <b>inside</b> your container!</td>
                </tr>
                <tr>
                    <td><code>custom</code></td>
                    <td>Executes custom scripts in the directory <code>./updateEverything.d/</code>. This can be used to enter and update VMs. You can use the enviorment variable <code>snapshotName</code> to get the default snapshot name also used on LXCs. A example can be found in the subdirectory <code>./updateEverything.d/example.sh</code> of this repository</td>
                </tr>
            </tbody>
        </table>
    </li>
</ul>