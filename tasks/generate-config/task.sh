#!/bin/bash -e

OM_CMD=om
JQ_CMD=jq

chmod +x ./tile-config-convertor/tile-config-convertor_linux_amd64
TCC_CMD=./tile-config-convertor/tile-config-convertor_linux_amd64

function cleanAndEchoProperties {
  INPUT=$1
  OUTPUT=$2
  VARS_OUTPUT=$3

  echo "$PROPERTIES" >> $INPUT
  $TCC_CMD -c properties -i $INPUT -o $OUTPUT -ov $VARS_OUTPUT

  sed -i -e 's/^/  /' $OUTPUT
  cat $OUTPUT
  echo ""
}

function cleanAndEchoResources() {
  INPUT=$1
  OUTPUT=$2
  VARS_OUTPUT=$3

  echo "$RESOURCES" >> $INPUT
  $TCC_CMD -c resources -i $INPUT -o $OUTPUT -ov $VARS_OUTPUT

  sed -i -e 's/^/  /' $OUTPUT
  cat $OUTPUT
  echo ""
}

function cleanAndEchoErrands() {
  INPUT=$1
  OUTPUT=$2
  VARS_OUTPUT=$3

  echo "$ERRANDS" >> $INPUT
  $TCC_CMD -c errands -i $INPUT -o $OUTPUT -ov $VARS_OUTPUT

  sed -i -e 's/^/  /' $OUTPUT
  cat $OUTPUT
  echo ""
}

function echoNetworkTemplate() {
  OUTPUT=$1
  VARS_OUTPUT=$2

  $TCC_CMD -c network-azs -o $OUTPUT -ov $VARS_OUTPUT

  sed -i -e 's/^/  /' $OUTPUT
  cat $OUTPUT
  echo ""
}

function applyChangesConfig() {
  ERRANDS=$(echo "$ERRANDS" | $JQ_CMD -r '.errands[] | select(.post_deploy==true) | .name')
  APPLY_CHANGES_CONFIG_YML=apply_changes_config.yml

  echo 'apply_changes_config: |' >> "$APPLY_CHANGES_CONFIG_YML"
  echo "  deploy_products: [\"$PRODUCT_NAME\"]" >> "$APPLY_CHANGES_CONFIG_YML"
  echo "  errands:" >> "$APPLY_CHANGES_CONFIG_YML" >> "$APPLY_CHANGES_CONFIG_YML"
  echo "    $PRODUCT_NAME:" >> "$APPLY_CHANGES_CONFIG_YML"
  echo "      run_post_deploy:" >> "$APPLY_CHANGES_CONFIG_YML"

  for errand in $ERRANDS; do
    echo "        $errand: true" >> "$APPLY_CHANGES_CONFIG_YML"
  done

  echo "  ignore_warnings: true" >> "$APPLY_CHANGES_CONFIG_YML"

  echo "---"
  echo "# Apply Changes Config for $PRODUCT_NAME are:"
  cat $APPLY_CHANGES_CONFIG_YML
  echo ""
}

function echoVars {
  PRODUCT_NAME=$1

  echo ""
  echo "---"
  cat "$PRODUCT_NAME-nw-azs-vars.yml"
  cat "$PRODUCT_NAME-properties-vars.yml"
  cat "$PRODUCT_NAME-resources-vars.yml"
  cat "$PRODUCT_NAME-errands-vars.yml"
  #statements
}

PRODUCT_NAME="${OM_CMD} interpolate --config config/${CONFIG_FILE} --path /product-name -s"

CURL_CMD="$OM_CMD --env env/"${ENV_FILE}" curl -s -p"

PRODUCTS=$($CURL_CMD /api/v0/staged/products)
PRODUCT_GUID=$(echo $PRODUCTS | $JQ_CMD -r --arg product_name $PRODUCT_NAME '.[] | select(.type == $product_name) | .guid')

## Download the product properties

PROPERTIES=$($CURL_CMD /api/v0/staged/products/$PRODUCT_GUID/properties)

## Download the resources
RESOURCES=$($CURL_CMD /api/v0/staged/products/$PRODUCT_GUID/resources)

## Download the errands
ERRANDS=$($CURL_CMD /api/v0/staged/products/$PRODUCT_GUID/errands)

## Cleanup all the stuff, and echo on the console
echo "---"
echo "product_config: |"
echo "  product-name: $PRODUCT_NAME"
echoNetworkTemplate "$PRODUCT_NAME-nw-azs.yml" "$PRODUCT_NAME-nw-azs-vars.yml"
cleanAndEchoProperties "$PRODUCT_NAME-properties.json" "$PRODUCT_NAME-properties.yml" "$PRODUCT_NAME-properties-vars.yml"
cleanAndEchoResources "$PRODUCT_NAME-resources.json" "$PRODUCT_NAME-resources.yml" "$PRODUCT_NAME-resources-vars.yml"
cleanAndEchoErrands "$PRODUCT_NAME-errands.json" "$PRODUCT_NAME-errands.yml" "$PRODUCT_NAME-errands-vars.yml"
applyChangesConfig
echoVars $PRODUCT_NAME


## Clean-up the container
rm -rf $PRODUCT_NAME-*.*
