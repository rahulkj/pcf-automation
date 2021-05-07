#!/bin/bash -e

BASE_DIR=$(dirname "$(realpath $0)")

clis=(jq ytt yq)

set +e
for cli in "${clis[@]}"; do
  cli_exists=$(which $cli)
  if [[ -z "${cli_exists}" ]]; then
    echo "Install ${cli} cli first"
    exit 1
  fi
done

if [[ -z "${PIPELINE_DIR}" ]]; then
  read -e -p "Enter the pipelines directory: " PIPELINE_DIR
fi

if [[ -z "${ENV}" ]]; then
  read -p "Enter env name: " ENV
fi

export YTT_env=${ENV}

export ENV_PIPELINE_DIR=${PIPELINE_DIR}/${ENV}
export VALUES_FILE=values-${ENV}.yml

folders=(pipelines pipelines/download-products pipelines/ops-manager pipelines/repave pipelines/products)

for folder in "${folders[@]}"; do
  if [[ ! -d "${ENV_PIPELINE_DIR}/${folder}" ]]; then
    mkdir -p "${ENV_PIPELINE_DIR}/${folder}"
  fi
done
set -e

ytt -f "${BASE_DIR}/download-products/template.yml" -f "${BASE_DIR}/${VALUES_FILE}" \
  > "${ENV_PIPELINE_DIR}/pipelines/download-products/pipeline.yml"
ytt -f "${BASE_DIR}/download-products/template-params.yml" -f "${BASE_DIR}/${VALUES_FILE}" \
  --data-values-env YTT > "${ENV_PIPELINE_DIR}/pipelines/download-products/params-template.yml"

ytt -f "${BASE_DIR}/opsman/template.yml" -f "${BASE_DIR}/${VALUES_FILE}" \
  --data-values-env YTT > "${ENV_PIPELINE_DIR}/pipelines/ops-manager/pipeline.yml"
ytt -f "${BASE_DIR}/opsman/template-params.yml" -f "${BASE_DIR}/${VALUES_FILE}" \
  --data-values-env YTT > "${ENV_PIPELINE_DIR}/pipelines/ops-manager/params-template.yml"

ytt -f "${BASE_DIR}/repave-platform/template.yml" -f "${BASE_DIR}/${VALUES_FILE}" \
  --data-values-env YTT > "${ENV_PIPELINE_DIR}/pipelines/repave/pipeline.yml"
ytt -f "${BASE_DIR}/repave-platform/template-params.yml" -f "${BASE_DIR}/${VALUES_FILE}" \
  --data-values-env YTT > "${ENV_PIPELINE_DIR}/pipelines/repave/params-template.yml"

ytt -f "${BASE_DIR}/install-upgrade-products/template.yml" -f "${BASE_DIR}/${VALUES_FILE}" \
  > "${ENV_PIPELINE_DIR}/pipelines/products/pipeline.yml"
ytt -f "${BASE_DIR}/install-upgrade-products/template-params.yml" -f "${BASE_DIR}/${VALUES_FILE}" \
  --data-values-env YTT > "${ENV_PIPELINE_DIR}/pipelines/products/params-template.yml"

ytt -f "${BASE_DIR}/globals-params.yml" -f "${BASE_DIR}/${VALUES_FILE}" \
  --data-values-env YTT > "${ENV_PIPELINE_DIR}/pipelines/globals.yml"

PRODUCTS=$(yq e .products "${BASE_DIR}/${VALUES_FILE}" -j | jq -r '.[] | select(.metadata.deploy_product==true) | .name')

for p in ${PRODUCTS}; do
  echo "------ ${p} ------"
  if [[ ! -d "${ENV_PIPELINE_DIR}/config/${p}" ]]; then
    mkdir -p "${ENV_PIPELINE_DIR}/config/${p}" && touch "${ENV_PIPELINE_DIR}/config/${p}/.gitkeep"
  fi

  if [[ ! -d "${ENV_PIPELINE_DIR}/vars/${p}" ]]; then
    mkdir -p "${ENV_PIPELINE_DIR}/vars/${p}" && touch "${ENV_PIPELINE_DIR}/vars/${p}/.gitkeep"
  fi

  if [[ ! -d "${ENV_PIPELINE_DIR}/env" ]]; then
    mkdir -p "${ENV_PIPELINE_DIR}/env" && touch "${ENV_PIPELINE_DIR}/env/.gitkeep"
  fi
done;
