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

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04*"]
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
  amazonlinux2023_ami_id = data.aws_ami.amazonlinux2023.id
  ubuntu_ami_id          = data.aws_ami.ubuntu.id
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

resource "aws_launch_template" "template" {
  name                   = "${var.project}-Template"
  image_id               = var.use_amazonlinux ? local.amazonlinux2023_ami_id : local.ubuntu_ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [module.private_sg.security_group_id]
  user_data              = var.use_amazonlinux ? filebase64(var.amzn2023_user_data) : filebase64(var.ubuntu_user_data)

  update_default_version = true

  instance_initiated_shutdown_behavior = "terminate"

  iam_instance_profile {
    arn = module.asg.iam_instance_profile_arn
  }

  tags = {
    Project = "${var.project}"
  }
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

  create_launch_template = false
  launch_template        = aws_launch_template.template.name

  ebs_optimized     = false
  enable_monitoring = false

  create_iam_instance_profile = true
  iam_role_name               = "ssm-instance-role"
  iam_role_path               = "/ec2/"
  iam_role_description        = "SSM role example"
  iam_role_tags = {
    CustomIamRole = "No"
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
