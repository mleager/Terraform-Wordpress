module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = ">=5.1.2"

  name = "${var.project}-VPC"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.4.0/24", "10.0.3.0/24"]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  public_subnet_names  = ["public-subnet-1", "public-subnet-2"]
  private_subnet_names = ["private-subnet-1", "private-subnet-2"]

  igw_tags = {
    Name = "igw"
  }

  nat_gateway_tags = {
    Name = "nat"
  }

  public_route_table_tags = {
    Name = "public-route"
  }

  private_route_table_tags = {
    Name = "private-route"
  }

  vpc_tags = {
    Name = "${var.project}-VPC"
  }

  tags = {
    Project = "${var.project}"
  }
}
