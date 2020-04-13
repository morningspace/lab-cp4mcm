# The Kubernetes namespace used for this lab
LAB_NAMESPACE="cp4mcm-lab"

# The CP4MCM URL, usually points to the master node
CP4MCM_BASE_URL="https://icp-console.10.0.10.2.nip.io"

# AWS settings
AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
AWS_REGION=${AWS_REGION:-"us-east-2"}
AWS_CLUSTER_NAME=${AWS_CLUSTER_NAME:-"my-cluster-eks"}

# kind settings
KIND_CLUSTER_NAME=${KIND_CLUSTER_NAME:-"my-cluster-kind"}
