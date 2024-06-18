#!/bin/bash
#set -x

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
ORANGE='\033[0;33m'
NC='\033[0m' # No Color

# resource paths
nodePath=/root/Core-Blockchain
ipcPath=$nodePath/chaindata/node1/geth.ipc
chaindataPath=$nodePath/chaindata/node1/geth
snapshotName=/root/snapshot-import/chaindata.tar.gz


# Make sure that the node installation is found, else exit

if [ ! -e "$chaindataPath" ]; then
	echo -e "\n\n\t${RED}A node installation was not found. Exiting...${NC}"
    exit 1
fi

# stop the node incase the node is running
$nodePath/node_src/build/bin/geth --exec "exit" attach ipc:$ipcPath

echo -e "\n\t${ORANGE}Sleeping for 15 seconds so that the node can shutdown gracefully"
sleep 15

echo -e "\n\n\t${ORANGE}Removing existing chaindata, if any${NC}"
rm $ipcPath
rm -rf $chaindataPath/chaindata

echo -e "\n\n\t${GREEN}Now importing the snapshot"
wget https://snapshots.poodl.org/chaindata.tar.gz
tar -xvf $snapshotName $chaindataPath

echo -e "\n\n\tImport is done, now attempting to run the node${NC}"
sleep 3
cd $nodePath

if [ -e "$nodePath/chaindata/node1/.validator" ]; then
    type=validator
else
    type=rpc
fi

./node-start.sh --$type
