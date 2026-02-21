
# IAM Role for EFS CSI Driver (IRSA)
resource "aws_iam_role" "efs_csi_driver" {
  name = "${local.name}-efs-csi-driver"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(module.eks.oidc_provider, "https://", "")}"
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringLike = {
          "${replace(module.eks.oidc_provider, "https://", "")}:sub" = "system:serviceaccount:kube-system:efs-csi-*"
          "${replace(module.eks.oidc_provider, "https://", "")}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "efs_csi_driver" {
  role       = aws_iam_role.efs_csi_driver.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
}

# EFS Filesystem
resource "aws_efs_file_system" "runner_cache" {
  creation_token   = "${local.name}-runner-cache"
  encrypted        = true
  performance_mode = "generalPurpose"
  throughput_mode  = "elastic"

  lifecycle_policy {
    transition_to_ia = "AFTER_7_DAYS"
  }

  tags = merge(var.tags, {
    Name = "${local.name}-runner-cache"
  })
}

resource "aws_efs_access_point" "runner_cache" {
  file_system_id = aws_efs_file_system.runner_cache.id

  posix_user {
    uid = 1000
    gid = 1000
  }

  root_directory {
    path = "/cache"
    creation_info {
      owner_uid   = 1000
      owner_gid   = 1000
      permissions = "777"
    }
  }
}

# Security Group for EFS mount targets
resource "aws_security_group" "efs_mount_target" {
  name        = "${local.name}-efs-mount-target"
  description = "Allow worker nodes to mount EFS"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    security_groups = [
      module.eks.node_security_group_id,
      module.eks.cluster_primary_security_group_id
    ]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(var.tags, {
    Name = "${local.name}-efs-mount-target"
  })
}

# EFS Mount Targets (one per private subnet)
resource "aws_efs_mount_target" "runner_cache" {
  for_each        = { for k, v in module.vpc.private_subnets : k => v }
  file_system_id  = aws_efs_file_system.runner_cache.id
  subnet_id       = each.value
  security_groups = [aws_security_group.efs_mount_target.id]
}

# EFS File System Policy
data "aws_iam_policy_document" "efs_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientWrite",
    ]
    resources = [aws_efs_file_system.runner_cache.arn]
    condition {
      test     = "Bool"
      variable = "elasticfilesystem:AccessedViaMountTarget"
      values   = ["true"]
    }
  }

  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientWrite",
    ]
    resources = [aws_efs_file_system.runner_cache.arn]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalArn"
      values   = [aws_iam_role.efs_csi_driver.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "elasticfilesystem:AccessPointArn"
      values   = [aws_efs_access_point.runner_cache.arn]
    }
  }
}

resource "aws_efs_file_system_policy" "runner_cache" {
  file_system_id = aws_efs_file_system.runner_cache.id
  policy         = data.aws_iam_policy_document.efs_policy.json
}

# StorageClass for EFS
resource "kubernetes_storage_class_v1" "efs_sc" {
  metadata {
    name = "efs-sc"
  }
  storage_provisioner = "efs.csi.aws.com"
  mount_options       = ["tls", "iam"]
  parameters = {
    fileSystemId     = aws_efs_file_system.runner_cache.id
    provisioningMode = "efs-ap"
    directoryPerms   = "700"
    gidRangeEnd      = "2000"
    gidRangeStart    = "1000"
    accessPointId    = aws_efs_access_point.runner_cache.id
  }
  depends_on = [aws_efs_file_system.runner_cache]
}

# PVC for runner cache
resource "kubernetes_persistent_volume_claim_v1" "runner_cache" {
  metadata {
    name      = "runner-cache"
    namespace = kubernetes_namespace.arc_runners.metadata[0].name
  }
  spec {
    access_modes       = ["ReadWriteMany"]
    storage_class_name = kubernetes_storage_class_v1.efs_sc.metadata[0].name
    resources {
      requests = {
        storage = "5Gi"
      }
    }
  }
  depends_on = [
    aws_efs_mount_target.runner_cache,
    kubernetes_storage_class_v1.efs_sc
  ]
}
