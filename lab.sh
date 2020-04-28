#!/usr/bin/env bash

########################
# include the magic
########################
. ./labs-magic.sh
. ./lab.config
. $LAB_CONFIG_FILE

# speed at which to simulate typing. bigger num = faster
TYPE_SPEED=

# The Kubernetes namespace used for this lab
LAB_NAMESPACE="lab-cp4mcm-${LAB_PROFILE}"

# AWS settings
AWS_REGION=${AWS_REGION:-"us-east-1"}
AWS_CLUSTER_NAME=${AWS_CLUSTER_NAME:-"my-cluster-eks-$((1 + RANDOM % 100))"}

# kind settings
KIND_CLUSTER_NAME=${KIND_CLUSTER_NAME:-"my-cluster-kind-$((1 + RANDOM % 100))"}

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

# function task1::step2::before {
#   logger::info "Detect if Secure Gateway Client is running..."
#   if docker ps | grep ibmcom/secure-gateway-client >/dev/null 2>&1; then
#     logger::info "Secure Gateway Client is running..."
#     return 1
#   else
#     logger::info "Secure Gateway Client is not running..."
#     return 0
#   fi
# }

function task2::step4::before {
  logger::info "Detect if cluster ${AWS_CLUSTER_NAME} has been provisioned..."
  if oc get secret -n ${LAB_NAMESPACE} | grep ${AWS_CLUSTER_NAME} >/dev/null 2>&1; then
    logger::info "Cluster has been provisioned."
    return 0
  else
    logger::info "Cluster has not been provisioned."
    return 1
  fi
}

function task3::step1::before {
  logger::info "Detect if cluster ${KIND_CLUSTER_NAME} has been provisioned..."
  if kind get clusters | grep ${KIND_CLUSTER_NAME} >/dev/null 2>&1; then
    logger::info "Cluster has been provisioned."
    return 1
  else
    logger::info "Cluster has not been provisioned."
    return 0
  fi
}

function task4::before {
  task2::step4::before || return 1

  logger::info "Detect if cluster ${KIND_CLUSTER_NAME} has been imported..."
  if [[ -n `oc get pod -n multicluster-endpoint --kubeconfig $HOME/.kube/${KIND_CLUSTER_NAME} | awk '{print $3}' | grep -v -e Running -e Completed -e STATUS` ]]; then
    logger::info "Cluster has not been imported."
    return 1
  else
    logger::info "Cluster has been imported."
    return 0
  fi
}

task::main "$@"
