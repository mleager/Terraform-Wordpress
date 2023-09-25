module "alb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = ">=5.1.0"

  name        = "ALB-SG"
  description = "Allow incoming HTTPS and HTTP traffic to ALB"
  vpc_id      = module.vpc.vpc_id

  ingress_rules       = ["https-443-tcp", "http-80-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]

  # ingress_with_cidr_blocks = [
  #   {
  #     from_port   = 443
  #     to_port     = 443
  #     protocol    = "tcp"
  #     description = "Allow HTTPS to ALB"
  #     cidr_blocks = "0.0.0.0/0"
  #   }
  # ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow all outgoing traffic from ALB"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = ">= 8.7.0"

  name = "${lower(var.project)}-alb"

  load_balancer_type = "application"

  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.public_subnets
  security_groups = [module.alb_sg.security_group_id]

  target_groups = [
    {
      name_prefix          = "tg-"
      backend_protocol     = "HTTP"
      backend_port         = 80
      target_type          = "instance"
      deregistration_delay = 10

      health_check = {
        enabled             = true
        interval            = 60
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 2
        unhealthy_threshold = 4
        timeout             = 30
        protocol            = "HTTP"
        matcher             = "200"
      }
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = module.acm.acm_certificate_arn
      target_group_index = 0
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
      action_type        = "redirect"
      redirect = {
        port        = 443
        protocol    = "HTTPS"
        status_code = "HTTP_302"
        host        = "www.mark-dns.de"
      }
    }
  ]

  lb_tags = {
    Name = "${var.project}-ALB"
  }

  tags = {
    Project = "${var.project}"
  }
}
