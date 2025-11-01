
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.4.0"

  name                   = local.name
  kubernetes_version                = var.eks_version
  endpoint_public_access = true
  endpoint_private_access = true

  vpc_id     = aws_vpc.main.id

  subnet_ids = [
		aws_subnet.subnet_primary_1.id,
		aws_subnet.subnet_primary_2.id,
		aws_subnet.subnet_primary_3.id,
	]

  # Cluster access entry
  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true

	addons = {
		coredns = {
			most_recent = true
		}
		metrics-server = {
			most_recent = true
		}
		kube-proxy = {
			most_recent = true
		}
		vpc-cni = {
			most_recent = true
			configuration_values = jsonencode({
				env = {
					AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG = "true"
					ENI_CONFIG_LABEL_DEF = "topology.kubernetes.io/zone"
				}
			})
		}
  }

  tags = local.tags
}
