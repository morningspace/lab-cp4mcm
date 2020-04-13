# Task 1: Configure hub cluster to be publicly accessible

  Instructions
  ============

  In this task, we will leverage IBM Cloud Secure Gateway to expose your local network to the internet, where
  the hub cluster is running so that clusters run on AWS can connect back to the hub cluster from the internet.
  This is required for hub cluster to manage your clusters provisioned by AWS EKS.

  Steps:

  1) Configure Secure Gateway on IBM Cloud
  2) Launch and configure Secure Gateway Client from localhost
  3) Configure and test API server host and port on hub cluster

  Estimated time to complete: 10 min
