#!/bin/bash

function logger::info {
  # Cyan
  printf "\033[0;36mINFO\033[0m $@\n"
}

function logger::warn {
  # Yellow
  printf "\033[0;33mWARN\033[0m $@\n"
}

function logger::error {
  # Red
  printf "\033[0;31mERRO\033[0m $@\n"
  exit 1
}

trap on_exit exit

function on_exit {
  elapsed_time=$(($SECONDS - $start_time))
  logger::info "Total elapsed time: $elapsed_time seconds"
}

function prompt_required {
  prompt "$@"
  while [[ -z $(eval echo \$$2) ]]; do
    prompt "$@"
  done
}

function prompt {
  echo -n -e "\033[0;36m? \033[0;37m$1\033[0m"

  local sample=$(eval echo \$$2)
  if [[ -n $sample ]]; then
    echo -n -e "($sample): "
  else
    echo -n -e ": "
  fi

  local input
  read -r input
  if [[ -n $input ]]; then
    eval $2=\'$input\'
  else
    return 1
  fi
}

function wait-env-ready {
  oc login -u admin -p Passw0rd! -n kube-system 2>&1 >/dev/null

  logger::info "Waiting IBM CloudPak for Multicloud Management up and running..."

  local pods_not_ready="Pending"
  local num_tries=200
  while [[ -n $pods_not_ready ]]; do
    pods_not_ready=`oc get pods -n kube-system | grep -v -e ibmcloudappmgmt -e import-job | awk '{print $3}' | grep -v -e Running -e Completed -e STATUS`
    if ((--num_tries == 0)); then
      logger::error "Error bringing up IBM CloudPak for Multicloud Management"
      exit 1
    fi
    echo -n "." >&2
    sleep 5
  done
  echo "[done]" >&2
}

function install-kind {
  logger::info "Install kind..."

  if ! command -v kind >/dev/null 2>&1; then
    curl -Lo ./kind https://github.com/kubernetes-sigs/kind/releases/download/v0.7.0/kind-$(uname)-amd64
    chmod +x ./kind
    mkdir -p $HOME/.local/bin
    mv ./kind $HOME/.local/bin/kind
    # kind version
    logger::info "kind installed finished"
  else
    logger::info "kind has been installed"
  fi
}

function install-secure-gateway-client {
  logger::info "Install IBM Cloud Secure Gateway Client (Docker image)..."

  if [[ "$(docker images -q ibmcom/secure-gateway-client 2> /dev/null)" == "" ]]; then
    docker pull ibmcom/secure-gateway-client
    logger::info "Image ibmcom/secure-gateway-client download finished"
  else
    logger::info "Image already exists: ibmcom/secure-gateway-client"
  fi
}

function install-aws-iam-authenticator {
  logger::info "Install aws-iam-authenticator..."

  if ! command -v aws-iam-authenticator >/dev/null 2>&1; then
    curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.15.10/2020-02-22/bin/linux/amd64/aws-iam-authenticator
    chmod +x ./aws-iam-authenticator
    mkdir -p $HOME/.local/bin
    mv ./aws-iam-authenticator $HOME/.local/bin/aws-iam-authenticator
    # aws-iam-authenticator version
    logger::info "aws-iam-authenticator installed finished"
  else
    logger::info "aws-iam-authenticator has been installed"
  fi
}

function get-apiserver {
  local host=$(oc get cm ibmcloud-cluster-info -n kube-public -o='jsonpath={.data.cluster_kube_apiserver_host}')
  local port=$(oc get cm ibmcloud-cluster-info -n kube-public -o='jsonpath={.data.cluster_kube_apiserver_port}')
  logger::info "$host:$port"
}

function set-apiserver {
  local host=${1%:*}
  local port=${1#*:}

  logger::info "Updating configmap/ibmcloud-cluster-info..."
  local current_host=$(oc get cm ibmcloud-cluster-info -n kube-public -o='jsonpath={.data.cluster_kube_apiserver_host}')
  local current_port=$(oc get cm ibmcloud-cluster-info -n kube-public -o='jsonpath={.data.cluster_kube_apiserver_port}')
  if [[ -n $host && $current_host != $host ]]; then
    logger::info "Updating cluster_kube_apiserver_host from $current_host to $host..."
    echo "{\"data\":{\"cluster_kube_apiserver_host\":\"$host\"}}" | oc patch -n kube-public cm ibmcloud-cluster-info -p $(cat -)
  fi
  if [[ -n $port && $current_port != $port ]]; then
    logger::info "Updating cluster_kube_apiserver_port from $current_port to $port..."
    echo "{\"data\":{\"cluster_kube_apiserver_port\":\"$port\"}}" | oc patch -n kube-public cm ibmcloud-cluster-info -p $(cat -)
  fi
}

function provision-eks {
  local cluster_name=${1:-"my-cluster-eks"}
  local aws_region=${2:-"us-east-2"}
  local aws_access_key_id=$(printf $3 | base64)
  local aws_secret_access_key=$(printf $4 | base64)

  logger::info "Apply apikey.yaml..."
  cat samples/eks/apikey.yaml | \
    sed -e "s|{{AWS_ACCESS_KEY_ID}}|$aws_access_key_id|g" \
        -e "s|{{AWS_SECRET_ACCESS_KEY}}|$aws_secret_access_key|g" | oc apply -n cp4mcm-lab -f -
  logger::info "Apply cluster.yaml..."
  cat samples/eks/cluster.yaml | \
    sed -e "s|{{CLUSTER_NAME}}|$cluster_name|g" \
      -e "s|{{AWS_REGION}}|$aws_region|g" | oc apply -n cp4mcm-lab -f -
}

function cluster-create-job-logs {
  local cluster_name=${1:-"my-cluster-eks"}
  local cluster_create_job=$(oc -n cp4mcm-lab get pod -l="job-name=${cluster_name}-create" -o name)
  oc -n cp4mcm-lab logs $cluster_create_job
}

function get-eks-kubeconfig {
  local cluster_name=${1:-"my-cluster-eks"}
  local cluster_secret=$(oc get secret -n cp4mcm-lab -o name | grep ${cluster_name})
  oc get ${cluster_secret} -n cp4mcm-lab -o 'go-template={{index .data "kubeconfig-eks"}}' | base64 --decode | tee $HOME/.kube/eks-kubeconfig
}

start_time=$SECONDS
