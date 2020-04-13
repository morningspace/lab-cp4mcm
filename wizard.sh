#!/usr/bin/env bash

########################
# include the magic
########################
. ./demo-magic.sh
. ./utils.sh
. ./conf.sh

########################
# Configure the options
########################

#
# speed at which to simulate typing. bigger num = faster
#
TYPE_SPEED=100

#
# custom prompt
#
# see http://www.tldp.org/HOWTO/Bash-Prompt-HOWTO/bash-prompt-escape-sequences.html for escape sequences
#
DEMO_PROMPT="${GREEN}➜ ${CYAN}\W "

#
# custom colors
#
DEMO_CMD_COLOR="\033[0;37m"
DEMO_COMMENT_COLOR=$CYAN

trap on_exit exit

function on_exit {
  elapsed_time=$(($SECONDS - $start_time))
  logger::info "Total elapsed time: $elapsed_time seconds"
}

# hide the evidence
clear

# put your demo awesomeness here
function lab-instructions {
  p "# Welcom to \"Lab for IBM CloudPak for Multicloud Management\""

  cat << EOF

  Instructions
  ============

  In this lab, I will walk you through the steps on how to use IBM CloudPak for Multicloud Management (CP4MCM)
  to manage a local cluster provisioned using kind and a remote cluster provisioned by AWS EKS, then publish a
  sample application from hub cluster to the two managed clusters, to give you a better view of how CP4MCM can
  manage clusters and applications in a hybrid environment.

  Tasks:

  0) Prepare environment
  1) Configure hub cluster to be publicly accessible
  2) Manage a cluster provisoned by AWS EKS
  3) Manage a cluster provisoned by kind
  4) Deploy your first application through CP4MCM

  Estimated time to complete: 60 min

EOF
}

function task0 {
  p "# Task 0: Prepare environment"

  cat << EOF

  Instructions
  ============

  In this task, we will install all the softwares that are required in this lab, then wait for CP4MCM to be up
  and runing.
  
  Steps:

  1) Install required softwares
  2) Wait for CP4MCM up and running
  
  Estimated time to complete: 5 min

EOF

  task0-step1
  task0-step2
}

function task0-step1 {
  p "# Task 0 - Step 1: Install required softwares"

  cat << EOF

  Instructions
  ============

  This lab requires below softwares to be installed on your machine:

  1) kind: Used to provision a local cluster. Please refer to below link for detail information:
     https://kind.sigs.k8s.io/
  2) AWS IAM Authenticator: Used to connect your cluster hosted on AWS. Please refer to below link for detail information.
     https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html
  3) IBM Cloud Secure Gateway Client: Used to expose your local network to the internet. Please refer to below link for detail information.
     https://cloud.ibm.com/docs/services/SecureGateway/

EOF

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
  p "# Task 0 - Step 1: Wait for CP4MCM up and running"

  cat << EOF

  Instructions
  ============

  To wait for CP4MCM up and running, let's monitor all CP4MCM pods status periodically. Usually, it takes 5 to
  10 minutes to finish.

EOF

  p "# To monitor all CP4MCM pods status periodically..."
  wait-env-ready

  p "# Create a namespace called $LAB_NAMESPACE for this lab..."
  pe "oc create ns $LAB_NAMESPACE"
}

function task1 {
  p "# Task 1: Configure hub cluster to be publicly accessible"

  cat << EOF

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

EOF

  task1-step1
  task1-step2
  task1-step3
}

function task1-step1 {
  p "# Task 1 - Step 1: Configure Secure Gateway on IBM Cloud"

  cat << EOF

  Instructions
  ============

  Please refer to below link to learn detail information to configure Secure Gateway using IBM Cloud account:
  https://cloud.ibm.com/docs/services/SecureGateway?topic=securegateway-getting-started-with-sg&locale=en#getting-started-with-sg

  In general, you may need to:

  1) Login to IBM Cloud using your IBM Cloud account
  2) Create a Secure Gateway resource
  3) Add a gateway
  4) Add a destination

EOF

  p "# To login to IBM Cloud using your IBM Cloud account..."
  cat << EOF

  Log in to IBM Cloud: https://cloud.ibm.com/. Please contact lab owner if you do not have an account yet.

