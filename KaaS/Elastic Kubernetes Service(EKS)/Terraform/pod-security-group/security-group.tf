resource "kubernetes_manifest" "security_group_policy" {
	manifest = {
		apiVersion = "vpcresources.k8s.aws/v1beta1"
		kind       = "SecurityGroupPolicy"
		metadata = {
			name      = "my-security-group-policy"
			namespace = kubernetes_namespace.default.metadata[0].name
		}
		spec = {
			podSelector = {
				matchLabels = {
					app = "my-app"
				}
			}
			securityGroups = {
				groupIds = [
					aws_security_group.allow_all.id,
				]
			}
		}
	}
}

resource "aws_security_group" "allow_all" {
	name        = "allow_all_pods"
	description = "Allow all inbound and outbound traffic"
	vpc_id      = module.vpc.vpc_id

	# Allow inbound from CoreDNS and other pods using same SG
  ingress {
    description = "HTTP from within VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  # Allow kubelet probes (e.g., health checks)
  ingress {
    description = "Allow kubelet probes from node SG"
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    security_groups = [module.eks.node_security_group_id] # node SG id
  }

  # Allow pod-to-pod communication within the same security group
  ingress {
    description = "Allow pod-to-pod communication"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }

  # Allow DNS queries to CoreDNS (UDP) - to node security group
	egress {
    description = "Allow DNS UDP to CoreDNS on nodes"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    security_groups = [module.eks.node_security_group_id]
  }

  # Allow DNS queries to CoreDNS (TCP) - to node security group
  egress {
    description = "Allow DNS TCP to CoreDNS on nodes"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    security_groups = [module.eks.node_security_group_id]
  }

  # Also allow DNS to VPC CIDR as fallback
  egress {
    description = "Allow DNS UDP to VPC CIDR"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  egress {
    description = "Allow DNS TCP to VPC CIDR"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  # Allow HTTPS outbound (for pulling images, etc.)
  egress {
    description = "Allow HTTPS outbound"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP outbound
  egress {
    description = "Allow HTTP outbound"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow pod-to-pod communication within the same security group
  egress {
    description = "Allow pod-to-pod communication"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }

  # Allow communication to cluster security group (for API server access)
  egress {
    description = "Allow communication to EKS cluster"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = [module.eks.cluster_security_group_id]
  }

  # Allow communication to node security group for service discovery
  egress {
    description = "Allow communication to nodes"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    security_groups = [module.eks.node_security_group_id]
  }

  tags = var.tags
}

# Add rule to node security group to allow DNS from pod security group
resource "aws_security_group_rule" "allow_dns_from_pod_sg" {
  type                     = "ingress"
  from_port                = 53
  to_port                  = 53
  protocol                 = "udp"
  source_security_group_id = aws_security_group.allow_all.id
  security_group_id        = module.eks.node_security_group_id
  description              = "Allow DNS UDP from pod security group"
}

resource "aws_security_group_rule" "allow_dns_tcp_from_pod_sg" {
  type                     = "ingress"
  from_port                = 53
  to_port                  = 53
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.allow_all.id
  security_group_id        = module.eks.node_security_group_id
  description              = "Allow DNS TCP from pod security group"
}
