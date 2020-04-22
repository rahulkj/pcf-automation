#!/bin/bash -e

PIPELINE_DIR=/Users/rjain/Documents/github/rahulkj/secrets

clis=(jq ytt yq)

set +e
for cli in "${clis[@]}"; do
  cli_exists=$(which $cli)
  if [[ -z "${cli_exists}" ]]; then
    echo "Install ${cli} cli first"
    exit 1
  fi
done
set -e

if [[ ! -d "${PIPELINE_DIR}/pipelines" || ! -d "${PIPELINE_DIR}/pipelines/products" || ! -d "${PIPELINE_DIR}/pipelines/download-products" ]]; then
  mkdir -p "${PIPELINE_DIR}/pipelines"
  mkdir -p "${PIPELINE_DIR}/pipelines/products"
  mkdir -p "${PIPELINE_DIR}/pipelines/download-products" 
fi

rm -rf "${PIPELINE_DIR}/pipelines/products/pipeline.yml" "${PIPELINE_DIR}/pipelines/products/params-template.yml"
rm -rf "${PIPELINE_DIR}/pipelines/download-products/pipeline.yml" "${PIPELINE_DIR}/pipelines/download-products/params-template.yml"

ytt -f products-template.yml -f values.yml > "${PIPELINE_DIR}/pipelines/products/pipeline.yml"
ytt -f products-template-params.yml -f values.yml > "${PIPELINE_DIR}/pipelines/products/params-template.yml"

ytt -f download-products-template.yml -f values.yml > "${PIPELINE_DIR}/pipelines/download-products/pipeline.yml"
ytt -f download-products-template-params.yml -f values.yml > "${PIPELINE_DIR}/pipelines/download-products/params-template.yml"

ytt -f globals-params.yml -f values.yml> "${PIPELINE_DIR}/pipelines/globals.yml"

PRODUCTS=$(yq r values.yml products -j | jq -r '.[].name')

for p in ${PRODUCTS}; do
  echo "------ ${p} ------"
  if [[ ! -d "${PIPELINE_DIR}/config/${p}" ]]; then
    mkdir -p "${PIPELINE_DIR}/config/${p}" && touch "${PIPELINE_DIR}/config/${p}/.gitkeep"
  fi

  if [[ ! -d "${PIPELINE_DIR}/vars/${p}" ]]; then
    mkdir -p "${PIPELINE_DIR}/vars/${p}" && touch "${PIPELINE_DIR}/vars/${p}/.gitkeep"
  fi

  if [[ ! -d "${PIPELINE_DIR}/env" ]]; then
    mkdir -p "${PIPELINE_DIR}/env" && touch "${PIPELINE_DIR}/env/.gitkeep"
  fi
done;
