# Task 2 - Step 2: Apply apikey.yaml and cluster.yaml to kick off the provision

  Instructions
  ============

  Define the cluster name and the region on AWS where you want to provision your cluster. Fill in the two YAML
  files: "apikey.yaml" and "cluster.yaml", which are required to provision the cluster with these values along
  with the base64 encoded access key ID and secret access key.

  Then apply the above YAML files on the hub cluster to kick off the provision. Usually, it takes more than 10
  minutes to finish. As it essentially invokes AWS EKS, it depends on how fast AWS EKS provisions a cluster.
