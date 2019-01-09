#!/bin/bash

if [[ $DEBUG == true ]]; then
  set -ex
else
  set -e
fi

REPLICATOR_CLI=$(find replicator/ -name "*linux")
chmod +x $REPLICATOR_CLI
CMD=./$REPLICATOR_CLI

INPUT_FILE=$(find product/ -name "*.pivotal")
FILE_NAME=$(echo $INPUT_FILE | cut -d '/' -f2)
OUTPUT_FILE=output-folder/$FILE_NAME

if [[ ! -z "$REPLICATED_NAME" ]]; then
  echo "Replicating the tile and adding " $REPLICATED_NAME
  $CMD -name $REPLICATED_NAME -path $INPUT_FILE -output $OUTPUT_FILE
else
  echo "Replication of the tile is not required " $REPLICATOR_NAME
  mv $INPUT_FILE $OUTPUT_FILE
fi

cp product/metadata.* output-folder/
cp product/version output-folder/
