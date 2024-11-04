
resource "aws_s3_bucket" "default" { 
  bucket = "${local.name}-${data.aws_caller_identity.current.account_id}"

  tags = { 
    Name        = "${local.name}-${data.aws_caller_identity.current.account_id}"
  }
}