resource "aws_launch_template" "resource_reservation_lt" {
  name_prefix   = "${local.name}-lt"
  image_id      = data.aws_ssm_parameter.eks_al2023_ami.value
  instance_type = var.instance_type

  user_data = base64encode(<<-EOF
Content-Type: multipart/mixed; boundary="BOUNDARY"
MIME-Version: 1.0

--BOUNDARY
Content-Transfer-Encoding: 7bit
Content-Type: application/node.eks.aws
Mime-Version: 1.0

---
apiVersion: node.eks.aws/v1alpha1
kind: NodeConfig
spec:
  cluster:
    name: ${aws_eks_cluster.this.name}
    apiServerEndpoint: ${aws_eks_cluster.this.endpoint}
    certificateAuthority: ${aws_eks_cluster.this.certificate_authority[0].data}
    cidr: ${aws_eks_cluster.this.kubernetes_network_config[0].service_ipv4_cidr}
  kubelet:
    config:
      # System resource reservation - reserves resources for OS processes
      systemReserved:
        cpu: "${var.system_reserved_cpu}"
        memory: "${var.system_reserved_memory}"
        ephemeral-storage: "${var.system_reserved_storage}"
      
      # Kubernetes resource reservation - reserves resources for K8s components
      kubeReserved:
        cpu: "${var.kube_reserved_cpu}"
        memory: "${var.kube_reserved_memory}"
        ephemeral-storage: "${var.kube_reserved_storage}"
      
      # Enforcement of system and kube reserved resources
      enforceNodeAllocatable:
        - pods
        - system-reserved
        - kube-reserved
      
      # Hard eviction thresholds - immediate pod eviction
      evictionHard:
        memory.available: "${var.eviction_hard_memory}"
        nodefs.available: "${var.eviction_hard_storage}"
        imagefs.available: "${var.eviction_hard_storage}"
      
      # Soft eviction thresholds - graceful pod eviction with grace period
      evictionSoft:
        memory.available: "${var.eviction_soft_memory}"
        nodefs.available: "${var.eviction_soft_storage}"
        imagefs.available: "${var.eviction_soft_storage}"
      
      # Grace periods for soft eviction
      evictionSoftGracePeriod:
        memory.available: "${var.eviction_soft_grace_period}"
        nodefs.available: "${var.eviction_soft_grace_period}"
        imagefs.available: "${var.eviction_soft_grace_period}"
      
      # Additional kubelet configuration for better resource management
      serializeImagePulls: false
      maxPods: 110
      
--BOUNDARY--
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = merge(local.tags, {
      Name = "${local.name}-worker"
    })
  }

  tags = local.tags
}

resource "aws_eks_node_group" "resource_reservation" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${local.name}-workers"
  node_role_arn   = aws_iam_role.eks_worker_role.arn
  subnet_ids      = module.vpc.private_subnets

  scaling_config {
    desired_size = 2
    max_size     = 5
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  launch_template {
    id      = aws_launch_template.resource_reservation_lt.id
    version = "$Latest"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_container_registry_policy,
  ]

  tags = local.tags
}