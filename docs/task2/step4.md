# Task 2 - Step 4: Get the cluster secret to access the provisioned cluster

Instructions
============

After the cluster is provisioned, you can get the cluster secret and saved as a kubeconfig file which can be
used to access the cluster.

You can also go to CP4MCM UI on the hub cluster via below link to check the cluster status. Find the cluster
from the cluster list, then click it to go to the details page:
$CP4MCM_BASE_URL/multicloud/clusters

---

To get the cluster resource defined on hub cluster...

```shell
oc get cluster.cluster.k8s.io ${AWS_CLUSTER_NAME} -n $LAB_NAMESPACE
```

By describing the cluster resource, you can see a `CreateClusterSuccessful` event in the Event list when the cluster is created...

```shell
oc describe cluster.cluster.k8s.io/${AWS_CLUSTER_NAME} -n $LAB_NAMESPACE
```

To find the cluster secret...

```shell
CLUSTER_SECRET=$(oc get secret -n $LAB_NAMESPACE -o name | grep ${AWS_CLUSTER_NAME})
```

To save as kubeconfig file into $HOME/.kube folder...

```shell
oc get ${CLUSTER_SECRET} -n $LAB_NAMESPACE -o 'go-template={{index .data \"kubeconfig-eks\"}}' | base64 --decode > $HOME/.kube/eks-kubeconfig
```

See how the kubeconfig looks like...

```shell
cat $HOME/.kube/eks-kubeconfig
```

Now, you can use below commands to access the cluster which is running remotely on AWS EKS...
```shell
oc get node --kubeconfig $HOME/.kube/eks-kubeconfig
oc get pod --all-namespaces --kubeconfig $HOME/.kube/eks-kubeconfig
```
