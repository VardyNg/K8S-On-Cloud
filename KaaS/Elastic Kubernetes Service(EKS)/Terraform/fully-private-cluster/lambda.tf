resource "aws_iam_role" "lambda_execution_role" {
  name = "${local.name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com" 
        }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_eks_access_policy" {
  name = "${local.name}-lambda_eks_access_policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:AccessKubernetesApi"
        ],
        Effect   = "Allow",
        Resource = [
          module.eks.cluster_arn
        ]
      },
      {
        Action  = [
          "logs:*"
        ],
        Effect  = "Allow",
        Resource = "*"
      },
      # https://docs.aws.amazon.com/lambda/latest/dg/configuration-vpc.html
      {
        Action = [ 
          "ec2:CreateNetworkInterface",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeSubnets",
          "ec2:DetachNetworkInterface",
          "ec2:AssignPrivateIpAddresses",
          "ec2:UnassignPrivateIpAddresses"
        ],
        Effect = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_eks_access_policy.arn
}

data "archive_file" "layer_zip" {
  type = "zip"
  source_dir = "layer"
  
  output_path = "layer.zip"
}

data "archive_file" "function_zip" {
  type = "zip"
  source_dir = "src"
  
  output_path = "function.zip"
}


resource "aws_lambda_layer_version" "lambda_layer" {
  layer_name          = "lambda_dependencies_layer"
  compatible_runtimes = ["python3.9"]
  filename            = data.archive_file.layer_zip.output_path
  source_code_hash    = filebase64sha256(data.archive_file.layer_zip.output_path)
}

resource "aws_lambda_function" "eks_lambda_same_subnet" {
  function_name    = "${local.name}-lambda-same_subnet"
  filename         = data.archive_file.function_zip.output_path
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "index.lambda_handler"
  runtime          = "python3.9"
  layers           = [aws_lambda_layer_version.lambda_layer.arn]
  timeout          = 30
  source_code_hash = filebase64sha256(data.archive_file.function_zip.output_path)

  vpc_config {
    subnet_ids         = module.vpc.private_subnets
    security_group_ids = [aws_security_group.allow_all.id]
  }

  environment {
    variables = {
      EKS_CLUSTER_NAME = module.eks.cluster_name
    }
  }
}

