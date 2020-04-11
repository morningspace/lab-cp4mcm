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

if [[ $# -gt 0 ]]; then
  if type $1 &>/dev/null ; then
    "$@"
  else
    logger::warn "Unknown command"
  fi
else
  logger::warn "Unknown command"
fi
