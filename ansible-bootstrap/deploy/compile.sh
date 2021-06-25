#!/bin/bash -u

hash jq 2>/dev/null || {
  echo >&2 "This script requires jq but it's not installed."
  echo >&2 "Refer to documentation to fulfill requirements."
  exit 1
}

hash yarn 2>/dev/null || {
  echo >&2 "This script requires yarn but it's not installed."
  echo >&2 "Refer to documentation to fulfill requirements."
  exit 1
}

cd ../deploy/permissioning-smart-contracts

rm -rf build/*

yarn install
yarn run build
cd ..

echo "Smartcontract compilato correttamente"
