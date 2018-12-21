PCF product tiles Concourse Pipelines:
---

> **CAUTION:** Pivotal does not provide support for these pipelines.
> If you find anything broken, then please submit a PR.

---

### Pipelines available in this repository are:

This repository provides the pipelines for the products listed in the following table.

| PIVOTAL PRODUCT NAME | VERSION | PIPELINE PARAMS LOCATION |
| --- | --- | --- |
| [OM + OD + PAS](https://network.pivotal.io/products/ops-manager) | 2.4.x | [Install PCF](./pipelines/install-pcf)
| [OM + OD + NSX-T + PAS](https://network.pivotal.io/products/ops-manager) | 2.4.x | [Install PCF with NSX-T](./pipelines/install-pcf/with-nsxt)
| Install Tile | x.x.x | [Install Tile](./pipelines/install-tile)
| Install Tile without Stemcell | x.x.x | [Install Tile without Stemcell](./pipelines/install-tile/without-stemcell)
| Replicate Tile and Install | x.x.x | [Replicate Tile and Install](./pipelines/install-tile-with-replicator)

---
### Following is an example on how to `fly` a pipeline:

Install PCF with NSX-T example:
```
>	fly -t concourse-[ENV] login -c https://<CONCOURSE-URL> -k
>	fly -t concourse-[ENV] set-pipeline -p install-pcf -c ./pipelines/install-pcf/with-nsxt/pipeline.yml -l ./pipelines/install-pcf/vSphere-ops-director-params.yml -l ./pipelines/install-pcf/nsxt-params.yml -l ./pipelines/install-pcf/opsman-params.yml -l ./pipelines/install-pcf/pas-params.yml -l ./pipelines/globals.yml
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
