resource "aws_s3_bucket" "codepipeline-artifact" {
  bucket = "${local.name}"
  force_destroy = true
}

resource "aws_s3_bucket" "source_bucket" {
  bucket        = "${local.name}-source"
  force_destroy = true

  versioning {
    enabled = true
  }
}

resource "aws_s3_object" "source_file" {
  bucket = aws_s3_bucket.source_bucket.bucket
  key    = "source.zip"
  source = "source.zip"
  etag   = filemd5("source.zip")
}

resource "aws_codepipeline" "codepipeline" {
  name     = "${local.name}-pipeline"
  role_arn = aws_iam_role.codepipeline.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline-artifact.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source-S3"
      category         = "Source"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      output_artifacts = ["source_output-S3"]

      configuration = {
        S3Bucket = aws_s3_bucket.source_bucket.bucket
        S3ObjectKey = "source.zip"
        PollForSourceChanges = "false"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output-S3"]

      configuration = {
        ProjectName = aws_codebuild_project.codebuild.name
      }
    }
  }
}

