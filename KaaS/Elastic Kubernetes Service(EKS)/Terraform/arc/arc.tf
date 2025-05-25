# Create namespace for ARC controller
resource "kubernetes_namespace_v1" "arc_systems" {
  metadata {
    name = var.arc_namespace
  }

  depends_on = [
    module.eks,
    aws_eks_node_group.controller_nodes
  ]
}

# Create namespace for ARC runners
resource "kubernetes_namespace_v1" "arc_runners" {
  metadata {
    name = var.arc_runners_namespace
  }

  depends_on = [
    module.eks,
    aws_eks_node_group.controller_nodes
  ]
}

# Install ARC controller using Helm
resource "helm_release" "arc_controller" {
  name       = "arc"
  namespace  = kubernetes_namespace_v1.arc_systems.metadata.0.name
  create_namespace = true

  repository = "oci://ghcr.io/actions/actions-runner-controller-charts"
  chart      = "gha-runner-scale-set-controller"
  version    = "0.8.2"  # Specify the version you want to use

  # Set node affinity to run on controller nodes
  set {
    name  = "affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].key"
    value = "node-role.kubernetes.io/controller"
  }

  set {
    name  = "affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].operator"
    value = "Exists"
  }

  # Set resource limits and requests
  set {
    name  = "resources.limits.cpu"
    value = "500m"
  }

  set {
    name  = "resources.limits.memory"
    value = "512Mi"
  }

  set {
    name  = "resources.requests.cpu"
    value = "200m"
  }

  set {
    name  = "resources.requests.memory"
    value = "256Mi"
  }

  timeout = 300
  wait    = true

  depends_on = [
    aws_eks_node_group.controller_nodes,
    kubernetes_namespace_v1.arc_systems
  ]
}

# The ARC runner scale set would be installed post-deployment
# with the following command (provided in output.tf):
# 
# helm install arc-runner-set \
#   --namespace arc-runners \
#   --create-namespace \
#   -f values.yaml \
#   oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set
#
# Where values.yaml contains:
#
# githubConfigUrl: https://github.com/OWNER/REPO
# githubConfigSecret: pre-defined-secret
#
# The secret would be created with:
# kubectl create secret generic pre-defined-secret \
#   --namespace=arc-runners \
#   --from-literal=github_app_id=YOUR_APP_ID \
#   --from-literal=github_app_installation_id=YOUR_INSTALLATION_ID \
#   --from-literal=github_app_private_key='YOUR_PRIVATE_KEY'