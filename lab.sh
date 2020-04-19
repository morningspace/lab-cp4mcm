#!/usr/bin/env bash

########################
# include the magic
########################
. ./demo-magic.sh
. ./labs-magic.sh
. ./.lab.settings

# The Kubernetes namespace used for this lab
LAB_NAMESPACE="cp4mcm-lab"

# AWS settings
AWS_REGION=${AWS_REGION:-"us-east-2"}
AWS_CLUSTER_NAME=${AWS_CLUSTER_NAME:-"my-cluster-eks-$((1 + RANDOM % 100))"}

# kind settings
KIND_CLUSTER_NAME=${KIND_CLUSTER_NAME:-"my-cluster-kind"}

function wait-env-ready {
  oc login -u admin -p Passw0rd! -n kube-system 2>&1 >/dev/null

  logger::info "Waiting IBM CloudPak for Multicloud Management up and running..."

  local pods_not_ready="Pending"
  local num_tries=200
  while [[ -n $pods_not_ready ]]; do
    pods_not_ready=`oc get pods -n kube-system | grep -v -e ibmcloudappmgmt -e import-job | awk '{print $3}' | grep -v -e Running -e Completed -e STATUS -e MatchNodeSelector`
    if ((--num_tries == 0)); then
      logger::error "Error bringing up IBM CloudPak for Multicloud Management"
      exit 1
    fi
    echo -n "." >&2
    sleep 5
  done
  echo "[done]" >&2
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

function task1::step2::before {
  logger::info "Detect if Secure Gateway Client is running..."
  if docker ps | grep ibmcom/secure-gateway-client >/dev/null 2>&1; then
    logger::info "Secure Gateway Client is running..."
    return 1
  fi
}

task::main "$@"
