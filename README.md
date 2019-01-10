PCF product tiles Concourse Pipelines:
---

> **CAUTION:** Pivotal does not provide support for these pipelines.
> If you find anything broken, then please submit a PR.

---

**Before you start, make sure you have access to [Platform Automation](https://network.pivotal.io/products/platform-automation) on PivNet, else reach out to your PA/SA to gain access to the release.**

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

---
### Following is an example on how to `fly` a pipeline:

Install PCF with NSX-T example:
```
>	fly -t concourse-[ENV] login -c https://<CONCOURSE-URL> -k
>	fly -t concourse-[ENV] set-pipeline -p install-pcf -c ./pipelines/install-pcf/with-nsxt/pipeline.yml -l ./pipelines/install-pcf/vSphere-ops-director-params.yml -l ./pipelines/install-pcf/with-nsxt/nsxt-params.yml -l ./pipelines/install-pcf/opsman-params.yml -l ./pipelines/install-pcf/pas-params.yml -l ./pipelines/globals.yml
>	fly -t concourse-[ENV] unpause-pipeline -p install-pcf
```

Install Healthwatch example:
```
>	fly -t concourse-[ENV] login -c https://<CONCOURSE-URL> -k
>	fly -t concourse-[ENV] set-pipeline -p healthwatch -c ./pipelines/install-tile/pipeline.yml -l ./pipelines/globals.yml -l ./pipelines/tiles/healthwatch/params.yml
>	fly -t concourse-[ENV] unpause-pipeline -p healthwatch
```

---
### Docker Images
* Download the [Platform Automation Docker Image](https://network.pivotal.io/products/platform-automation)
* Install [Docker](https://hub.docker.com/search/?type=edition&offering=community) on your machine
* Run `docker import platform-automation-image-x.x.x.tgz <COMPANY-ORG>/platform-automation-image`
* `docker login`
* `docker push <COMPANY-ORG>/platform-automation-image`

You can now update the [globals.yml](./pipelines/globals.yml) and update the variable `platform_automation_image_repository` to point to your docker registry

---

### Some tricks

For using certificates via credhub, in the pipelines, then,
- store the **RAW** certificate in a file, ex: `backup_private_key.pem`
- login into `credhub`
- Execute the command `credhub set -n /concourse/main/backup_private_key -t password -v "$(awk '$1=$1' ORS='\\\\n' backup_private_key.pem | awk '{printf("\"\\\"%s\\\"\"\n", $0);}')"`

Now you can use, the variable `backup_private_key` in all the pipelines, that need the backup key.
