# Task 2 - Step 2: Apply apikey.yaml and cluster.yaml to kick off the provision

Instructions
============

Define the cluster name and the region on AWS where you want to provision your cluster. Fill in the two YAML
files: "apikey.yaml" and "cluster.yaml", which are required to provision the cluster with these values along
with the base64 encoded access key ID and secret access key.

Then apply the above YAML files on the hub cluster to kick off the provision. Usually, it takes more than 10
minutes to finish. As it essentially invokes AWS EKS, it depends on how fast AWS EKS provisions a cluster.

---

Firstly, let's input all the parameters that are required to provision your cluster on AWS, e.g.: the cluster name, the region used to provision the cluster, ...

<!--
var::set-required "Input cluster name" "AWS_CLUSTER_NAME"
var::set-required "Input AWS region" "AWS_REGION"
var::save "AWS_CLUSTER_NAME"
var::save "AWS_REGION"
-->

Then, use these values to populate the two YAML files.

```
1) samples/eks/apikey.yaml: Used to create the secret for AWS access.
2) samples/eks/cluster.yaml: Used to define how the cluster will look like.
```

Let's see how they look like...

```shell
cat samples/eks/apikey.yaml
cat samples/eks/cluster.yaml
```

Now, let's start to provision the cluster on AWS by applying the above YAML files...

Encode $AWS_ACCESS_KEY_ID and $AWS_SECRET_ACCESS_KEY in base64:

```shell
ID=$(printf $AWS_ACCESS_KEY_ID | base64)
KEY=$(printf $AWS_SECRET_ACCESS_KEY | base64)
```

Apply apikey.yaml...

```shell
cat samples/eks/apikey.yaml | sed -e "s|{{AWS_ACCESS_KEY_ID}}|$ID|g" -e "s|{{AWS_SECRET_ACCESS_KEY}}|$KEY|g" | oc apply -n $LAB_NAMESPACE -f -
```

Apply cluster.yaml...

```shell
cat samples/eks/cluster.yaml | sed -e "s|{{CLUSTER_NAME}}|$CLUSTER_NAME|g" -e "s|{{AWS_REGION}}|$AWS_REGION|g" | oc apply -n $LAB_NAMESPACE -f -
```
