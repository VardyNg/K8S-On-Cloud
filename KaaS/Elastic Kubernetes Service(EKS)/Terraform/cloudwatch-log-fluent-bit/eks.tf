module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.8.0"

  name                    = local.name
  kubernetes_version      = var.eks_version
  endpoint_public_access  = true
  endpoint_private_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    default = {
      instance_types = ["m5.large"]

      amiType      = "AL2_x86_64"
      min_size     = 1
      max_size     = 5
      desired_size = 1
      iam_role_additional_policies = {
        CloudWatchAgentServerPolicy : "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
      }
    }
  }

  access_entries = {
    # One access entry with a policy associated
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
  }

  addons = {
    amazon-cloudwatch-observability = {
      most_recent = true
      configuration_values = jsonencode({
        containerLogs = {
          enabled = true
          fluentBit = {
            config = {
              service       = file("${path.module}/fluent-bit-service.conf")
              customParsers = file("${path.module}/fluent-bit-parsers.conf")
              extraFiles = {
                "application-log.conf" = file("${path.module}/application-log.conf")
                "dataplane-log.conf"   = file("${path.module}/dataplane-log.conf")
                "host-log.conf"        = file("${path.module}/host-log.conf")
              }
            }
          }
        }
      })
    }
    vpc-cni = {
      most_recent = true
    }
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
  }

  tags = local.tags
}
