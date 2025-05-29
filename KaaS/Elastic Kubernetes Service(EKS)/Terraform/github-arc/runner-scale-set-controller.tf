resource "helm_release" "arc" {
  name             = "arc"
  namespace        = "arc-systems"
  create_namespace = true

  repository = "oci://ghcr.io/actions/actions-runner-controller-charts"
  chart      = "gha-runner-scale-set-controller"

	values = [
		<<-EOT
nodeSelector:
  controller-node: "true"

tolerations:
- key: "controller-node"
  operator: "Equal"
  value: "true"
  effect: "NoSchedule"
EOT
	]
}
