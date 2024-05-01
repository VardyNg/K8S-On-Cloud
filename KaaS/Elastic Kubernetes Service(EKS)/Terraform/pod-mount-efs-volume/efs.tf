resource "aws_efs_file_system" "default" {
  creation_token = local.name

  tags = {
    Name = local.name
  }
}

resource "aws_efs_mount_target" "default" {
  for_each        = { for k, instance in flatten(module.vpc.private_subnets) : k => instance}
  file_system_id  = aws_efs_file_system.default.id
  subnet_id       = each.value
  security_groups = [aws_security_group.efs-mount-target.id]
}

resource "aws_security_group" "efs-mount-target" {
  name        = "${local.name}-efs-mount-target"
  description = "Allow worker nodes to mount the mount target"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"    
    security_groups = [module.eks.node_security_group_id]
  }
  tags = {
    Name = "${local.name}-efs-mount-target"
  }
}