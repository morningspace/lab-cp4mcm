# Task 3 - Step 1: Provision a local cluster using kind

Instructions
============

To provision a cluster using kind is very easy. Just tell kind how the cluster will look like by defining a 
config file. Then run kind command to provision the cluster. Usually, it takes 1 or 2 minutes to finish.

---

Determine the cluster name that you want to provision using kind and save as $KIND_CLUSTER_NAME...

<!--
var::set "Input cluster name" "KIND_CLUSTER_NAME"
var::save "KIND_CLUSTER_NAME"
-->

Let's use below config file to define the cluster. It is a cluster with one master node and two worker nodes.

```shell
cat samples/kind/config.yaml
```

To provision the cluster, run kind command as below...

```shell
kind create cluster --config samples/kind/config.yaml --kubeconfig $HOME/.kube/kind-kubeconfig --name ${KIND_CLUSTER_NAME}
```

It also saves the kubeconfig file into $HOME/.kube folder. See how the kubeconfig looks like...

```shell
cat $HOME/.kube/kind-kubeconfig
```

Now, you can use below commands to access the cluster which is provisioned by kind...

To list the nodes:

```shell
oc get node --kubeconfig $HOME/.kube/kind-kubeconfig
```

And all pods running on these nodes:

```shell
oc get pod --all-namespaces --kubeconfig $HOME/.kube/kind-kubeconfig
```
