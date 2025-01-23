# s3_bucket.tf
resource "aws_s3_bucket" "website_bucket" {
  bucket = "hd-static-site-bucket"
  force_destroy = true

  tags = {
    Name        = "HdStaticWebsite"
    Environment = "Production"
  }
}

resource "aws_s3_bucket_website_configuration" "hd-blog" {
  bucket = aws_s3_bucket.website_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

}

# block_public_access.tf
resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.website_bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

##### will upload all the files present under HTML folder to the S3 bucket #####
resource "aws_s3_object" "upload_object" {
  for_each      = fileset("html/", "*")
  bucket        = aws_s3_bucket.website_bucket.id
  key           = each.value
  source        = "html/${each.value}"
  etag          = filemd5("html/${each.value}")
  content_type  = "text/html"
}

output "website_url" {
    value = aws_s3_bucket.website_bucket.website_endpoint
    description = "The URL of the static website" 
}

