#!/bin/bash

if [[ $DEBUG == true ]]; then
  set -ex
else
  set -e
fi

REPLICATOR_CLI=$(find winfs-injector/ -name "*linux")
chmod +x $REPLICATOR_CLI
CMD=./$REPLICATOR_CLI

INPUT_FILE=$(find pivnet-product/ -name "*.pivotal")
FILE_NAME=$(echo $INPUT_FILE | cut -d '/' -f2)
OUTPUT_FILE=output-folder/$FILE_NAME

$CMD --input-tile $INPUT_FILE --output-tile $OUTPUT_FILE

cp pivnet-product/metadata.* output-folder/
cp pivnet-product/version output-folder/
