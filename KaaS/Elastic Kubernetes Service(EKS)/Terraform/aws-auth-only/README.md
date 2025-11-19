## Deploy an EKS cluster with aws-auth configmap only

## Troubeshooting

```
│ Error: creating EKS Cluster (xyz): operation error EKS: CreateCluster, https response error StatusCode: 400, InvalidParameterException: bootstrapClusterCreatorAdminPermissions must be true if cluster authentication mode is set to CONFIG_MAP
│
```

The root cause in the eks resource has set bootstrap_cluster_creator_admin_permissions to false, while API only mode require it to be true.

From the [discussion](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3206), this is an intentional behavior:
But I still don't understand why.

To make it work, after initalized the module, manually set the value to true in the state file.

K8S-On-Cloud/KaaS/Elastic Kubernetes Service(EKS)/Terraform/aws-auth-only/.terraform/modules/eks/main.tf

```terraform
resource "aws_eks_cluster" "this" {
  count = local.create ? 1 : 0

  region = var.region

  name                          = var.name
  role_arn                      = local.role_arn
  version                       = var.kubernetes_version
  enabled_cluster_log_types     = var.enabled_log_types
  deletion_protection           = var.deletion_protection
  bootstrap_self_managed_addons = false
  force_update_version          = var.force_update_version

  access_config {
    authentication_mode = var.authentication_mode

    # See access entries below - this is a one time operation from the EKS API.
    # Instead, we are hardcoding this to false and if users wish to achieve this
    # same functionality, we will do that through an access entry which can be
    # enabled or disabled at any time of their choosing using the variable
    # var.enable_cluster_creator_admin_permissions
    bootstrap_cluster_creator_admin_permissions = true  <- HERE!!!!
  }
	...
```

	