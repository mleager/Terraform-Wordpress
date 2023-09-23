data "aws_route53_zone" "main" {
  name = "mark-dns.de"
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name = "www.mark-dns.de"
  zone_id     = data.aws_route53_zone.main.id

  wait_for_validation = true
}

module "dns_record" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 2.0"

  zone_id = data.aws_route53_zone.main.zone_id

  records = [
    {
      name    = "www"
      type    = "CNAME"
      ttl     = 3600
      records = [module.alb.lb_dns_name]
    }
  ]
}
