Tanzu product (PCF) tiles Concourse Pipelines:
---

> **CAUTION:** VMware does not provide support for these pipelines.
> If you find anything broken, then please submit a PR.

---

**Before you start, make sure you have access to [Platform Automation Toolkit](https://network.pivotal.io/products/platform-automation) on PivNet.**
These pipelines are based on [Platform Automation Toolkit](https://network.pivotal.io/products/platform-automation) and a few of the tasks have been customized to meet the real world scenarios

There are 2 approaches here for using the pipelines:
- Generate the pipelines using ytt
- Run individual pipelines for each product/s

No approach is right or wrong here. I would try the option 1 first, and then if there are any gaps with it, I will switch to option 2 for those products.

## Generate the pipelines using ytt
If you choose to have auto-generated pipelines, then please head to [generate-pipelines](./generate-pipelines)

## Run individual pipelines for each product/s
If you choose to run individual pipelines, then please head to [individual-pipelines](./individual-pipelines)

Please file bugs if something isn't right. PR's are welcome too.

## Begin here:

The pipelines leverage locks ([concourse pool resource](https://github.com/concourse/pool-resource)), for locking mechanism. To begin, we will need 3 locks in 1 repo, so create a new repo called `pipeline-locks`

```
.
├── opsman-install-pipeline-lock
│   ├── README.md
│   ├── claimed
│   └── unclaimed
│       └── homelab
├── opsman-upgrade-pipeline-lock
│   ├── README.md
│   ├── claimed
│   │   └── homelab
│   └── unclaimed
└── product-pipeline-lock
    ├── README.md
    ├── claimed
    └── unclaimed
       └── homelab
```

Notice the state of the locks, this is intentional. We can to run install of ops manager just once, and the others will locked/unlocked back on the upgrade of ops manager/product tiles.

Once this is set, you can generate the pipelines after filling out the `values.yml`

Fly the pipelines and orchestrate the deployment.
