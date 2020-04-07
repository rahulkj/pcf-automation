#!/bin/bash -e

CLI_EXISTS=$(which ytt)

if [[ -z "${CLI_EXISTS}" ]]; then
  echo "Install ytt cli first https://get-ytt.io/"
  exit 1
fi

rm -rf pipeline.yml

ytt -f template.yml -f values.yml > pipeline.yml
