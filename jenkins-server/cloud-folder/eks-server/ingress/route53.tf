resource "aws_route53_zone" "ingress-nginx" {
  name = "hullerdata.com"
}

# DNS records pointing to Load Balancer:
resource "aws_route53_record" "elb" {
    
  allow_overwrite = true
  zone_id = aws_route53_zone.ingress-nginx.zone_id
  name    = "hullerdata.com"
  type    = "A"

  alias {
    name                   = data.kubernetes_service.ingress-nginx.status[0].load_balancer[0].ingress[0].hostname
    zone_id                = data.aws_lb.ingress-nginx.zone_id
    evaluate_target_health = false
  }
}