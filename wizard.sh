#!/usr/bin/env bash

########################
# include the magic
########################
. ./demo-magic.sh
. ./lab-magic.sh
. ./utils.sh
. ./.lab.settings

# The Kubernetes namespace used for this lab
LAB_NAMESPACE="cp4mcm-lab"

# AWS settings
AWS_REGION=${AWS_REGION:-"us-east-2"}
AWS_CLUSTER_NAME=${AWS_CLUSTER_NAME:-"my-cluster-eks-$((1 + RANDOM % 100))"}

# kind settings
KIND_CLUSTER_NAME=${KIND_CLUSTER_NAME:-"my-cluster-kind"}

function task0 {
  i task0
  e task0 step1
  e task0 step2
}

function task0-step1 {
  i task0 step1

  p "# To install kind..."
  install-kind
  p "# To verify if kind is installed successfully..."
  pe "kind version"

  p "# To install AWS IAM Authenticator..."
  install-aws-iam-authenticator
  p "# To verify if AWS IAM Authenticator is installed successfully..."
  pe "aws-iam-authenticator version"

  p "# To install IBM Cloud Secure Gateway Client..."
  install-secure-gateway-client
  p "# To verify if IBM Cloud Secure Gateway Client is installed successfully..."
  pe "docker images ibmcom/secure-gateway-client"
}

function task0-step2 {
  i task0 step2

  p "# To monitor all CP4MCM pods status periodically..."
  wait-env-ready

  p "# Create a namespace called $LAB_NAMESPACE for this lab..."
  pe "oc create ns $LAB_NAMESPACE"
}

function task1 {
  i task1
  e task1 step1
  e task1 step2
  e task1 step3
}

function task1-step1 {
  i task1 step1
  i task1 step1.1
  i task1 step1.2
  i task1 step1.3
  i task1 step1.4
}

function task1-step2 {
  i task1 step2

  p "# Detect if Secure Gateway Client is running..."
  pe "docker ps | grep ibmcom/secure-gateway-client"

  if ! docker ps | grep ibmcom/secure-gateway-client >/dev/null 2>&1; then
    i task1 step2.1

    p "# To record the Gateway ID and Security Token..."
    a "Gateway ID" "GATEWAY_ID"
    a "Security Token" "GATEWAY_SECURITY_TOKEN"

    p "# Now, let's launch the client using the above inputs..."
    pe "docker run -d -p 9003:9003 ibmcom/secure-gateway-client $gateway_id -t $GATEWAY_SECURITY_TOKEN"
  else
    p "# Secure Gateway Client is running..."
  fi

  i task1 step2.2
}

function task1-step3 {
  i task1 step3
  i task1 step3.1

  local hostname_and_port

  p "# To input the public hostname and port..."
  a "The public hostname and port" "hostname_and_port"

  p "# Before update the hostname and port for your hub cluster, let's check the current API server host and port..."
  get-apiserver

  p "# You can test the API server connectivity using the current hostname and port..."
  pe "curl -kL https://`hostname`:8443"
  echo
  
  p "# You can also test the API server connectivity using the public hostname and port..."
  pe "curl -kL https://${hostname_and_port}"
  echo

  p "# Now, let's update the API server host and port..."
  set-apiserver $hostname_and_port

  p "# The current API server host and port have been changed as below..."
  get-apiserver
}

function task2 {
  i task2
  e task2 step1
  e task2 step2
  e task2 step3
  e task2 step4
}

function task2-step1 { 
  i task2 step1

  p "# To input your AWS access key ID and secret access key..."
  a "Input AWS access key ID" "AWS_ACCESS_KEY_ID"
  a "Input AWS secret access key" "AWS_SECRET_ACCESS_KEY"

  p "# Then encode them into base64 strings..."
  pe "printf $AWS_ACCESS_KEY_ID | base64"
  pe "printf $AWS_SECRET_ACCESS_KEY | base64"
}

function task2-step2 {
  i task2 step2

  p "# To input all the parameters that are required to provision your cluster on AWS..."
  a "Input cluster name" "AWS_CLUSTER_NAME"
  a "Input AWS region" "AWS_REGION"

  i task2 step2.1

  p "# Let's see how they look like..."
  p "cat samples/eks/apikey.yaml"
  cat samples/eks/apikey.yaml | \
    sed -e "s|{{AWS_ACCESS_KEY_ID}}|$(printf $AWS_ACCESS_KEY_ID | base64)|g" \
        -e "s|{{AWS_SECRET_ACCESS_KEY}}|$(printf $AWS_SECRET_ACCESS_KEY | base64)|g"

  p "cat samples/eks/cluster.yaml"
  cat samples/apps/subscription.yaml | \
    sed -e "s|{{AWS_CLUSTER_NAME}}|$AWS_CLUSTER_NAME|g" \
        -e "s|{{KIND_CLUSTER_NAME}}|$KIND_CLUSTER_NAME|g"

  p "# Now, let's start to provision the cluster on AWS by applying the above YAML files..."
  provision-eks $AWS_CLUSTER_NAME $AWS_REGION $AWS_ACCESS_KEY_ID $AWS_SECRET_ACCESS_KEY
}

