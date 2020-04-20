# Task 4 - Step 4: Define and apply a deployable

Instructions
============

Deployables are resources that wrap or represent other resources to prevent them from being deployed on hub 
cluster before the resources are placed on managed clusters. Deployables can be directly deployed to one or
more managed clusters from the storage locations that include the deployables.

As an example, in this lab, we will wrap a Kubernetes resource Deployment as a Deployable, and deploy it to
the two managed clusters that we provisioned.

---

To define the deployable, let's use samples/apps/deployable.yaml.

It wraps nginx as a Kubernetes resource Delployment.

```shell
cat samples/apps/deployable.yaml
```

Let's apply it to the hub cluster...

```shell
cat samples/apps/deployable.yaml | sed -e "s|{{LAB_NAMESPACE}}|$LAB_NAMESPACE|g" | oc apply -n $LAB_NAMESPACE -f -
```
