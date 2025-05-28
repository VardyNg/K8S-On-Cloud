output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = "aws eks --region ${local.region} update-kubeconfig --name ${module.eks.cluster_name}"
}

output "create_xray_collector" {
	description = "Create the X-Ray collector by applying the ADOT collector manifest"
	value = <<EOT
kubectl apply -f - <<EOF
apiVersion: opentelemetry.io/v1alpha1
kind: OpenTelemetryCollector
metadata:
	name: my-collector-xray
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
EOT
}
