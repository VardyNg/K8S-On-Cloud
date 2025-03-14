output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = "aws eks --region ${local.region} update-kubeconfig --name ${module.eks.cluster_name}"
}

output "batch-job-submission-command" {
  description = "Batch job submission command"
  value       = "aws batch submit-job --job-name my-first-job --job-queue ${aws_batch_job_queue.eks_job_queue.name} --job-definition ${aws_batch_job_definition.eks_job_definition.name} --region ${local.region}"
}