function task2-step3 {
  i task2 step3

  p "# To track the progress on hub cluster, find the pod..."
  pe "oc -n $LAB_NAMESPACE get pod -l='job-name=${AWS_CLUSTER_NAME}-create'"

  local cluster_create_job=$(oc -n $LAB_NAMESPACE get pod -l="job-name=${AWS_CLUSTER_NAME}-create" | grep -e Running -e Completed -e ContainerCreating | awk '{print $1}')
  if [[ -n $cluster_create_job ]]; then
    p "# Then, check the progress by monitoring the running pod logs..."
    pe "oc -n $LAB_NAMESPACE logs $cluster_create_job"

    p "# You can also add -f option to keep monitoring the pod logs..."
    p "oc -n $LAB_NAMESPACE logs $cluster_create_job -f"
  else
    p "# Something wrong with the provision."
  fi

  p "# Please go to the next task or step until the cluster is provisioned."
  p "# Before that, you can use this step to keep traking the provision progress."
}

function task2-step4-before {
  p "# Detect if cluster ${AWS_CLUSTER_NAME} has been provisioned..."
  pe "oc get secret -n ${LAB_NAMESPACE} | grep ${AWS_CLUSTER_NAME}"
  oc get secret -n ${LAB_NAMESPACE} | grep ${AWS_CLUSTER_NAME} >/dev/null 2>&1 || return 1
}

function task2-step4 {
  i task2 step4

  p "# To get the cluster resource defined on hub cluster..."
  pe "oc get cluster.cluster.k8s.io ${AWS_CLUSTER_NAME} -n $LAB_NAMESPACE"

  p "# By describing the cluster resource, you can see a CreateClusterSuccessful event in the Event list when the cluster is created..."
  pe "oc describe cluster.cluster.k8s.io/${AWS_CLUSTER_NAME} -n $LAB_NAMESPACE"

  p "# To find the cluster secret..."
  pe "oc get secret -n $LAB_NAMESPACE | grep ${AWS_CLUSTER_NAME}"
  local cluster_secret=$(oc get secret -n $LAB_NAMESPACE -o name | grep ${AWS_CLUSTER_NAME})

  p "# To save as kubeconfig file into $HOME/.kube folder..."
  pe "oc get ${cluster_secret} -n $LAB_NAMESPACE -o 'go-template={{index .data \"kubeconfig-eks\"}}' | base64 --decode > $HOME/.kube/eks-kubeconfig"

  p "# See how the kubeconfig looks like..."
  pe "cat $HOME/.kube/eks-kubeconfig"

  p "# Now, you can use below commands to access the cluster which is running remotely on AWS EKS..."
  pe "oc get node --kubeconfig $HOME/.kube/eks-kubeconfig"
  pe "oc get pod --all-namespaces --kubeconfig $HOME/.kube/eks-kubeconfig"
}

function task3 {
  i task3
  e task3 step1
  e task3 step2
  e task3 step3
}

function task3-step1 {
  i task3 step1

  p "# To input the cluster name that you want to provision using kind..."
  a "Input cluster name" "KIND_CLUSTER_NAME"

  p "# Detect if cluster has been provisioned..."
  p "kind get clusters | grep ${KIND_CLUSTER_NAME}"
  if ! kind get clusters | grep ${KIND_CLUSTER_NAME} >/dev/null 2>&1; then
    p "# Let's use below config file to define the cluster..."
    p "# It is a cluster with one master node and two worker nodes."
    pe "cat samples/kind/config.yaml"

    p "# To provision the cluster, run kind command as below..."
    pe "kind create cluster --config samples/kind/config.yaml --kubeconfig $HOME/.kube/kind-kubeconfig --name ${KIND_CLUSTER_NAME}"

    p "# It also saves the kubeconfig file into $HOME/.kube folder."
    p "# See how the kubeconfig looks like..."
    pe "cat $HOME/.kube/kind-kubeconfig"
  else
    p "# Cluster has been provisioned."
  fi

  p "# Now, you can use below commands to access the cluster which is provisioned by kind..."
  pe "oc get node --kubeconfig $HOME/.kube/kind-kubeconfig"
  pe "oc get pod --all-namespaces --kubeconfig $HOME/.kube/kind-kubeconfig"
}

