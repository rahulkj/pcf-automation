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
| [Install Tile] | x.x.x | [Install Tiles](./pipelines/install-tile)
| [Install Tile without Stemcell] | x.x.x | [Install Tile without Stemcell](./pipelines/install-tile/without-stemcell)

---
### Following is an example on how to `fly` a pipeline:

```
>	fly -t concourse-[ENV] login -c https://<CONCOURSE-URL> -k
>	fly -t concourse-[ENV] set-pipeline -p healthwatch -c ./pipelines/install-tile/pipeline.yml -l ./pipelines/tiles/healthwatch/params.yml
>	fly -t concourse-[ENV] unpause-pipeline -p healthwatch
```
