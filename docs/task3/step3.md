# Task 3 - Step 3: Track progress until the import is finished

Instructions
============

During the import process, you can track the progress by monitoring the pods status under a namespace called
multicluster-endpoint on the cluster being imported. When all pods are up and running, the import process is
finished.

You can also go to CP4MCM UI via below link to check the cluster status:
$CP4MCM_BASE_URL/multicloud/clusters

---

To monitor the pods status under multicluster-endpoint namespace...

```shell
oc get pod -n multicluster-endpoint --kubeconfig $HOME/.kube/${KIND_CLUSTER_NAME}
```

Please go to the next task or step until the cluster is imported. Before that, you can use this step to keep traking the import progress.
