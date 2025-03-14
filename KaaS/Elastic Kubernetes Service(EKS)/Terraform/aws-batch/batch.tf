resource "aws_iam_instance_profile" "eks_worker_nodes" {
  name = "eks-worker-nodes-instance-profile"
  role = aws_iam_role.eks_worker_nodes.name
}

resource "aws_iam_role" "eks_worker_nodes" {
  name = "eks-worker-nodes-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_worker_nodes_AmazonEKSWorkerNodePolicy" {
  role       = aws_iam_role.eks_worker_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_worker_nodes_AmazonEC2ContainerRegistryReadOnly" {
  role       = aws_iam_role.eks_worker_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "eks_worker_nodes_AmazonEKS_CNI_Policy" {
  role       = aws_iam_role.eks_worker_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_batch_compute_environment" "eks_compute_environment" {
  compute_environment_name = "My-Eks-CE1"
  type                     = "MANAGED"
  state                    = "ENABLED"

  eks_configuration {
    eks_cluster_arn      = module.eks.cluster_arn
    kubernetes_namespace = kubernetes_namespace.batch.metadata.0.name
  }

  compute_resources {
    type                = "EC2"
    allocation_strategy = "BEST_FIT_PROGRESSIVE"
    min_vcpus           = 0
    max_vcpus           = 128
    instance_type       = ["m5"]
    subnets             = module.vpc.private_subnets
    security_group_ids  = [module.eks.node_security_group_id]
    instance_role       = aws_iam_instance_profile.eks_worker_nodes.arn
  }
}

resource "aws_batch_job_queue" "eks_job_queue" {
  name     = "My-Eks-JQ1"
  priority = 10
  state    = "ENABLED"

  compute_environment_order {
    order                = 1
    compute_environment  = aws_batch_compute_environment.eks_compute_environment.arn
  }
}

resource "aws_batch_job_definition" "eks_job_definition" {
  name = "MyJobOnEks_Sleep"
  type = "container"

  eks_properties {
    pod_properties {
      host_network = true
      containers {
        image = "public.ecr.aws/amazonlinux/amazonlinux:2"
        command = [
          "sleep",
          "60"
        ]
        resources {
          limits = {
            cpu    = "1"
            memory = "1024Mi"
          }
        }
      }
      metadata {
        labels = {
          environment = "test"
        }
      }
    }
  }
}