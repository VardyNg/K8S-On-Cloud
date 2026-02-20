resource "kubernetes_namespace_v1" "karpenter" {
  metadata {
    name = "karpenter"
  }

  depends_on = [
    module.eks
  ]
}

resource "helm_release" "karpenter" {
	name             = "karpenter"
	namespace        = kubernetes_namespace_v1.karpenter.metadata.0.name
	create_namespace = true
	

	repository = "oci://public.ecr.aws/karpenter"
	chart      = "karpenter"
	version    = "1.5.0"

	values = [
		<<-EOT
settings:
  clusterName: ${module.eks.cluster_name}

serviceAccount:
  annotations:
    eks.amazonaws.com/role-arn: ${aws_iam_role.karpenter_controller_role.arn}

controller:
  resources:
    requests:
      cpu: "0.5"
      memory: "512Mi"
    limits:
      cpu: "2"
      memory: "2Gi"

replicas: 1

tolerations:
  - key: "controller-node"
    operator: "Equal"
    value: "true"
    effect: "NoSchedule"

logLevel: info
EOT
	]

	timeout = 300
	wait    = true
}

# Uncomment and apply after EKS cluster is ready
resource "kubectl_manifest" "karpenter_ec2nodeclass_runner" {
	yaml_body = yamlencode({
		apiVersion = "karpenter.k8s.aws/v1"
		kind       = "EC2NodeClass"
		metadata = {
			name = "runner"
		}
		spec = {
			amiFamily = "AL2023"
			role      = "${aws_iam_role.karpenter_node_role.name}"
			subnetSelectorTerms = [
				{
					tags = {
						"karpenter.sh/discovery" = "${module.eks.cluster_name}"
					}
				}
			]
			securityGroupSelectorTerms = [
				{
					id = "${module.eks.cluster_primary_security_group_id}"
				}
			]
			"amiSelectorTerms" = [
				{ "id" = data.aws_ssm_parameter.eks_al2023_ami.value }
			],
			blockDeviceMappings = [
				{
					deviceName = "/dev/xvda"
					ebs = {
						volumeSize = "50Gi"
						volumeType = "gp3"
						deleteOnTermination = true
						encrypted = true
					}
				}
			]
			kubeReserved = {
				cpu = "500m"
				memory = "300Mi"
			}
			systemReserved = {
				cpu = "100m"
				memory = "100Mi"
			}
			tags = var.tags
		}
	})

	depends_on = [ 
		helm_release.karpenter,
	 ]
}

resource "kubectl_manifest" "karpenter_nodepool_runner" {
	yaml_body = <<-EOT
apiVersion: karpenter.sh/v1
kind: NodePool
metadata:
  name: runner
spec:
  template:
    spec:
      requirements:
        - key: kubernetes.io/arch
          operator: In
          values: [amd64]
        - key: kubernetes.io/os
          operator: In
          values: [linux]
        - key: karpenter.sh/capacity-type
          operator: In
          values: [spot]
        - key: node.kubernetes.io/instance-type
          operator: In
          values: [
            "c5.2xlarge", "c5.4xlarge",
            "c5a.2xlarge", "c5a.4xlarge",
            "c5n.2xlarge", "c5n.4xlarge",
            "c6a.2xlarge", "c6a.4xlarge",
            "c6i.2xlarge", "c6i.4xlarge",
            "c7a.2xlarge", "c7a.4xlarge",
            "m5.2xlarge", "m5a.2xlarge",
            "m6a.2xlarge", "m6i.2xlarge"
          ]
      nodeClassRef:
        group: karpenter.k8s.aws
        kind: EC2NodeClass
        name: runner
      expireAfter: 1h
  limits:
    cpu: 1000
  disruption:
    consolidationPolicy: WhenEmpty
    consolidateAfter: 30s
EOT

	depends_on = [
		helm_release.karpenter,
		kubectl_manifest.karpenter_ec2nodeclass_runner
	]
}