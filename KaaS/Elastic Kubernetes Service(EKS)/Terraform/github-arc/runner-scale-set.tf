
resource "kubernetes_namespace" "arc_runners" {
  metadata {
    name = "arc-runners"
  }
}

resource "kubernetes_secret_v1" "pre_defined" {
  metadata {
    name      = "pre-defined-secret"
    namespace = kubernetes_namespace.arc_runners.metadata[0].name
  }

  type = "Opaque"

  data = {
    github_app_id               = var.github_app_id
    github_app_installation_id  = var.github_app_installation_id
    github_app_private_key      = var.github_app_private_key
  }
}

resource "helm_release" "arc_runner_set" {
  name             = "arc-runner-set-eks"
  namespace        = kubernetes_namespace.arc_runners.metadata[0].name
	version 				 = "0.13.1"
  repository = "oci://ghcr.io/actions/actions-runner-controller-charts"
  chart      = "gha-runner-scale-set"
  values     = [
    <<-EOT
githubConfigUrl: "${var.github_config_url}"

githubConfigSecret: "${kubernetes_secret_v1.pre_defined.metadata[0].name}"

maxRunners: 20

minRunners: 0

containerMode:
  type: "kubernetes-novolume"

listenerTemplate:
  spec:
    containers:
      - name: listener
        securityContext:
          runAsUser: 1000
    tolerations:
    - key: "controller-node"
      operator: "Equal"
      value: "true"
      effect: "NoSchedule"
    nodeSelector:
      controller-node: "true"

template:
  spec:
    containers:
    - name: runner
      image: ghcr.io/actions/actions-runner:latest
      command: ["/home/runner/run.sh"]
      env:
        - name: ACTIONS_RUNNER_REQUIRE_JOB_CONTAINER
          value: "false"
      volumeMounts:
        - name: cache
          mountPath: /home/runner/.cache
      resources:
        limits:
          cpu: "2"
          memory: 3Gi
        requests:
          cpu: "1"
          memory: 2Gi
    volumes:
    - name: cache
      persistentVolumeClaim:
        claimName: runner-cache
EOT
  ]

	depends_on = [
		helm_release.arc
	]
}
