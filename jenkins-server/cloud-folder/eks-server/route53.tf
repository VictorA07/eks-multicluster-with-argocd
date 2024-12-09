data "aws_route53_zone" "ingress-nginx" {
  name = "hullerdata.com"
  private_zone = false
}

# CREATE CERTIFICATE WHICH IS DEPENDENT ON HAVING A DOMAIN NAME
resource "aws_acm_certificate" "cert" {
  domain_name               = "hullerdata.com"
  subject_alternative_names = ["*.hullerdata.com"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# ATTACHING ROUTE53 AND THE CERTFIFCATE- CONNECTING ROUTE 53 TO THE CERTIFICATE
resource "aws_route53_record" "cert-record" {
  for_each = {
    for anybody in aws_acm_certificate.cert.domain_validation_options : anybody.domain_name => {
      name   = anybody.resource_record_name
      record = anybody.resource_record_value
      type   = anybody.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.ingress-nginx.zone_id
}

# SIGN THE CERTIFICATE
resource "aws_acm_certificate_validation" "ssl_cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert-record : record.fqdn]
}

# DNS records pointing to Load Balancer:
resource "aws_route53_record" "argocd-dns" {
  count = terraform.workspace == "argocd" ? 1 : 0  
  allow_overwrite = true
  zone_id = data.aws_route53_zone.ingress-nginx.zone_id
  name    = "argocd.hullerdata.com"
  type    = "A"

  alias {
    name                   = data.aws_lb.ingress-nginx.dns_name
    zone_id                = data.aws_lb.ingress-nginx.zone_id
    evaluate_target_health = false
  }
  depends_on = [helm_release.ingress_nginx]
}