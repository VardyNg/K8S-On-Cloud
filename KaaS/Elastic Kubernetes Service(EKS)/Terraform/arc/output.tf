output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = "aws eks --region ${local.region} update-kubeconfig --name ${module.eks.cluster_name}"
}

output "create_github_secret_command" {
  description = "Command to create GitHub App secret for ARC"
  value       = <<-EOT
    # Create the namespace for runner
    kubectl create namespace ${var.arc_runners_namespace}
    
    # Create a secret with the GitHub App credentials
    kubectl create secret generic pre-defined-secret \
      --namespace=${var.arc_runners_namespace} \
      --from-literal=github_app_id=YOUR_GITHUB_APP_ID \
      --from-literal=github_app_installation_id=YOUR_GITHUB_APP_INSTALLATION_ID \
      --from-literal=github_app_private_key='YOUR_GITHUB_APP_PRIVATE_KEY'
  EOT
}

output "arc_runner_set_install_command" {
  description = "Command to install ARC runner set"
  value       = <<-EOT
    # Create values.yaml for the runner set
    cat > values.yaml <<EOF
    githubConfigUrl: ${var.github_config_url}
    githubConfigSecret: pre-defined-secret
    EOF
    
    # Install the runner set
    helm install arc-runner-set \
      --namespace ${var.arc_runners_namespace} \
      --create-namespace \
      -f values.yaml \
      oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set
  EOT
}