EOF

  p "# To create a Secure Gateway resource..."
  cat << EOF

  Go to https://cloud.ibm.com/catalog, search by using keywords "Secure Gateway", you can see a service called
  "Secure Gateway" listed in the search results. Click this service and go to its details page, then click the 
  "Create" button. The resource will be created then.

EOF

  p "# To add a gateway..."

  cat << EOF

  On the "Secure Gateway Dashboard" page, click the plus icon to add a gateway. Give your gateway a name, e.g.
  my-cp4mcm-gateway, and leave all the other fields without change.

EOF

  p "# To add a destination..."

  cat << EOF

  On the "Secure Gateway Dashboard" page, click the gateway that we created just now, then click the plus icon
  to add a destination for your gateway. Answer the questions on the dialog wizard with below suggested values
  one by one:

  1) Where is your resource located? On-Premises
  2) What is the host and port of your destination? 
     Resource Hostname: `hostname`
     Resource Port: 8443
  3) What protocol will the User/Application use to connect to your destination? TCP
  4) What kind of authentication does your destination enforce? None
  5) What would you like to name this destination? e.g. my-cp4mcm-destination

EOF
}

function task1-step2 {
  p "# Task 1 - Step 2: Launch and configure Secure Gateway Client from localhost"

  cat << EOF

  Instructions
  ============

  Please refer to below link to learn details on how to configure Secure Gateway using your IBM Cloud account:
  https://cloud.ibm.com/docs/services/SecureGateway?topic=securegateway-getting-started-with-sg&locale=en#getting-started-with-sg

  In general, you may need to:

  1) Launch Secure Gateway Client if not exists
  2) Config Secure Gateway ACL for hub cluster

EOF

  p "# Try to detect if Secure Gateway Client exists..."
  pe "docker ps | grep ibmcom/secure-gateway-client"

  if ! docker ps | grep ibmcom/secure-gateway-client >/dev/null 2>&1; then
    p "# To launch Secure Gateway Client..."

    cat << EOF

  On the "Secure Gateway Dashboard" page, click the gateway that we created, click the Clients tab, then click
  the Connect Client button. On the dialog, copy the Gateway ID and Security Token that will be used to launch
  the Secure Gateway Client

EOF

    local gateway_id
    local security_token

    p "# To record the Gateway ID and Security Token..."
    prompt_required "Gateway ID" "gateway_id"
    prompt_required "Security Token" "security_token"

    p "# Now, let's launch the client using the above inputs..."
    pe "docker run -d -p 9003:9003 ibmcom/secure-gateway-client $gateway_id -t $security_token"
  else
    p "# Secure Gateway Client is running..."
  fi

  p "# To config Secure Gateway ACL for hub cluster..."

  cat << EOF

  Secure Gateway Client has a dashboard which can be used to manage connections. We will use this dashboard to
  config ACL for our hub cluster. Go to: http://127.0.0.1:9003 in web browser, click the "Access Control List"
  button, in the "Allow access" section, input:

  1) Resource Hostname: `hostname`
  2) Port: 8443

  Then click the plus icon. It allows the hub cluster deployed in your local network to be accessible from the
  internet.

EOF
}

function task1-step3 {
  p "# Task 1 - Step 3: Configure and test API server host and port on hub cluster"

  cat << EOF

  Instructions
  ============

  After you expose your hub cluster to the internet, the default API server host and port on hub cluster need
  to be updated accordingly to reflect the change.

  You may need to:

  1) Find the public hostname and port for your hub cluster from IBM Cloud Secure Gateway
  2) Test API server connectivity using public hostname and port
  3) Update the hostname and port for your hub cluster

EOF

  p "# To find the public hostname and port for your hub cluster from IBM Cloud Secure Gateway..."

  cat << EOF

  On the "Secure Gateway Dashboard" page, click the gateway that you have created, then click the gear icon of
  the destination. On the popup dialog, copy the value of "Cloud Host : Port" field for later use.

