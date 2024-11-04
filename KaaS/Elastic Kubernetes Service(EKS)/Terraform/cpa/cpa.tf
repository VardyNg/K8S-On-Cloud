resource "helm_release" "cluster_proportional_autoscaler" {
  name       = "cluster-proportional-autoscaler"
  repository = "https://kubernetes-sigs.github.io/cluster-proportional-autoscaler"
  chart      = "cluster-proportional-autoscaler"
  namespace  = "kube-system"

  values = [file("values.yaml")]

  wait = true
}
