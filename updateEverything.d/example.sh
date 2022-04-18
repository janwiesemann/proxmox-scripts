#!/bin/bash

echo "This is a exmaple script for custom updates."
echo "You can use \$snapshotName as a variable to get the default snapshot name. This will result in something like $snapshotName"
echo "This variable can be used to create a snapshot prior to a upgrade using 'qm snapshot 111 \$snapshotName'"
echo "If no updates where executed, it is recommendet to delete the snapshot afterwards. This can be done using 'qm delsnapshot 111 \$snapshotName'"