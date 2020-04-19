# Task 0 - Step 1: Install required software

Instructions
============

This lab requires below software to be installed on your machine:

1) kind: Used to provision a local cluster. Please refer to below link for detail information:
   https://kind.sigs.k8s.io/
2) AWS IAM Authenticator: Used to connect your cluster hosted on AWS. Please refer to below link for detail information.
   https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html
3) IBM Cloud Secure Gateway Client: Used to expose your local network to the internet. Please refer to below link for detail information.
   https://cloud.ibm.com/docs/services/SecureGateway/

---

## Install kind

Make sure $HOME/.local/bin exists and included in $PATH.

```shell
mkdir -p $HOME/.local/bin
```

Then run below commands to install kind:

```shell
curl -Lo ./kind https://github.com/kubernetes-sigs/kind/releases/download/v0.7.0/kind-$(uname)-amd64
chmod +x ./kind
mv ./kind $HOME/.local/bin/kind
```

To verify if kind is installed successfully:

```shell
kind version
```

## Install AWS IAM Authenticator

To install AWS IAM Authenticator:

```shell
curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.15.10/2020-02-22/bin/linux/amd64/aws-iam-authenticator
chmod +x ./aws-iam-authenticator
mv ./aws-iam-authenticator $HOME/.local/bin/aws-iam-authenticator
```

To verify if AWS IAM Authenticator is installed successfully:

```shell
aws-iam-authenticator version
```

## Install IBM Cloud Secure Gateway Client

To install IBM Cloud Secure Gateway Client:

```shell
docker pull ibmcom/secure-gateway-client
```

To verify if IBM Cloud Secure Gateway Client is installed successfully:

```shell
docker images ibmcom/secure-gateway-client
```
