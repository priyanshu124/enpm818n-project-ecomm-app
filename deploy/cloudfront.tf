locals {
  static_origin_id = "${var.prefix}-static-origin"
}

resource "aws_cloudfront_origin_access_control" "static_oac" {
  name                              = "${var.prefix}-static-oac"
  description                       = "OAC for static assets S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# Use AWS managed cache policy "Managed-CachingOptimized"
data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}

resource "aws_cloudfront_distribution" "static_cdn" {
  enabled             = true
  comment             = "${var.prefix} static assets CDN"
  default_root_object = "index.html"

  aliases     = var.cloudfront_aliases
  price_class = var.cloudfront_price_class

  origin {
    domain_name              = aws_s3_bucket.static.bucket_regional_domain_name
    origin_id                = local.static_origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.static_oac.id
  }

  default_cache_behavior {
    target_origin_id       = local.static_origin_id
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]

    # Enable edge compression (gzip/brotli) on responses
    compress = true

    # Use AWS managed caching policy with compression + long TTLs
    cache_policy_id = data.aws_cloudfront_cache_policy.caching_optimized.id
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = "arn:aws:acm:us-east-1:245838289780:certificate/93a4c492-cd37-4b93-9607-0e169921a045"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = {
    Name = "${var.prefix}-static-cdn"
  }
}
