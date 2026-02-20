module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.4.0"

  name                    = local.name
  kubernetes_version      = var.eks_version
  endpoint_public_access  = true
  endpoint_private_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  enable_irsa = true

  access_entries = {
    # Admin access entry
    admin = {
      kubernetes_groups = []
      principal_arn     = data.aws_caller_identity.current.arn

      policy_associations = {
        admin = {
          policy_arn = "arn:${data.aws_partition.current.partition}:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
    # Karpenter node access - must be EC2_LINUX so nodes join the system:nodes group
    # and kubelet-serving CSRs get auto-approved (required for logs/exec)
    karpenter = {
      type          = "EC2_LINUX"
      principal_arn = aws_iam_role.karpenter_node_role.arn
    }
  }

  node_security_group_tags = merge(local.tags, {
    "karpenter.sh/discovery" = local.name
  })

	addons = {
		coredns = {
			most_recent = true

			configuration_values = jsonencode({
				tolerations: [
					{
						key:      "controller-node"
						operator: "Equal"
						value:    "true"
						effect:   "NoSchedule"
					}
				]
				resources: {
					limits: {
						cpu: "2"
					}
					requests: {
						cpu: "0.5"
					}
				}
				autoScaling: {
					enabled: true,
					minReplicas: 2,
					maxReplicas: 10
				}
			})
		}
		metrics-server = {
			most_recent = true

			configuration_values = jsonencode({
				nodeSelector: {
					controller-node = "true"
				}
				tolerations: [
					{
						key:      "controller-node"
						operator: "Equal"
						value:    "true"
						effect:   "NoSchedule"
					}
				]
			})
		}
		kube-proxy = {
			most_recent = true
		}
		vpc-cni = {
			most_recent = true
		}
  }

  tags = var.tags
}

# Get the latest Amazon Linux 2023 AMI for EKS
data "aws_ssm_parameter" "eks_al2023_ami" {
  name = "/aws/service/eks/optimized-ami/${var.eks_version}/amazon-linux-2023/x86_64/standard/recommended/image_id"
}

