resource "aws_launch_template" "eks_custom_al2_lt" {
  name_prefix   = "${local.name}-al2-lt"
  image_id      = "ami-0d835dd3c85c512e7"
  instance_type = "c6i.8xlarge"

  user_data = base64encode(<<-EOF
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh ${module.eks.cluster_name} \
	--apiserver-endpoint '${module.eks.cluster_endpoint}' \
	--b64-cluster-ca '${module.eks.cluster_certificate_authority_data}' \
	--kubelet-extra-args '--register-with-taints=some-taint=true:NoSchedule'
  )
EOF
	)
}

resource "aws_eks_node_group" "mng-custom-al2" {
  cluster_name    = module.eks.cluster_name
  node_group_name = "mng-custom-al2"
  node_role_arn   = aws_iam_role.eks_worker_role.arn

  subnet_ids = module.vpc.private_subnets

  scaling_config {
    desired_size = 2
    max_size     = 5
    min_size     = 1
  }

  launch_template {
    id      = aws_launch_template.eks_custom_al2_lt.id
    version = "$Latest"
  }
}