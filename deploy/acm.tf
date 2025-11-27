# Create Route53 hosted zone and ACM certificate (DNS validated) for the provided domain

#  Hosted zone that will be used to validate the ACM certificate and manage app DNS
resource "aws_route53_zone" "zone" {
  name = var.domain
  tags = { Name = "${var.prefix}-zone" }
}

# Create the DNS validation records
resource "aws_acm_certificate" "ssl" {
  domain_name       = var.domain
  validation_method = "DNS"
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.ssl.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = aws_route53_zone.zone.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
}

# Tell ACM to validate the certificate using the Route53 records we created
resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.ssl.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

output "acm_certificate_arn" {
  value = aws_acm_certificate.ssl.arn
}
