variable "project" {
  type        = string
  description = "Project Name"
}

variable "use_amazonlinux2" {
  type        = bool
  description = "Set to true if you want to use Amazon Linux 2, false for Amazon Linux 2023"
  default     = true
}

variable "instance_type" {
  type        = string
  description = "Instance Type for ASG controlled EC2 Instances"
}

variable "db_identifier" {
  type        = string
  description = "DB Identifier Name"
}

variable "db_engine_version" {
  type        = map(list(string))
  description = "Map of lists that holds a DB engine and its version"
  default = {
    "mysql"    = ["mysql", "8.0.33"]
    "mariadb"  = ["mariadb", "10.6.14"]
    "postgres" = ["postgres", "15.3"]
  }
}

variable "db_instance_class" {
  type        = string
  description = "RDS Instance Class - default to Free Tier selection"
  default     = "db.t3.micro"
}

variable "db_name" {
  type        = string
  description = "Name of the MySQL Database"
}

variable "db_user" {
  type        = string
  description = "Name of the MySQL Database User"
}

variable "amzn2023_user_data" {
  type        = string
  description = "Relative Path to the User Data Bash Script for Amazon Linux 2023"
}

variable "amzn2_user_data" {
  type        = string
  description = "Relative Path to the User Data Bash Script for Amazon Linux 2"
}

variable "ubuntu_user_data" {
  type        = string
  description = "Relative Path to the User Data Bash Script for Ubuntu 22.04"
}
