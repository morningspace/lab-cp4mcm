# Task 0 - Step 2: Wait for CP4MCM up and running

Instructions
============

To wait for CP4MCM up and running, let's monitor all CP4MCM pods status periodically. Usually, it takes 5 to
10 minutes to finish.

---

To monitor all CP4MCM pods status periodically, login as admin using `oc` first...

```shell
oc login -u ${OCP_USER} -p ${OCP_PASSWORD} -n kube-system
```

Then check the pods status as below:

```shell
oc get pods -n kube-system | grep -v -e ibmcloudappmgmt -e import-job
```

Now, let's wait for all pods ready...
<!--
wait-env-ready
-->

Finally, create a namespace called $LAB_NAMESPACE for this lab...

```shell
oc create ns $LAB_NAMESPACE
```
<!--
var::save "LAB_NAMESPACE"
-->
