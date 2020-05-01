# Task 4 - Step 5: Check results

Instructions
============

After we define applications, channels, subscriptions properly, newly created deployable will be deployed on
to the managed clusters from the hub cluster through the channel, subscription mechanism. Usually, it takes
a few minutes to finish the whole process.

You can check the results by issuing oc command both on hub cluster and managed clusters.

You can also check CP4MCM UI by visiting below link:
$CP4MCM_BASE_URL/multicloud/applications

---

To list applications defined on hub cluster...

```shell
oc get applications -n $LAB_NAMESPACE
```

To list channels defined on hub cluster...

```shell
oc get channel -n $LAB_NAMESPACE
```

To list subscriptions defined on hub cluster...

```shell
oc get subscription.app.ibm.com -n $LAB_NAMESPACE
```

To list deployables defined on hub cluster...

```shell
oc get deployable -n $LAB_NAMESPACE
```

To check whether application is deployed on managed clusters...

Go to check the cluster provisioned by kind...

```shell
oc get ns --kubeconfig $HOME/.kube/${KIND_CLUSTER_NAME}
oc get pod -n $LAB_NAMESPACE --kubeconfig $HOME/.kube/${KIND_CLUSTER_NAME}
```

Go to check the cluster provisioned on AWS...

```shell
oc get ns --kubeconfig $HOME/.kube/${AWS_CLUSTER_NAME}
oc get pod -n $LAB_NAMESPACE --kubeconfig $HOME/.kube/${AWS_CLUSTER_NAME}
```

Finally, you should be able to see the nginx pod named as nginx-deployment-xxx-yyy both appeared on your local managed cluster provisioned by kind and the remote managed cluster running on AWS.

If you see that, it means you have successfully deployed the sample application from hub cluster to the two managed clusters in your hybrid environment.

Then you have finished all the tasks defined in this lab! Congratulations!
