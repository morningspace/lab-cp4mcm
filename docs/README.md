# IBM Cloud Pak for Multicloud Management: All-in-One Playground to Manage Your Hybrid Cloud

Introduction
============

This lab will walk you through the steps to use IBM Cloud Pak for Multicloud Management (CP4MCM) to manage a
local cluster which is provisioned using kind and a remote cluster which is provisioned using AWS EKS, then
deploy a sample application from hub cluster to the two managed clusters. This gives you a better view of how
CP4MCM can manage clusters and applications in a hybrid environment efficiently.

The lab also demonstrates the way to use IBM Cloud Secure Gateway to establish connections between hub cluster
deployed in private network and managed cluster deployed on internet.

![Figure: The Lab Architecture](images/lab-architecture.png)
  
Tasks
=====

- [Task 0: Prepare environment](task0/)
- [Task 1: Configure hub cluster to be publicly accessible](task1/)
- [Task 2: Manage a cluster provisioned by AWS EKS](task2/)
- [Task 3: Manage a cluster provisioned by kind](task3/)
- [Task 4: Deploy your first application through CP4MCM](task4/)

Estimated time to complete: 60 min

See Also
========

Online version of lab instructions: https://github.com/morningspace/lab-cp4mcm/tree/master/docs