EOF

  local hostname_and_port

  p "# To input the public hostname and port..."
  prompt_required "The public hostname and port" "hostname_and_port"

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
  p "# Task 2: Manage a cluster provisoned by AWS EKS"

  cat << EOF

  Instructions
  ============

  In this task, we will ask CP4MCM to auto-provision a cluster on AWS EKS for us.

  Steps:

  1) Get your AWS access key ID and secret access key
  2) Apply apikey.yaml and cluster.yaml to kick off the provision
  3) Track progress until the provission is finished
  4) Get the cluster secret to access the provisioned cluster

  Estimated time to complete: 15 min

EOF

  task2-step1
  task2-step2
  task2-step3
  task2-step4
}

function task2-step1 { 
  p "# Task 2 - Step 1: Get your AWS access key ID and secret access key"

  cat << EOF

  Instructions
  ============

  Login to Amazon Console https://console.aws.amazon.com/ using your Amazon account. Click the user account on
  top navigation bar, and choose "My Security Credentials". Click the "Create access key" button to generate a
  new access key ID and a secret access key for you. Record the two values for later use.

EOF

  p "# To input your AWS access key ID and secret access key..."
  prompt_required "Input AWS access key ID" "AWS_ACCESS_KEY_ID"
  prompt_required "Input AWS secret access key" "AWS_SECRET_ACCESS_KEY"

  p "# Then encode them into base64 strings..."
  pe "printf $AWS_ACCESS_KEY_ID | base64"
  pe "printf $AWS_SECRET_ACCESS_KEY | base64"
}

function task2-step2 {
  p "# Task 2 - Step 2: Apply apikey.yaml and cluster.yaml to kick off the provision"

  cat << EOF

  Instructions
  ============

  Define the cluster name and the region on AWS where you want to provision your cluster. Fill in the two YAML
  files: "apikey.yaml" and "cluster.yaml", which are required to provision the cluster with these values along
  with the base64 encoded access key ID and secret access key.

  Then apply the above YAML files on the hub cluster to kick off the provision. Usually, it takes more than 10
  minutes to finish. As it essentially invokes AWS EKS, it depends on how fast AWS EKS provisions a cluster.

EOF

  p "# To input all the parameters that are required to provision your cluster on AWS..."
  prompt_required "Input cluster name" "AWS_CLUSTER_NAME"
  prompt_required "Input AWS region" "AWS_REGION"

  p "# Now, use these values to populate the two YAML files."
  cat << EOF

  1) samples/eks/apikey.yaml: Used to create the secret for AWS accesss.
  2) samples/eks/clusters.yaml: Used to define how the cluster will look like.

EOF

  p "# Let's see how they look like..."
  pe "cat samples/eks/apikey.yaml"
  pe "cat samples/eks/cluster.yaml"

  p "# Now, let's start to provision the cluster on AWS by applying the above YAML files..."
  provision-eks $AWS_CLUSTER_NAME $AWS_REGION $AWS_ACCESS_KEY_ID $AWS_SECRET_ACCESS_KEY
}

function task2-step3 {
  p "# Task 2 - Step 3: Track progress until the provission is finished"

  cat << EOF

  Instructions
  ============

  During the provision, you can track the progress either on hub cluster or on AWS.

  1) On hub cluster, you can monitor the logs of the pod created for the provision job.
  2) On AWS, go to the link: https://console.aws.amazon.com/cloudformation. From the "Stacks" page, choose the
     right stack by the cluster name being used to provision your cluster, then go to its "Events" tab to find
     the progress.

EOF

  p "# To track the progress on hub cluster, find the pod..."
  pe "oc -n $LAB_NAMESPACE get pod -l='job-name=${AWS_CLUSTER_NAME}-create'"

  local cluster_create_job=$(oc -n $LAB_NAMESPACE get pod -l="job-name=${AWS_CLUSTER_NAME}-create" | grep -e Running -e Completed | awk '{print $1}')
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
  exit
}

