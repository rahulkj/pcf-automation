HOW TO USE
---

## Prerequisites
Install the following cli's
- jq
- yq
- ytt

## Steps to execute

* Update the `create_pipeline.sh` script to update the `PIPELINE_DIR` variable to point to the desired folder
* Modify the script to your desired `config`, `pipelines` and `vars` folders
* Update the `values.yml` to add the products you desire to be part of the pipeline
  ```
  products:
  - name: pas
    slug: ((pas_product_slug))
    version: ((pas_product_version))
    s3_bucket: ((s3_pas_bucket))
    s3_product_regex: "(.*).pivotal"
    s3_stemcells_regex: "(.*).tgz"
    has_stemcell: True
  ```
* Execute the script now.

On execution, it will result in the follow directories:

```
.
├── config
│   ├── harbor
│   │   ├── config.yml
│   │   └── deploy-products.yml
│   ├── pas
│   │   ├── config.yml
│   │   └── deploy-products.yml
│   └── pks
│       ├── config.yml
│       └── deploy-products.yml
├── pipelines
│   ├── params.yml
│   └── pipeline.yml
└── vars
    ├── harbor
    │   └── vars.yml
    ├── pas
    │   └── vars.yml
    └── pks
        └── vars.yml

9 directories, 11 files
```

Now switch into the `pipelines` director and fly the pipeline:
`fly -t dev sp -p products -c $PIPELINE_DIR/pipelines/pipeline.yml -l $PIPELINE_DIR/pipelines/params.yml -l ../pipelines/globals.yml`

![](concourse.png)


**NOTE: You will need to update the config, vars and also the params.yml file**
