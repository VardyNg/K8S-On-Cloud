data "http" "kubecost_values" {
  url = "https://raw.githubusercontent.com/kubecost/cost-analyzer-helm-chart/develop/cost-analyzer/values-eks-cost-monitoring.yaml"
}

resource "helm_release" "kubecost" {
  name             = "kubecost"
  chart            = "oci://public.ecr.aws/kubecost/cost-analyzer"
  version          = "2.4.3"
  namespace        = "kubecost"
  create_namespace = true

  values = [
    data.http.kubecost_values.body
  ]
}
