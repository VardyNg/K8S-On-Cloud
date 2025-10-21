# Single Helm chart that installs both Secrets Store CSI Driver and ASCP provider
# Reference: https://docs.aws.amazon.com/secretsmanager/latest/userguide/ascp-eks-installation.html#integrating_csi_driver_install
resource "helm_release" "secrets_provider_aws" {
	name       = "secrets-provider-aws"
	repository = "https://aws.github.io/secrets-store-csi-driver-provider-aws"
	chart      = "secrets-store-csi-driver-provider-aws"
	namespace  = "kube-system"
}

# SecretProviderClass to define which secret to mount
resource "kubernetes_manifest" "secret_provider_class" {
  manifest = {
    apiVersion = "secrets-store.csi.x-k8s.io/v1"
    kind       = "SecretProviderClass"
    metadata = {
      name      = "nginx-irsa-deployment-aws-secrets"
      namespace = kubernetes_namespace.example.metadata[0].name
    }
    spec = {
      provider = "aws"
      parameters = {
        objects = "- objectName: \"${aws_secretsmanager_secret.example_secret.name}\"\n  objectType: \"secretsmanager\"\n"
      }
    }
  }
  depends_on = [helm_release.secrets_provider_aws]
}