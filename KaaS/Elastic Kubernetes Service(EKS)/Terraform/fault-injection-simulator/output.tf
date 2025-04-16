output "eks_node_termination_command" {
  value = "aws fis start-experiment --experiment-template-id ${awscc_fis_experiment_template.eks_node_termination.id} --region ${local.region}"
}

output "eks_pod_termination_command" {
  value = "aws fis start-experiment --experiment-template-id ${awscc_fis_experiment_template.eks_pod_termination.id} --region ${local.region}"
}