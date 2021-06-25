#!/bin/bash

NUMERO_NODI=$1
if [ -z "$NUMERO_NODI" ] ; then NUMERO_NODI=0; fi

P2P_HOST=$2
P2P_PORT=$3
CONTAINER_NAME=$4

echo "numero nodi: $NUMERO_NODI"

DATAPATH=/var/besu/scripts/deploy/cryptofiles/admin
mkdir -p $DATAPATH

/var/besu/scripts/deploy/besu-21.1.4/bin/besu --data-path=$DATAPATH public-key export-address --to=$DATAPATH/key.address
/var/besu/scripts/deploy/besu-21.1.4/bin/besu --data-path=$DATAPATH public-key export --to=$DATAPATH/key.pub

sed -i 's/0x//' $DATAPATH/key.address

chmod -Rf 777 /var/besu/scripts/deploy/cryptofiles/*

rm -f /var/besu/scripts/ansible-config/key*
rm -f /var/besu/scripts/ansible-config/other/key*

if [ $NUMERO_NODI -gt 0 ] 
then
   
    DATAPATH=/var/besu/scripts/deploy/cryptofiles/$CONTAINER_NAME
    mkdir -p $DATAPATH
    
    /var/besu/scripts/deploy/besu-21.1.4/bin/besu --data-path=$DATAPATH public-key export-address --to=$DATAPATH/key.address
    /var/besu/scripts/deploy/besu-21.1.4/bin/besu --data-path=$DATAPATH public-key export --to=$DATAPATH/key.pub
    
    sed -i 's/0x//' $DATAPATH/key.address

    echo "enode://$(cat $DATAPATH/key.pub)@$P2P_HOST:$P2P_PORT" > $DATAPATH/enode
    sed -i 's/0x//' $DATAPATH/enode

    chmod -Rf 777 /var/besu/scripts/deploy/cryptofiles/*

    rm -f /var/besu/scripts/ansible-config/key*
    rm -f /var/besu/scripts/ansible-config/other/key*

fi

echo "Stop generate crypto "


