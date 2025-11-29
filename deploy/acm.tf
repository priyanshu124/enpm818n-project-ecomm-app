# Create Route53 hosted zone and ACM certificate (DNS validated) for the provided domain

#  Hosted zone that will be used to validate the ACM certificate and manage app DNS
data "aws_route53_zone" "hosted_zone" {
  name = "${var.domain}."
}

# Create the DNS validation records
resource "aws_acm_certificate" "ssl" {
  domain_name       = var.domain
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.ssl.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
}

# Tell ACM to validate the certificate using the Route53 records we created
resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.ssl.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
  depends_on              = [aws_route53_record.cert_validation]
}

resource "aws_route53_record" "alb_alias" {
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = var.domain
  type    = "A"

  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
  # Ensure ALB alias is created only after certificate validation
  depends_on = [aws_acm_certificate_validation.cert]
}

output "acm_certificate_arn" {
  value = aws_acm_certificate.ssl.arn
}

output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}