function task2-step4 {
  p "# Task 2 - Step 4: Get the cluster secret to access the provisioned cluster"

  cat << EOF

  Instructions
  ============

  After the cluster is provisioned, you can get the cluster secret and saved as a kubeconfig file which can be
  used to access the cluster.

  You can also go to CP4MCM UI on the hub cluster via below link to check the cluster status. Find the cluster
  from the cluster list, then click it to go to the details page:
  $CP4MCM_BASE_URL/multicloud/clusters

EOF

  p "# Try to detect if cluster has been provisioned..."
  pe "oc get secret -n $LAB_NAMESPACE | grep ${AWS_CLUSTER_NAME}"

  if oc get secret -n $LAB_NAMESPACE | grep ${AWS_CLUSTER_NAME} >/dev/null 2>&1; then
    p "# Cluster has been provisioned successfully, let's continue..."

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
  else
    p "# Cluster has not been provisioned yet, please try again later..."
  fi
}

function task3 {
  p "# Task 3: Manage a cluster provisoned by kind"

  cat << EOF

  Instructions
  ============

  In this task, we will provision a cluster by using kind in the same local network along with the hub cluster
  and import it into hub cluster as a managed cluster so that can be managed by the hub cluster.

  Steps:

  1) Provision a local cluster using kind.
  2) Generate the cluster import command from CP4MCM UI and run it.
  3) Track progress until the import is finished

  Estimated time to complete: 10 min

EOF

  task3-step1
  task3-step2
  task3-step3
}

function task3-step1 {
  p "# Task 3 - Step 1: Provision a local cluster using kind"

  cat << EOF

  Instructions
  ============

  To provision a cluster using kind is very easy. Just tell kind how the cluster will look like by defining a 
  config file. Then run kind command to provision the cluster. Usually, it takes 1 or 2 minutes to finish.

EOF

  p "# To input the cluster name that you want to provision using kind..."
  prompt_required "Input cluster name" "KIND_CLUSTER_NAME"

  p "# Try to detect if cluster has been provisioned..."
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
  p "# Task 3 - Step 2: Generate the cluster import command from CP4MCM UI and run it"

  cat << EOF

  Instructions
  ============

  To import an existing cluster into hub cluster, you can go to CP4MCM UI to generate the import command, then
  run the command against your cluster to be imported. To import a local cluster launced by kind is very fast.
  Usually, it takes a few minutes to finish.
  
EOF

  p "# To generate the import cluster command from CP4MCM UI..."
  cat << EOF

  Open below link in your web browser:
  $CP4MCM_BASE_URL/multicloud/clusters

  On the cluster list page, click the "Add cluster" button to open the popup dialog. Choose the option "Import
  an existing cluster by running a command on your cluster", then click the "Select" button. On the next page,
  input the name of your cluster that is going to be imported, e.g. ${KIND_CLUSTER_NAME}, leave all the other fields
  without change, then click the "Generate command" button to generate the command and copy it for later use.

EOF

  local import_command
  p "# To run the command against your cluster to be imported..."
  prompt_required "Paste the import command here" "import_command"

  import_command=${import_command%|*}
  p "# Run the command by using the kubeconfig $HOME/.kube/kind-kubeconfig..."
  pe "${import_command}| oc apply --kubeconfig $HOME/.kube/kind-kubeconfig -f -"
  eval "${import_command}| oc apply --kubeconfig $HOME/.kube/kind-kubeconfig -f -"
}

function task3-step3 {
  p "# Task 3 - Step 3: Track progress until the import is finished"

  cat << EOF

  Instructions
  ============

  During the import process, you can track the progress by monitoring the pods status under a namespace called
  multicluster-endpoint on the cluster being imported. When all pods are up and running, the import process is
  finished.

  You can also go to CP4MCM UI via below link to check the cluster status:
  $CP4MCM_BASE_URL/multicloud/clusters

EOF

  p "# To monitor the pods status under multicluster-endpoint namespace..."
  pe "oc get pod -n multicluster-endpoint --kubeconfig $HOME/.kube/kind-kubeconfig"

  p "# Please go to the next task or step until the cluster is imported."
  p "# Before that, you can use this step to keep traking the import progress."
  exit
}

function task4 {
  p "# Task 4: Deploy your first application through CP4MCM"

  cat << EOF

  Instructions
  ============

  In this task, we will deploy nginx as a sample application from hub cluster to the clusters that are managed
  by the hub cluster using its application model via channel, subscription mechanism. We will use the clusters
  that are provisioned.

  Steps:

  1) Define and apply an application
  2) Define and apply a channel
  3) Define and apply a subscription
  4) Define and apply a deployable
  5) Check results

  Estimated time to complete: 15 min

