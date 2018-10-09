#!/bin/bash

if [[ $DEBUG == true ]]; then
  set -ex
else
  set -e
fi

chmod +x om-cli/om-linux
OM_CMD=./om-cli/om-linux

chmod +x ./jq/jq-linux64
JQ_CMD=./jq/jq-linux64

echo "$PRODUCT_PROPERTIES" > properties.yml
echo "$PRODUCT_RESOURCES" > resources.yml
echo "$PRODUCT_NETWORK_AZS" > network-azs.yml

properties_config=$(ruby -ryaml -rjson -e 'puts JSON.pretty_generate(YAML.load(ARGF))' < properties.yml)
properties_config=$(echo "$properties_config" | $JQ_CMD 'delpaths([path(.[][][]? | select(type == "null"))]) | delpaths([path(.[][]? | select(. == {}))]) | del(.[][] | nulls) | delpaths([path(.[][] | select(. == ""))]) | delpaths([path(.[] | select(. == {}))])')

echo "$properties_config" >> properties.json

echo
ruby -ryaml -rjson -e 'puts YAML.dump(JSON.parse(STDIN.read))' < properties.json > properties.yml

resources_config=$(ruby -ryaml -rjson -e 'puts JSON.pretty_generate(YAML.load(ARGF))' < resources.yml)
network_config=$(ruby -ryaml -rjson -e 'puts JSON.pretty_generate(YAML.load(ARGF))' < network-azs.yml)
