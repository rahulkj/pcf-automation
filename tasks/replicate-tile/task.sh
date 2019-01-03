#!/bin/bash

if [[ $DEBUG == true ]]; then
  set -ex
else
  set -e
fi

chmod +x replicator/replicator-linux
CMD=./replicator/replicator-linux

INPUT_FILE=`find pivnet-product/ -name "*.pivotal"`
FILE_NAME=`echo $INPUT_FILE | cut -d '/' -f3`
OUTPUT_FILE=output-folder/$FILE_NAME

if [[ ! -z "$REPLICATED_NAME" ]]; then
  echo "Replicating the tile and adding " $REPLICATED_NAME
  $CMD -name $REPLICATED_NAME -path $INPUT_FILE -output $OUTPUT_FILE
else
  echo "Replication of the tile is not required " $REPLICATOR_NAME
  mv $INPUT_FILE $OUTPUT_FILE
fi
