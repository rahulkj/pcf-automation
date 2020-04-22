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

if [[ ! -d "${PIPELINE_DIR}/pipelines" || ! -d "${PIPELINE_DIR}/pipelines/download-products" ]]; then
  mkdir -p "${PIPELINE_DIR}/pipelines/download-products"
fi

rm -rf "${PIPELINE_DIR}/pipelines/download-products/pipeline.yml" \
  "${PIPELINE_DIR}/pipelines/download-products/params.yml"

ytt -f template.yml -f values.yml > "${PIPELINE_DIR}/pipelines/download-products/pipelines.yml"
ytt -f template-params.yml -f values.yml > "${PIPELINE_DIR}/pipelines/download-products/params.yml"