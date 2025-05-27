output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = "aws eks --region ${local.region} update-kubeconfig --name ${module.eks.cluster_name}"
}

# output "kubectl_configure_secret" {
# 	description = "Configure the secret for ARC: make sure you're logged in with the correct AWS profile and run the following command to create the secret"
# 	value       = "kubectl create secret generic pre-defined-secret --from-literal=github_app_id=${var.github_app_id} --from-literal=github_app_installation_id=${var.github_app_installation_id} --from-literal=github_app_private_key=${var.github_app_private_key} -n ${kubernetes_namespace.arc_runners_1.metadata[0].name}"
# }

# output "patch-arc-gha-rs-controller" {
# 	description = "To ensure the ARC GHA Runner Controller pods are scheduled on the controller node group, run the following command"
#   value = <<EOF
# kubectl patch deployment arc-gha-rs-controller \
# 	-n arc-systems \
#   --type='merge' \
#   -p '{
#     "spec": {
#       "template": {
#         "spec": {
#           "nodeSelector": {
#             "controller": "true"
#           },
#           "tolerations": [
#             {
#               "key": "controller",
#               "operator": "Equal",
#               "value": "true",
#               "effect": "NoSchedule"
#             }
#           ]
#         }
#       }
#     }
#   }'
# EOF
# }