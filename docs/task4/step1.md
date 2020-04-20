# Task 4 - Step 1: Define and apply an application

Instructions
============

CP4MCM provides enhanced application management capabilities through a Kubernetes resource-based application
model and channel/subscription-based deployment options. Applications are composed of multiple resources and
defined in YAML.

As an example, in this lab, we will define nginx as an application and deploy it to managed clusters through
the channel, subscription mechanism.

In the application definition YAML, it includes "spec.componentKinds" to indicate that the application uses a 
subscription, and "spec.selector" to define the labels used to match the application with the subscription.

---

To define the application, let's use samples/apps/application.yaml.

It indicates that any subscription with label "app" equal to "lab-apps" will match this application.

```shell
cat samples/apps/application.yaml
```

Let's apply it to the hub cluster...

```shell
cat samples/apps/application.yaml | sed -e "s|{{LAB_NAMESPACE}}|$LAB_NAMESPACE|g" | oc apply -n $LAB_NAMESPACE -f -
```
