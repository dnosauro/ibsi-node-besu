#!/bin/bash -u

hash jq 2>/dev/null || {
  echo >&2 "This script requires jq but it's not installed."
  echo >&2 "Refer to documentation to fulfill requirements."
  exit 1
}

echo "[\""$(paste -d, $(ls ../deploy/cryptofiles/node*/key.address) |sed 's/,/\",\"/g' |tr '\n' '"')"]" > ../deploy/genesisfile/toEncode.json

extradata=$(cat ../deploy/genesisfile/toEncode.json | ../deploy/besu-21.1.4/bin/besu rlp encode)
node_ingress_code=`cat ../deploy/permissioning-smart-contracts/src/chain/abis/NodeIngress.json | jq '.["deployedBytecode"]'`
account_ingress_code=`cat ../deploy/permissioning-smart-contracts/src/chain/abis/AccountIngress.json | jq '.["deployedBytecode"]'`
node_address_admin=`cat ../deploy/cryptofiles/admin/key.address`

rm -f ../deploy/genesisfile/toEncode.json

sed -e "s/EXTRA_DATA/${extradata}/g" \
    -e "s/NODE_ADDRESS_ADMIN/$node_address_admin/g" \
    -e "s/NODE_INGRESS_CODE/$node_ingress_code/g" \
    -e "s/ACCOUNT_INGRESS_CODE/$account_ingress_code/g" ../deploy/genesisfile/ibft2GenesisPermissioning.json.template > ../deploy/besu/node/config/ibft2GenesisPermissioning.json



