PCF product tiles Concourse Pipelines:
---

> **CAUTION:** Pivotal does not provide support for these pipelines.
> If you find anything broken, then please submit a PR.

---

**Before you start, make sure you have access to [Platform Automation](https://network.pivotal.io/products/platform-automation) on PivNet, else reach out to your PA/SA to gain access to the release.**

* Create a git repo, based on instructions from [Concourse Pool Resource](https://github.com/concourse/pool-resource)
  - Avoids pipelines from stepping on each other, as they wait for the lock to be released, before they run
* Create a git repo, to store the pipeline config, for example, create a config directory, and folder based config for each product.
```
.
├── config
│   ├── compliance
│   │   ├── config.yml
│   │   └── deploy-products.yml
│   ├── director
│   │   └── director.yml
│   ├── event-alerts
│   │   ├── config.yml
│   │   └── deploy-products.yml
│   ├── healthwatch
│   │   ├── config.yml
│   │   └── deploy-products.yml
│   ├── install-pcf
│   │   ├── nsxt-config.yml
│   │   ├── ops-director-config.yml
│   │   ├── ops-director-pks-config.yml
│   │   ├── opsman-auth.yml
│   │   ├── opsman-config.yml
│   │   ├── pas-config.yml
│   │   └── pks-config.yml
│   ├── mysql
│   │   ├── config.yml
│   │   └── deploy-products.yml
│   ├── opsman-env
│   │   └── env.yml
│   ├── p-rabbitmq
│   │   ├── config.yml
│   │   └── deploy-products.yml
│   ├── pks
│   │   ├── config.yml
│   │   └── deploy-products.yml
│   └── upgrade-opsman
│       └── env.yml
├── config-aws
│   └── install-pcf
│       ├── ops-director-config.yml
│       ├── opsman-auth.yml
│       ├── opsman-config.yml
│       └── pas-config.yml
└── state-files
    ├── README.md
    ├── aws-state.yml
    └── homelab-state.yml
```
* Update the `globals.yml` variables
  - `config_repo_git_url`
  - `automation_git_url`
  - `locks_repo_git_url`

* Load all the secrets in credhub _(These pipelines heavily rely on credhub)_
---

### Pipelines available in this repository are:

This repository provides the pipelines for the products listed in the following table.

| PIVOTAL PRODUCT NAME | VERSION | PIPELINE PARAMS LOCATION |
| --- | --- | --- |
| [OM + OD](https://network.pivotal.io/products/ops-manager) + [PAS](https://network.pivotal.io/products/elastic-runtime) | 2.4.x | [Install PCF](./pipelines/install-pcf)
| [OM + OD](https://network.pivotal.io/products/ops-manager) + [NSX-T](https://network.pivotal.io/products/vmware-nsx-t/) + [PAS](https://network.pivotal.io/products/elastic-runtime) | 2.4.x | [Install PCF with NSX-T](./pipelines/install-pcf/with-nsxt)
| OM upgrade | 2.4.x | [OpsManager Upgrade](./pipelines/upgrade-opsman)
| Install Tile | x.x.x | [Install Tile](./pipelines/install-tile)
| Install Tile without Stemcell | x.x.x | [Install Tile without Stemcell](./pipelines/install-tile/without-stemcell)
| Replicate Tile and Install | x.x.x | [Replicate Tile and Install](./pipelines/install-tiles-using-replicator)
| Replicate [PAS for windows](https://network.pivotal.io/products/pas-windows) and Install | x.x.x | [Replicate PAS for windows and Install](./pipelines/install-windows-tile)
| Repave | --- | [Repave](./pipelines/repave)

---
### Following is an example on how to `fly` a pipeline:

`export PIPELINES_REPO=~/Documents/workspace/automation-repo`
`export CONFIG_REPO=~/Documents/workspace/config-repo`

Install PCF with NSX-T example:
```
>	fly -t concourse-[ENV] login -c https://<CONCOURSE-URL> -k
>	fly -t concourse-[ENV] set-pipeline -p install-pcf -c $PIPELINES_REPO/pipelines/install-pcf/with-nsxt/pipeline.yml \
      -l $CONFIG_REPO/params/install-pcf/params.yml \
      -l $PIPELINES_REPO/pipelines/globals.yml
>	fly -t concourse-[ENV] unpause-pipeline -p install-pcf
```

Install Healthwatch example (Applicable for any tile):
```
>	fly -t concourse-[ENV] login -c https://<CONCOURSE-URL> -k
>	fly -t concourse-[ENV] set-pipeline -p healthwatch -c $PIPELINES_REPO/pipelines/install-tile/pipeline.yml \
      -l $PIPELINES_REPO/pipelines/globals.yml \
      -l $CONFIG_REPO/params/install-tile/healthwatch-params.yml
>	fly -t concourse-[ENV] unpause-pipeline -p healthwatch
```

Upgrade OpsManager example:
```
>	fly -t concourse-[ENV] login -c https://<CONCOURSE-URL> -k
>	fly -t concourse-[ENV] set-pipeline -p upgrade-opsman -c $PIPELINES_REPO/pipelines/upgrade-opsman/pipeline.yml \
      -l $PIPELINES_REPO/pipelines/globals.yml \
      -l $CONFIG_REPO/params/upgrade-opsman/params.yml
>	fly -t concourse-[ENV] unpause-pipeline -p upgrade-opsman
```

Repave all VMs example:
```
>	fly -t concourse-[ENV] login -c https://<CONCOURSE-URL> -k
>	fly -t concourse-[ENV] set-pipeline -p repave -c $PIPELINES_REPO/pipelines/repave/pipeline.yml \
      -l $PIPELINES_REPO/pipelines/globals.yml \
      -l $CONFIG_REPO/params/repave/params.yml
>	fly -t concourse-[ENV] unpause-pipeline -p repave
```
---
### Store your secrets

- Ensure you have all the secrets stored in credhub. Also include the following to your list:
  - credhub_server_ca
  - credhub_client
  - credhub_client_secret
  - credhub_server

^^^ will be needed to fetch the secrets from credhub to interpolate the env.yml and config's

---
### Configuration

- For OpsManager/Ops Director configuration, refer to http://docs.pivotal.io/pcf-automation/latest/reference/inputs-outputs.html
- For product configuration, you can generate the config after the staging is complete, and you can trigger the `generate-config` job. Capture the output and tweak it as needed.
- Create a new folder for this product, for ex: in your `config_repo_git_url` repo, create a folder `config/product`, and create a file called `config.yml` and paste the above contents into it. Take a look at [config](./config) folder
- Finally, re-run the `config-product` job
---

### Some tricks

For using certificates via credhub, in the pipelines, then,
- store the **RAW** certificate in a file, ex: `backup_private_key.pem`
- login into `credhub`
- Execute the command `credhub set -n /concourse/main/backup_private_key -t value -v "$(awk '$1=$1' ORS='\\\\n' backup_private_key.pem | awk '{printf("\"\\\"%s\\\"\"\n", $0);}')"`

Now you can use, the variable `backup_private_key` in all the pipelines, that need the backup key.
