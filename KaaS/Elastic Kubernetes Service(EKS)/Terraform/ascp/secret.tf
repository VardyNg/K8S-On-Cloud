# AWS Secrets Manager Secret example for ASCP

resource "aws_secretsmanager_secret" "example_secret" {
  name_prefix             = "ascpexamplesecret"
  description             = "Example secret for ASCP testing"
  recovery_window_in_days = 7

  tags = {
    Environment = "example"
    Purpose     = "ascptesting"
  }
}

resource "aws_secretsmanager_secret_version" "example_secret_version" {
  secret_id = aws_secretsmanager_secret.example_secret.id
  secret_string = jsonencode({
    username = "admin"
    password = "MySecurePassword123!"
    api_key  = "sk-1234567890abcdefghijklmnopqrst"
    database = "myapp_db"
  })
}
