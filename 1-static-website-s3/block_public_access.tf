# block_public_access.tf
resource "aws_s3_account_public_access_block" "account_public_access_block" {
  
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
