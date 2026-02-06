# Create CloudWatch Logs Transformer and Metric Filters to track OOMKilled pods using native Terraform resources

# Compute the CloudWatch log group name based on the EKS cluster name
locals {
  cw_log_group = "/aws/eks/${module.eks.cluster_name}/cluster"
}

# Look up the existing log group by name
data "aws_cloudwatch_log_group" "target" {
  name = local.cw_log_group
}

# Transformer: parse the incoming JSON logs and extract deploymentName from pod names
resource "aws_cloudwatch_log_transformer" "oom_transformer" {
  log_group_arn = data.aws_cloudwatch_log_group.target.arn

  # first processor must be a parser
  transformer_config {
    parse_json {}
  }

  # then run grok to extract deploymentName from pod name
  transformer_config {
    grok {
      source = "objectRef.name"
      # Escape the percent to prevent Terraform template parsing of %{...}
      match  = "%%{DATA:deploymentName}-%%{WORD}-%%{WORD}"
    }
  }
}

# Metric filter that counts OOMKilled events per pod
resource "aws_cloudwatch_log_metric_filter" "oom_pod" {
  name           = "OOMKilled-Pods"
  log_group_name = local.cw_log_group
  pattern        = "{ $.requestObject.status.containerStatuses[*].lastState.terminated.reason = \"OOMKilled\" }"

  metric_transformation {
    name      = "OOMKilledByPod"
    namespace = "EKS/PodHealth"
    value     = "1"
    dimensions = {
      Namespace = "$.objectRef.namespace"
      PodName   = "$.objectRef.name"
    }
  }
}

# Metric filter that counts OOMKilled events per deployment (applies on transformed logs)
resource "aws_cloudwatch_log_metric_filter" "oom_deployment" {
  name                    = "OOMKilled-ByDeployment"
  log_group_name          = local.cw_log_group
  pattern                 = "{ $.requestObject.status.containerStatuses[*].lastState.terminated.reason = \"OOMKilled\" }"
  apply_on_transformed_logs = true

  metric_transformation {
    name      = "OOMKilledByDeployment"
    namespace = "EKS/PodHealth"
    value     = "1"
    dimensions = {
      Namespace  = "$.objectRef.namespace"
      Deployment = "$.deploymentName"
    }
  }

  # Ensure transformer exists before applying metric filter on transformed logs
  depends_on = [aws_cloudwatch_log_transformer.oom_transformer]
}

output "cw_oom_log_group" {
  description = "CloudWatch Logs log group used for OOMKilled metrics"
  value       = local.cw_log_group
}
