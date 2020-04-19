#!/bin/bash -e

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

read -p "Enter env name: " ENV
export YTT_env=$ENV

PIPELINE_DIR=$PWD/$ENV

if [[ ! -d "${PIPELINE_DIR}/pipelines" ]]; then
  mkdir -p "${PIPELINE_DIR}/pipelines"
fi

rm -rf "${PIPELINE_DIR}/pipelines/pipeline.yml" "${PIPELINE_DIR}/pipelines/params.yml"

ytt -f template.yml -f values.yml > "${PIPELINE_DIR}/pipelines/pipeline.yml"
ytt -f template-params.yml -f values.yml --data-values-env YTT > "${PIPELINE_DIR}/pipelines/params.yml"

PRODUCTS=$(yq r values.yml products -j | jq -r '.[].name')

for p in ${PRODUCTS}; do
  echo "----- ${p} -----"
  if [[ ! -d "${PIPELINE_DIR}/config/${p}" ]]; then
    mkdir -p "${PIPELINE_DIR}/config/${p}" && touch "${PIPELINE_DIR}/config/${p}/.gitkeep"
  fi

  if [[ ! -d "${PIPELINE_DIR}/vars/${p}" ]]; then
    mkdir -p "${PIPELINE_DIR}/vars/${p}" && touch "${PIPELINE_DIR}/vars/${p}/.gitkeep"
  fi

  if [[ ! -d "${PIPELINE_DIR}/errands" ]]; then
    mkdir -p "${PIPELINE_DIR}/errands"
  fi

  if [[ ! -f "${PIPELINE_DIR}/errands/${p}" ]]; then
    touch "${PIPELINE_DIR}/errands/${p}"
  fi
done;
