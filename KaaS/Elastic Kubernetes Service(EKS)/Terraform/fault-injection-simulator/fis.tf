resource "awscc_fis_experiment_template" "eks_node_termination" {
  description = "Terminate a fraction of instances in an EKS node group to test fault tolerance"
  role_arn    = aws_iam_role.fis_role.arn

  # Define the stop conditions. Here, no external stop source is defined.
  stop_conditions = [{
    source = "none"
  }]

  # Define a target block that selects the EKS node group.
  targets = {
    eks_nodegroup = {
      id             = "EKSNodeGroupTarget"
      resource_type  = "aws:eks:nodegroup"
      selection_mode = "ALL"
      resource_arns = [
        module.eks.eks_managed_node_groups.default.node_group_arn
      ]
    }
  }

  # Define an action block that uses the aws:eks:terminate-nodegroup-instances action.
  actions = {
    terminate_nodes = {
      id         = "TerminateNodeInstancesAction"
      action_id  = "aws:eks:terminate-nodegroup-instances"
      description = "Terminate 50% of instances in the EKS node group"
      parameters = {
        instanceTerminationPercentage = 50
      }
      targets = {
        Nodegroups = "eks_nodegroup"
      }
    }
  }

  tags = {
    Name = "${local.name}-EKSNodeTerminationExperiment"
  }
}

resource "awscc_fis_experiment_template" "eks_pod_termination" {
  description = "Terminate pods in eks cluster to test fault tolerance"
  role_arn    = aws_iam_role.fis_role.arn

  # Define the stop conditions. Here, no external stop source is defined.
  stop_conditions = [{
    source = "none"
  }]

  # Define a target block that selects the EKS node group.
  targets = {
    EKSPodTarget = {
      id             = "EKSPodTarget"
      resource_type  = "aws:eks:pod"
      selection_mode = "ALL"
      
      parameters = {
        clusterIdentifier = module.eks.cluster_name
        namespace         = kubernetes_namespace_v1.ns.metadata[0].name
        selectorType      = "labelSelector"
        selectorValue     = "app=default"
      }
    }
  }

  // https://docs.aws.amazon.com/fis/latest/userguide/fis-actions-reference.html#pod-delete
  actions = {
    terminate_pods = {
      id         = "TerminatePodsAction"
      action_id  = "aws:eks:pod-delete"
      description = "Terminate pods in the EKS cluster"
      parameters = {
        kubernetesServiceAccount = kubernetes_service_account.fis-sa.metadata[0].name
      }
      targets = {
        Pods = "EKSPodTarget"
      }
    }
  }

  tags = {
    Name = "${local.name}-EKSNodeTerminationExperiment"
  }
}