#!/bin/bash -e

PIPELINE_DIR=$PWD/test

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

if [[ ! -d "${PIPELINE_DIR}/pipelines" ]]; then
  mkdir -p "${PIPELINE_DIR}/pipelines"
fi

rm -rf "${PIPELINE_DIR}/pipelines/pipeline.yml" "${PIPELINE_DIR}/pipelines/params.yml"

ytt -f template.yml -f values.yml > "${PIPELINE_DIR}/pipelines/pipeline.yml"
ytt -f template-params.yml -f values.yml > "${PIPELINE_DIR}/pipelines/params.yml"

PRODUCTS=$(yq r values.yml products -j | jq -r '.[].name')

for p in ${PRODUCTS}; do
  echo ${p} + "test"
  if [[ ! -d "${PIPELINE_DIR}/config/${p}" ]]; then
    mkdir -p "${PIPELINE_DIR}/config/${p}" && touch "${PIPELINE_DIR}/config/${p}/config.yml"
    mkdir -p "${PIPELINE_DIR}/config/${p}" && touch "${PIPELINE_DIR}/config/${p}/deploy-products.yml"
  fi

  if [[ ! -d "${PIPELINE_DIR}/vars/${p}" ]]; then
    mkdir -p "${PIPELINE_DIR}/vars/${p}" && touch "${PIPELINE_DIR}/vars/${p}/vars.yml"
  fi
done;
