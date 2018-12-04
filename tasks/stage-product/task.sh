#!/bin/bash

if [[ $DEBUG == true ]]; then
  set -ex
else
  set -e
fi

chmod +x om-cli/om-linux
CMD=./om-cli/om-linux

chmod +x ./jq/jq-linux64
JQ_CMD=./jq/jq-linux64

if [[ (! -z "$DEPENDENCY_PRODUCT_TILES") && ("null" != "$DEPENDENCY_PRODUCT_TILES") ]]; then
  STAGED_PRODUCTS=$($CMD --env env/"${ENV_FILE}" curl -s -p /api/v0/staged/products)

  for dependency in $(echo $DEPENDENCY_PRODUCT_TILES | sed "s/,/ /g")
  do
    DEPENDENCY_PRODUCT_FOUND=$(echo $STAGED_PRODUCTS | jq --arg product_name $dependency '.[] | select(.type | contains($product_name))')
    if [ -z "$DEPENDENCY_PRODUCT_FOUND" ]; then
      echo "Cannot find the dependency product tile $dependency, hence exitting"
      exit 1
    else
      echo "Found dependency product tile $dependency"
    fi
  done
fi

PRODUCT_NAME=$($CMD tile-metadata --product-path pivnet-product/*.pivotal --product-name)
PRODUCT_VERSION=$($CMD tile-metadata --product-path pivnet-product/*.pivotal --product-version)

$CMD --env env/"${ENV_FILE}" stage-product -p $PRODUCT_NAME -v $PRODUCT_VERSION
