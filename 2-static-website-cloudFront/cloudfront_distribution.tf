# defines Origin Access Control(OAC)
resource "aws_cloudfront_origin_access_control" "static_website_oac" {
  name                              = "static_website_oac"
  description                       = "Origin Access Control(OAC) for static website"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.website_bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.static_website_oac.id
    origin_id                = aws_s3_bucket.website_bucket.id
  }

  enabled             = true
  is_ipv6_enabled     = false
  comment             = "CloudFront Distribution to serve as static website endpoint"
  default_root_object = "index.html"

#   logging_config {
#     include_cookies = false
#     bucket          = "mylogs.s3.amazonaws.com"
#     prefix          = "myprefix"
#   }

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.website_bucket.id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["DE"]
    }
  }

  tags = {
    Environment = "Development"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.s3_distribution.domain_name
}
