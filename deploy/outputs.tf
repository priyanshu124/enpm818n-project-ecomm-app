output "db_host" {
  value = aws_db_instance.main.address
}

output "ami_id" {
  value = data.aws_ami.php-app.id
}


output "static_bucket_name" {
  description = "S3 bucket name for static assets"
  value       = aws_s3_bucket.static.bucket
}

output "static_cdn_domain_name" {
  description = "CloudFront domain name for static assets"
  value       = aws_cloudfront_distribution.static_cdn.domain_name
}