resource "local_file" "user_data" {
  content  = data.template_cloudinit_config.node.rendered
  filename = "../user_data/user-data"
}

module "smng" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-eks.git//modules/self-managed-node-group?ref=dfed830957079301b879814e87608728576dd168"
  count  = 1

  cluster_version                   = local.cluster_version
  cluster_name                      = local.name
  cluster_primary_security_group_id = module.eks.cluster_primary_security_group_id

  name            = local.name
  use_name_prefix = false

  subnet_ids = module.vpc.private_subnets

  min_size     = 1
  max_size     = 7
  desired_size = 2

  ami_id        = data.aws_ami.eks_default.id
  instance_type = "m5.large"

  launch_template_name            = local.name
  launch_template_use_name_prefix = false
  launch_template_description     = "Self managed node group example launch template"

  enable_monitoring = false

  block_device_mappings = {
    xvda = {
      device_name = "/dev/xvda"
      ebs = {
        volume_size           = 75
        volume_type           = "gp3"
        iops                  = 3000
        throughput            = 150
        delete_on_termination = true
      }
    }
  }

  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
    instance_metadata_tags      = "disabled"
  }

  iam_role_name            = local.name
  iam_role_use_name_prefix = false
  iam_role_description     = "Self managed node group complete example role"
  iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
    CloudWatchAgentServerPolicy  = "arn:${data.aws_partition.current.partition}:iam::aws:policy/CloudWatchAgentServerPolicy"
    NodeAdditional               = aws_iam_policy.node_additional.arn
  }

  autoscaling_group_tags = {
    "k8s.io/cluster-autoscaler/enabled" : true,
    "k8s.io/cluster-autoscaler/${local.name}" : "owned",
  }

  warm_pool = {
    pool_state                  = "Stopped"
    min_size                    = 2
    max_group_prepared_capacity = 6
  }

  initial_lifecycle_hooks = [
    {
      lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"
      name                 = "finish_user_data"
    },
  ]

  user_data_template_path = local_file.user_data.filename
}
