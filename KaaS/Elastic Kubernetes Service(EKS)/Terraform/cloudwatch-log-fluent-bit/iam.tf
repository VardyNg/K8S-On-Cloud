resource "aws_iam_role_policy_attachment" "lb_controller_attach" {
  role        = module.eks.eks_managed_node_groups.initial.iam_role_name
  policy_arn  = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}