function task3-step2 {
  i task3 step2
  i task3 step2.1

  p "# To run the command against your cluster to be imported..."
  a "Paste the import command here" "KIND_IMPORT_COMMAND"

  local import_command=${KIND_IMPORT_COMMAND%|*}
  p "# Run the command by using the kubeconfig $HOME/.kube/kind-kubeconfig..."
  pe "${import_command}| oc apply --kubeconfig $HOME/.kube/kind-kubeconfig -f -"

  sleep 3
  eval "${import_command}| oc apply --kubeconfig $HOME/.kube/kind-kubeconfig -f - >/dev/null 2>&1"
}

function task3-step3 {
  i task3 step3

  p "# To monitor the pods status under multicluster-endpoint namespace..."
  pe "oc get pod -n multicluster-endpoint --kubeconfig $HOME/.kube/kind-kubeconfig"

  p "# Please go to the next task or step until the cluster is imported."
  p "# Before that, you can use this step to keep traking the import progress."
}

function task4-before {
  ! task2-step4-before && return 1

  p "# Detect if cluster ${KIND_CLUSTER_NAME} has been imported..."
  pe "oc get pod -n multicluster-endpoint --kubeconfig $HOME/.kube/kind-kubeconfig"
  pods_not_ready=`oc get pod -n multicluster-endpoint --kubeconfig $HOME/.kube/kind-kubeconfig | awk '{print $3}' | grep -v -e Running -e Completed -e STATUS`
  return [[ -n $pods_not_ready ]]
}

function task4 {
  i task4
  e task4 step1
  e task4 step2
  e task4 step3
  e task4 step4
  e task4 step5
}

function task4-step1 {
  i task4 step1

  p "# To define the application, let's use samples/apps/application.yaml..."
  p "# It indicates that any subscription with label \"app\" equal to \"lab-apps\" will match this application."
  pe "cat samples/apps/application.yaml"

  p "# Let's apply it to the hub cluster..."
  pe "oc apply -f samples/apps/application.yaml"
}

function task4-step2 {
  i task4 step2

  p "# To define the channel, let's use samples/apps/channel.yaml..."
  p "# It uses \"spec.type\" and \"spec.sourceNamespaces\" to specify the channel type and where it lives."
  pe "cat samples/apps/channel.yaml"

  p "# Let's apply it to the hub cluster..."
  pe "oc apply -f samples/apps/channel.yaml"
}

function task4-step3 {
  i task4 step3

  p "# To define the subscription, let's use samples/apps/subscription.yaml..."
  p "# It specifies the channel to be subscribed, and has label \"app\" equal to \"labs-app\", which matches the channel we defined."
  pe "cat samples/apps/subscription.yaml"

  p "# Let's apply it to the hub cluster..."
  p "oc apply -f samples/apps/subscription.yaml"
  cat samples/apps/subscription.yaml | \
    sed -e "s|{{AWS_CLUSTER_NAME}}|$AWS_CLUSTER_NAME|g" \
        -e "s|{{KIND_CLUSTER_NAME}}|$KIND_CLUSTER_NAME|g" | oc apply -n $LAB_NAMESPACE -f -
}

function task4-step4 {
  i task4 step4

  p "# To define the deployable, let's use samples/apps/deployable.yaml..."
  p "# It wraps nginx as a Kubernetes resource Delployment."
  pe "cat samples/apps/deployable.yaml"

  p "# Let's apply it to the hub cluster..."
  pe "oc apply -f samples/apps/deployable.yaml"
}

function task4-step5 {
  i task4 step5

  p "# To list applications defined on hub cluster..."
  pe "oc get applications -n $LAB_NAMESPACE"

  p "# To list channels defined on hub cluster..."
  pe "oc get channel -n $LAB_NAMESPACE"

  p "# To list subscriptions defined on hub cluster..."
  pe "oc get subscription.app.ibm.com -n $LAB_NAMESPACE"

  p "# To list deployables defined on hub cluster..."
  pe "oc get deployable -n $LAB_NAMESPACE"

  p "# To check whether application is deployed on managed clusters..."
  p "# Go to check the cluster provisioned by kind..."
  pe "oc get ns --kubeconfig $HOME/.kube/kind-kubeconfig"
  pe "oc get pod -n $LAB_NAMESPACE --kubeconfig $HOME/.kube/kind-kubeconfig"

  p "# Go to check the cluster provisioned on AWS..."
  pe "oc get ns --kubeconfig $HOME/.kube/eks-kubeconfig"
  pe "oc get pod -n $LAB_NAMESPACE --kubeconfig $HOME/.kube/eks-kubeconfig"
}

e "$@"
