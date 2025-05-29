resource "kubernetes_manifest" "adot_collector_xray" {
  manifest = yamldecode(<<EOF
apiVersion: opentelemetry.io/v1alpha1
kind: OpenTelemetryCollector
metadata:
  name: my-collector-xray
  namespace: default
spec:
  mode: deployment
  resources:
    requests:
      cpu: "1"
    limits:
      cpu: "1"
  serviceAccount: adot-collector
  config: |
    receivers:
      otlp:
        protocols:
          grpc:
            endpoint: 0.0.0.0:4317
          http:
            endpoint: 0.0.0.0:4318
    processors:
      batch/traces:
        timeout: 1s
        send_batch_size: 50

    exporters:
      awsxray:
        region: "${local.region}"

    service:
      pipelines:
        traces:
          receivers: [otlp]
          processors: [batch/traces]
          exporters: [awsxray]
EOF
  )

  lifecycle {
    ignore_changes = [
      manifest["spec"]
    ]
  }

	// Supress "Provider produced inconsistent result after apply" error
	computed_fields = [
		"spec.config"
	]
}
