resource "kubernetes_namespace_v1" "karpenter-ns" {
  metadata {
    name = "karpenter"
  }
}

resource "helm_release" "karpenter" {
  name       = "karpenter"
  namespace  = kubernetes_namespace_v1.karpenter-ns.metadata.0.name
  create_namespace = true

  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = "1.9.0"

  set = [
		{
			name  = "settings.clusterName"
			value = aws_eks_cluster.cluster.name
  	},
		{
			name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
			value = aws_iam_role.karpenter_controller_role.arn
		},
		{
			name  = "controller.resources.requests.cpu"
			value = "1"
		},
		{
			name  = "controller.resources.requests.memory"
			value = "1Gi"
		},
		{
			name  = "controller.resources.limits.cpu"
			value = "1"
		},
		{
			name  = "controller.resources.limits.memory"
			value = "1Gi"
		}
	]



  timeout = 300 # Optional: Adjust based on your requirements
  wait    = true
}

resource "kubernetes_manifest" "karpenter_ec2nodeclass" {
  manifest = {
    "apiVersion" = "karpenter.k8s.aws/v1"
    "kind"       = "EC2NodeClass"
    "metadata" = {
      "name" = "nodeclass"
    }
    "spec" = {
      "amiFamily" = "AL2023"
      "role"      = aws_iam_role.karpenter_node_role.name
      "subnetSelectorTerms" = [
        {
          "tags" = {
            "karpenter.sh/discovery" = aws_eks_cluster.cluster.name
          }
        }
      ]
      "securityGroupSelectorTerms" = [
        {
          "tags" = {
            "karpenter.sh/discovery" = aws_eks_cluster.cluster.name
          }
        }
      ]
      "amiSelectorTerms" = [
        { "id" = data.aws_ssm_parameter.eks_al2023_ami.value }
      ],
      "userData": <<-EOT
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="//"

--//
Content-Type: application/node.eks.aws

# Karpenter Generated NodeConfig
apiVersion: node.eks.aws/v1alpha1
kind: NodeConfig
spec:
  cluster:
    name: ${aws_eks_cluster.cluster.id}
    apiServerEndpoint: ${aws_eks_cluster.cluster.endpoint}
    certificateAuthority: ${aws_eks_cluster.cluster.certificate_authority.0.data}
    cidr: ${aws_eks_cluster.cluster.kubernetes_network_config.0.service_ipv4_cidr}
  kubelet:
    config:
      clusterDNS:
      - 172.20.0.10
      maxPods: 118
    flags:
    - --node-labels="karpenter.sh/capacity-type=on-demand,karpenter.sh/nodepool=default"
--//--
      EOT
    }
  }
}

resource "kubernetes_manifest" "karpenter_nodepool" {
  manifest = {
    "apiVersion" = "karpenter.sh/v1"
    "kind"       = "NodePool"
    "metadata" = {
      "name" = "nodepool"
    }
    "spec" = {
      "template" = {
        "spec" = {
          "requirements" = [
            {
              "key"      = "kubernetes.io/arch"
              "operator" = "In"
              "values"   = ["amd64"]
            },
            {
              "key"      = "kubernetes.io/os"
              "operator" = "In"
              "values"   = ["linux"]
            },
            {
              "key"      = "karpenter.sh/capacity-type"
              "operator" = "In"
              "values"   = ["on-demand"]
            },
            {
              "key" = "node.kubernetes.io/instance-type"
              "operator" = "In"
              "values"   = ["m5.large"]
            }
          ]
          "nodeClassRef" = {
            "group" = "karpenter.k8s.aws"
            "kind"  = "EC2NodeClass"
            "name"  = "nodeclass"
          }
          "expireAfter" = "720h"
        }
      }
      "limits" = {
        "cpu" = 1000
      }
      "disruption" = {
        "consolidationPolicy" = "WhenEmptyOrUnderutilized"
        "consolidateAfter"    = "1m"
      }
    }
  }
}
