resource "kubernetes_namespace_v1" "ns" {
  metadata {
    name = "karpenter"
  }
}

resource "helm_release" "karpenter" {
  name       = "karpenter"
  namespace  = kubernetes_namespace_v1.ns.metadata.0.name
  create_namespace = true

  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = "1.0.8"

  set {
    name  = "settings.clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.karpenter_controller_role.arn
  }

  set {
    name  = "controller.resources.requests.cpu"
    value = "1"
  }

  set {
    name  = "controller.resources.requests.memory"
    value = "1Gi"
  }

  set {
    name  = "controller.resources.limits.cpu"
    value = "1"
  }

  set {
    name  = "controller.resources.limits.memory"
    value = "1Gi"
  }

  timeout = 300 # Optional: Adjust based on your requirements
  wait    = true
}

data "aws_ssm_parameter" "eks_al2023_ami" {
  name = "/aws/service/eks/optimized-ami/1.29/amazon-linux-2023/x86_64/standard/recommended/image_id"
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
            "karpenter.sh/discovery" = module.eks.cluster_name
          }
        }
      ]
      "securityGroupSelectorTerms" = [
        {
          "tags" = {
            "karpenter.sh/discovery" = module.eks.cluster_name
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
    apiServerEndpoint: ${module.eks.cluster_endpoint}
    certificateAuthority: ${module.eks.cluster_certificate_authority_data}
    cidr: ${module.eks.cluster_service_cidr}
    name: test-cluster
  kubelet:
    config:
      clusterDNS:
      - 172.20.0.10
      maxPods: 118
    flags:
    - --node-labels="karpenter.sh/capacity-type=on-demand,karpenter.sh/nodepool=default"

--//
Content-Type: text/x-shellscript; charset="us-ascii"

#!/bin/bash
# Set ulimit values
echo "* soft nofile 65536" >> /etc/security/limits.conf
echo "* hard nofile 65536" >> /etc/security/limits.conf
echo "ulimit -n 65536" >> /etc/profile

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
