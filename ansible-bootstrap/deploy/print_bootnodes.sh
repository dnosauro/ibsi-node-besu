#!/bin/bash

BN="bootnodes=[\"$(paste -d\| $(ls /var/besu/scripts/deploy/cryptofiles/node*/enode) | tr -d '\n'| sed 's/|/","/g')\"]"

sed -i 's|bootnodes=.*|'$BN'|' ../deploy/besu/template/config.toml

echo "Lista bootnode sostituita correttamente nel file template config.toml"

