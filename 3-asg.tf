data "aws_ami" "amazonlinux2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = ["amazon"]
}

data "aws_ami" "amazonlinux2023" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = ["amazon"]
}

locals {
  amazonlinux2_ami_id    = data.aws_ami.amazonlinux2.id
  amazonlinux2023_ami_id = data.aws_ami.amazonlinux2023.id
}

module "private_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = ">=5.1.0"

  name        = "Private-SG"
  description = "Allow HTTP traffic from the Application Load Balancer"
  vpc_id      = module.vpc.vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = module.alb_sg.security_group_id
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      description = "Allow HTTPS to ALB"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = ">=6.10.0"

  name = "${var.project}-ASG"

  min_size                  = 0
  max_size                  = 2
  desired_capacity          = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"
  vpc_zone_identifier       = module.vpc.private_subnets
  force_delete              = true

  target_group_arns = module.alb.target_group_arns

  launch_template_name        = "Wordpress-Template"
  launch_template_description = "Wordpress Launch Template"
  launch_template_version     = "$Default"
  update_default_version      = true

  # If you change Image ID to Amazon Linux 2, change the User Data attribute to match
  image_id          = local.amazonlinux2023_ami_id
  instance_type     = var.instance_type
  instance_name     = var.project
  security_groups   = [module.private_sg.security_group_id]
  user_data         = filebase64(var.amzn2023_user_data)
  ebs_optimized     = false
  enable_monitoring = false

  create_iam_instance_profile = true
  iam_instance_profile_name   = "ssm-profile"
  iam_role_name               = "${var.project}-Instance-Role"
  iam_role_path               = "/ec2/"
  iam_role_description        = "IAM role for ${var.project}"
  iam_role_tags = {
    CustomIamRole = "no"
  }
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  autoscaling_group_tags = {
    Name = "${var.project}-ASG"
  }

  tags = {
    Project = "${var.project}"
  }
}
