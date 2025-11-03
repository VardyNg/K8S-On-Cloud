resource "aws_eks_addon" "coredns" {
  cluster_name = module.eks.cluster_name
  addon_name   = "coredns"

  resolve_conflicts_on_update = "OVERWRITE"

  # https://github.com/aws/amazon-vpc-cni-k8s/issues/2726#issuecomment-1869078906
  configuration_values = jsonencode({
    autoScaling : {
      enabled : true,
      minReplicas : 4,
      maxReplicas : 10
    },
    # affinity: {
    #   nodeAffinity: {
    #     requiredDuringSchedulingIgnoredDuringExecution: {
    #       nodeSelectorTerms: [
    #         {
    #           matchExpressions: [
    #             {
    #               key: "some_label",
    #               operator: "In",
    #               values: ["true"]
    #             },
    #             {
    #               key: "kubernetes.io/os",
    #               operator: "In",
    #               values: ["linux"]
    #             },
    #             {
    #               key: "kubernetes.io/arch",
    #               operator: "In",
    #               values: ["amd64", "arm64"]
    #             }
    #           ]
    #         }
    #       ]
    #     }
    #   }
    # }
    nodeSelector : {
      some_label = "true"
    }
  })
}