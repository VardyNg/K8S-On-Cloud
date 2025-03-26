resource "aws_codebuild_project" "codebuild" {
  name          = "${local.name}-codebuild"
  service_role = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type         = "LINUX_CONTAINER"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = <<BUILDSPEC
version: 0.2

phases:
  build:
    commands:
       - aws eks update-kubeconfig --region ${local.region} --name ${module.eks.cluster_name}
       - kubectl create deployment hello-k8s --image=nginx
       - kubectl get pods
BUILDSPEC
  }
}