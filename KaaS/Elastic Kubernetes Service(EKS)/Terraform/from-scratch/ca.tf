resource "helm_release" "cluster_autoscaler" {
  name       = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"
  wait       = true

  values = [
    yamlencode({
      autoDiscovery = {
        clusterName = aws_eks_cluster.cluster.name
      }
      awsRegion = var.region
      rbac = {
        serviceAccount = {
          name = "cluster-autoscaler-sa"
          annotations = {
            "eks.amazonaws.com/role-arn" = aws_iam_role.cluster_autoscaler.arn
          }
        }
      }
    })
  ]
}
