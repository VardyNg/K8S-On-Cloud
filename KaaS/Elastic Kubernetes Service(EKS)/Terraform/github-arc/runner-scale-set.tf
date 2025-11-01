
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

  repository = "oci://ghcr.io/actions/actions-runner-controller-charts"
  chart      = "gha-runner-scale-set"
  values     = [
    <<-EOT
githubConfigUrl: "${var.github_config_url}"

githubConfigSecret: "${kubernetes_secret_v1.pre_defined.metadata[0].name}"

maxRunners: 20

minRunners: 1

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
    initContainers:
    - name: init-dind-externals
      image: ghcr.io/actions/actions-runner:latest
      command: ["cp", "-r", "/home/runner/externals/.", "/home/runner/tmpDir/"]
      volumeMounts:
        - name: dind-externals
          mountPath: /home/runner/tmpDir
    containers:
    - name: runner
      image: ghcr.io/actions/actions-runner:latest
      command: ["/home/runner/run.sh"]
      env:
        - name: DOCKER_HOST
          value: unix:///var/run/docker.sock
      volumeMounts:
        - name: work
          mountPath: /home/runner/_work
        - name: dind-sock
          mountPath: /var/run
      resources:
        limits:
          cpu: 3
          memory: 6Gi
        requests:
          cpu: 3
          memory: 6Gi
    - name: dind
      image: docker:dind
      args:
        - dockerd
        - --host=unix:///var/run/docker.sock
        - --group=$(DOCKER_GROUP_GID)
      env:
        - name: DOCKER_GROUP_GID
          value: "123"
      securityContext:
        privileged: true
      volumeMounts:
        - name: work
          mountPath: /home/runner/_work
        - name: dind-sock
          mountPath: /var/run
        - name: dind-externals
          mountPath: /home/runner/externals
    volumes:
    - name: work
      emptyDir: {}
    - name: dind-sock
      emptyDir: {}
    - name: dind-externals
      emptyDir: {}
EOT
  ]

	depends_on = [
		helm_release.arc
	]
}