EOF

  task4-step1
  task4-step2
  task4-step3
  task4-step4
  task4-step5
}

function task4-step1 {
  p "# Task 4 - Step 1: Define and apply an application"

  cat << EOF

  Instructions
  ============

  CP4MCM provides enhanced application management capabilities through a Kubernetes resource based application
  model and channel/subscription based deployment options. Applications are composed of multiple resources and
  defined in YAML.

  As an example, in this lab, we will define nginx as an application and deploy it to managed clusters through
  the channel, subscription mechanism.

  In the application definition YAML, it includes "spec.componentKinds" to indicate that the application uses a 
  subscription, and "spec.selector" to define the labels used to match the application with the subscription.

EOF

  p "# To define the application, let's use samples/apps/application.yaml..."
  p "# It indicates that any subscription with label \"app\" equal to \"lab-apps\" will match this application."
  pe "cat samples/apps/application.yaml"

  p "# Let's apply it to the hub cluster..."
  pe "oc apply -f samples/apps/application.yaml"
}

function task4-step2 {
  p "# Task 4 - Step 2: Define and apply a channel"

  cat << EOF

  Instructions
  ============

  Channel is a custom resource that can help you streamline deployments and separate cluster access. It defines
  namespace on hub cluster and point to physical place where resources are stored for deployment.
  
  There're a few types of channels. In this lab, we will use Namespace channel to monitor a specified namespace
  which is used to maintain custom resources called Deployables. Deployables added or updated in this namespace
  will be promoted to managed clusters through the channel.

EOF

  p "# To define the channel, let's use samples/apps/channel.yaml..."
  p "# It uses \"spec.type\" and \"spec.sourceNamespaces\" to specify the channel type and where it lives."
  pe "cat samples/apps/channel.yaml"

  p "# Let's apply it to the hub cluster..."
  pe "oc apply -f samples/apps/channel.yaml"
}

function task4-step3 {
  p "# Task 4 - Step 3: Define and apply a subscription"

  cat << EOF

  Instructions
  ============

  Subscription can point to a channel for identifying new and updated Kubernetes resources for deployment.

  As an example, in this lab, we will define subscription that matches the application and channel we defined.
  It also defines where we want the applications to be deployed.

EOF

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
  p "# Task 4 - Step 4: Define and apply a deployable"

  cat << EOF

  Instructions
  ============

  Deployables are resources that wrap or represent other resources to prevent them from being deployed on hub 
  cluster before the resources are placed on managed clusters. Deployables can be directly deployed to one or
  more managed clusters from the storage locations that include the deployables.

  As an example, in this lab, we will wrap a Kubernetes resource Deployment as a Deployable, and deploy it to
  the two managed clusters that we provisioned.

EOF

  p "# To define the deployable, let's use samples/apps/deployable.yaml..."
  pe "cat samples/apps/deployable.yaml"

  p "# It wraps nginx as a Kubernetes resource Delployment."
  p "# Let's apply it to the hub cluster..."
  pe "oc apply -f samples/apps/deployable.yaml"
}

function task4-step5 {
  p "# Task 4 - Step 5: Check results"

  cat << EOF

  Instructions
  ============

  After we define applications, channels, subscriptions properly, newly created deployable will be deployed on
  to the managed clusters from the hub cluster through the channel, subscription mechanism. Usually, it takes
  a few minutes to take effect.

  You can check the results by issuing oc command both on hub cluster and managed clusters.
  
  You can also check CP4MCM UI by visiting below link:
  $CP4MCM_BASE_URL/multicloud/applications

EOF

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

start_time=$SECONDS

case $1 in
  "")
    lab-instructions
    ;;
  *)
    [[ -z $2 ]] && method_name="$1" || "$1-$2"
    if type $method_name &>/dev/null ; then
      "$method_name"
      # show a prompt so as not to reveal our true nature after
      # the demo has concluded
      p "# Press Enter key to exit..."
    else
      logger::warn "Unknown task or step"
    fi
    ;;
esac
