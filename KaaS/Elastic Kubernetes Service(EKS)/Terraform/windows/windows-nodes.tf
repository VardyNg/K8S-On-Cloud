data "aws_ssm_parameter" "windows_ami" {
  name = "/aws/service/ami-windows-latest/Windows_Server-2022-English-Core-EKS_Optimized-${var.eks_version}/image_id"
}

resource "aws_launch_template" "eks_windows_nodes" {
  name_prefix   = "${local.name}-lt"
  image_id      = data.aws_ssm_parameter.windows_ami.value
  instance_type = "t3.medium"

  user_data = base64encode(<<-EOF
<powershell>
[string]$EKSBinDir = "$env:ProgramFiles\Amazon\EKS"
[string]$EKSBootstrapScriptName = 'Start-EKSBootstrap.ps1'
[string]$EKSBootstrapScriptFile = "$EKSBinDir\$EKSBootstrapScriptName"
(Get-Content $EKSBootstrapScriptFile).replace('"--proxy-mode=kernelspace",', '"--proxy-mode=kernelspace", "--feature-gates WinDSR=true", "--enable-dsr",') | Set-Content $EKSBootstrapScriptFile
& $EKSBootstrapScriptFile -EKSClusterName ${local.name} -APIServerEndpoint ${module.eks.cluster_endpoint} -Base64ClusterCA ${module.eks.cluster_certificate_authority_data} -DNSClusterIP "172.20.0.10" 3>&1 4>&1 5>&1 6>&1
</powershell>
  EOF
  )
}

resource "aws_eks_node_group" "windows" {
  cluster_name    = module.eks.cluster_name
  node_group_name = "windows"
  node_role_arn   = aws_iam_role.eks_worker_role.arn

  subnet_ids = module.vpc.private_subnets

  scaling_config {
    desired_size = 1
    max_size     = 5
    min_size     = 1
  }

  launch_template {
    id      = aws_launch_template.eks_windows_nodes.id
    version = "$Latest"
  }
}