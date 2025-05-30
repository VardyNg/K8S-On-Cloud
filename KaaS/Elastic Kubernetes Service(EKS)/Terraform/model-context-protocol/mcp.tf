# There are two potential ways to deploy the MCP server:
# 1. As an EKS add-on (commented out for now, as the exact add-on name may differ)
# 2. As a Helm chart (implemented below)

# Option 1: Deploy MCP server as an EKS add-on (uncomment when available)
# resource "aws_eks_addon" "mcp" {
#   cluster_name = module.eks.cluster_name
#   addon_name   = "eks-mcp-server" # The exact add-on name may differ
#   
#   # Wait for cluster and required add-ons to be ready
#   depends_on = [
#     module.eks
#   ]
# }

# Option 2: Deploy MCP server using Helm chart
resource "helm_release" "mcp_server" {
  name       = "eks-mcp-server"
  repository = "https://eks-charts.s3.amazonaws.com/stable" # Example repository URL, replace with actual
  chart      = "eks-mcp-server"                             # Example chart name, replace with actual
  namespace  = "kube-system"
  
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.mcp_server_role.iam_role_arn
  }
  
  set {
    name  = "logLevel"
    value = "info"
  }
  
  set {
    name  = "clusterName"
    value = module.eks.cluster_name
  }
  
  depends_on = [
    module.eks
  ]
}

# IAM role for the MCP server
module "mcp_server_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  
  role_name = "${local.name}-mcp-server"
  
  oidc_providers = {
    one = {
      provider_arn = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:eks-mcp-server"]
    }
  }
  
  role_policy_arns = {
    policy = aws_iam_policy.mcp_server_policy.arn
  }
  
  tags = local.tags
}

# IAM policy for the MCP server
resource "aws_iam_policy" "mcp_server_policy" {
  name        = "${local.name}-mcp-server-policy"
  description = "Policy for EKS MCP server"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:AccessKubernetesApi",
          "eks:DescribeNodegroup",
          "eks:ListNodegroups",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceTypes",
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
  
  tags = local.tags
}

# Create a Kubernetes service account for AI operations
resource "kubernetes_service_account" "ai_operator" {
  metadata {
    name      = "ai-operator"
    namespace = "default"
    
    annotations = {
      "eks.amazonaws.com/role-arn" = module.ai_operator_role.iam_role_arn
    }
  }
  
  depends_on = [
    module.eks,
    helm_release.mcp_server
  ]
}

# Create IAM role for AI operations
module "ai_operator_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  
  role_name = "${local.name}-ai-operator"
  
  oidc_providers = {
    one = {
      provider_arn = module.eks.oidc_provider_arn
      namespace_service_accounts = ["default:ai-operator"]
    }
  }
  
  role_policy_arns = {
    policy = aws_iam_policy.ai_operator_policy.arn
  }
  
  tags = local.tags
}

# Create IAM policy for AI operations (limited permissions)
resource "aws_iam_policy" "ai_operator_policy" {
  name        = "${local.name}-ai-operator-policy"
  description = "Policy for AI operations via MCP server"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:DescribeNodegroup",
          "eks:ListNodegroups",
          "eks:AccessKubernetesApi",
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
  
  tags = local.tags
}

# Create a ConfigMap with MCP configuration
resource "kubernetes_config_map" "mcp_config" {
  metadata {
    name      = "mcp-config"
    namespace = "default"
  }
  
  data = {
    "mcp-config.json" = jsonencode({
      allowedNamespaces = ["default", "kube-system"]
      logLevel          = "info"
      authorizationMode = "serviceAccount"
    })
  }
  
  depends_on = [
    module.eks,
    helm_release.mcp_server
  ]
}

# Deploy sample application that will be managed by AI through MCP
resource "kubernetes_deployment" "sample_app" {
  metadata {
    name = "sample-app"
    labels = {
      app = "sample-app"
      "ai-managed" = "true"  # Label to identify AI-managed applications
    }
  }
  
  spec {
    replicas = 2
    
    selector {
      match_labels = {
        app = "sample-app"
      }
    }
    
    template {
      metadata {
        labels = {
          app = "sample-app"
          "ai-managed" = "true"
        }
      }
      
      spec {
        container {
          name  = "nginx"
          image = "nginx:latest"
          
          port {
            container_port = 80
          }
          
          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "0.2"
              memory = "256Mi"
            }
          }
        }
      }
    }
  }
  
  depends_on = [
    module.eks,
    helm_release.mcp_server
  ]
}