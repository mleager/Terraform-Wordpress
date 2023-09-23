data "aws_secretsmanager_secret" "secret" {
  arn = "arn:aws:secretsmanager:us-east-1:600005164000:secret:tf_secret-otPZg4"
}

data "aws_secretsmanager_secret_version" "version" {
  secret_id = data.aws_secretsmanager_secret.secret.id
}

locals {
  password = jsondecode(data.aws_secretsmanager_secret_version.version.secret_string)["password"]
}

module "rds_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = ">= 5.1.0"

  name        = "RDS-SG"
  description = "Allow Incoming Traffic to DB on Port 3306"
  vpc_id      = module.vpc.vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "mysql-tcp"
      source_security_group_id = module.private_sg.security_group_id
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = ">=6.1.1"

  identifier = var.db_identifier

  create_db_subnet_group    = true
  create_db_option_group    = false
  create_db_parameter_group = false

  engine            = var.db_engine_version["mysql"][0] #"mysql"
  engine_version    = var.db_engine_version["mysql"][1] #"8.0.33"
  instance_class    = var.db_instance_class
  allocated_storage = 5

  db_name  = var.db_name
  username = var.db_user
  password = local.password
  port     = "3306"

  manage_master_user_password = false

  multi_az               = false
  db_subnet_group_name   = "db-group"
  subnet_ids             = module.vpc.private_subnets
  vpc_security_group_ids = [module.rds_sg.security_group_id]

  skip_final_snapshot = true
  deletion_protection = false

  tags = {
    Project = "${var.project}"
  }
}

output "rds_endpoint_url" {
  value = module.rds.db_instance_endpoint
}
