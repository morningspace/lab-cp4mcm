# Task 4 - Step 3: Define and apply a subscription

Instructions
============

Subscription can point to a channel for identifying new and updated Kubernetes resources for deployment.

As an example, in this lab, we will define subscription that matches the application and channel we defined.
It also defines where we want the applications to be deployed.

---

To define the subscription, let's use samples/apps/subscription.yaml.

It specifies the channel to be subscribed, and has label "app" equal to "labs-app", which matches the channel we defined.

```shell
cat samples/apps/subscription.yaml
```

Let's apply it to the hub cluster...

```shell
cat samples/apps/subscription.yaml | sed -e "s|{{AWS_CLUSTER_NAME}}|$AWS_CLUSTER_NAME|g" -e "s|{{KIND_CLUSTER_NAME}}|$KIND_CLUSTER_NAME|g" -e "s|{{LAB_NAMESPACE}}|$LAB_NAMESPACE|g" | oc apply -n $LAB_NAMESPACE -f -
```