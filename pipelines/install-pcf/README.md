### PCF Installation on vSphere Only

-	This pipeline is based on the [vSphere reference architecture](https://docs.pivotal.io/pivotalcf/2-4/refarch/vsphere/vsphere_ref_arch.html)
-	Pre-requisites for using this pipeline are:
	-	3 Networks (One for each of the Infrastructure, Deployment, Services and Dynamic Services)
	-	3 AZ's (vSphere Clusters and/or Resource Pools)
	- Shared storage (Ephemeral and Persistent)
	-	DNS with wildcard domains
