# Create a Wordpress Site using Terraform:

Create a Wordpress website that does the following:

1. Stores website data - RDS
2. Manage database password securely - Secrets Manager
3. Provision multiple servers in HA mode - Auto Scaling
4. Install WordPress on your servers - User Data Script
5. Distribute requests across multiple web servers - Load Balancer
6. Connect to the website securely via user-friendly DNS names – Route53, ACM

## Wordpress - How To:

### Create and Use DB Password

1. Create DB Password manually using AWS Secrets Manager
2. Pull Password as a Data Source in Terraform
3. Specify the Secret as the RDS Password

  ( optional - but recommended )

4. Create S3 Remote Backend so that DB Password is not stored as plain text in TF State file

### Output DB Endpoint, DB Name, and DB User Name to use with Wordpress

( optional ) 

Will be used on the EC2 Instance terminal to initiate MySQL and connect it to RDS.

* NOTE: 
  1. RDS Endpoint output will include the port number appended to the end
     
  * Do not include the port number in the MySQL command to connect to the database
  
    rds_endpoint Output from Terraform:
    ```
    <RDS Endpoint>:3306
    ```
  
  2. Not recommeneded to output the AWS Secret - use AWS CLI or AWS console manually to retrieve the value
    ```
    $ aws secretsmanager get-secret-value --secret-id MyTestSecret
    ```

### Specify EC2 Instance AMI

Choose the proper AMI and User Data script in the ASG Module depending on which Amazon Linux AMI you prefer:
* Amazon Linux 2 ( Default in this repo )
* Amazon Linux 2023
* Amazon Linux

A Launch Template resource may be used to implement default choice depending on a Boolean variable.

Will require adjustments of the ASG Module.
```
variable "use_amazonlinux2" {
  type        = bool
  description = "Set to true if you want to use Amazon Linux 2, false for Amazon Linux 2023"
  default     = true
}

resource "aws_launch_template" "template" {
  name                   = "${var.project}-Template"
  image_id               = var.use_amazonlinux2 ? data.aws_ami.amazonlinux2.id : data.aws_ami.amazonlinux2023.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [module.private_sg.security_group_id]
  user_data              = var.use_amazonlinux2 ? filebase64(var.amzn2_user_data) : filebase64(var.amzn2023_user_data)

  update_default_version = true

  instance_initiated_shutdown_behavior = "terminate"

  iam_instance_profile {
    name = aws_iam_instance_profile.ssm_instance_profile.name
  }
}
```

### Connect local MySQL on EC2 terminal to the RDS Instance

From EC2 Terminal:
```
$ mysql -h <RDS Endpoint> -u <DB User Name> -p
```
* Enter password when prompted ( password from AWS Secrets Manager )

### Verify Wordpress RDS database is Operational and Connected

After connecting to MySQL using the command above, perform the following commands:
1. List all databases to ensure "Wordpress" database is in the returned list
```
mysql$ SHOW databases;
```
2. Use Wordpress database
```
mysql$ USE wordpress;
```
3. View Wordpress database tables
```
mysql$ SELECT * FROM wp_users;
```

If the following commands return results, the Wordpress RDS database is connected.

### Setup Wordpress server using the RDS Credentials

Wordpress comes with a built-in Admin page to modify the website. 

If the EC2 Instance is functioning properly, connecting to the DNS of the Application Load Balancer or the Public IP of the EC2 instance will route to the WP Admin page.

Follow Wordpress instructions to intiate Wordpress account and site:
  1. Use Credentials from RDS Module:

    - DB Name
    - DB User
    - DB Password

  2. Wordpress will provide config data
     
    Copy generated code into wordpress/wp-config.php

  4. Sign in to Wordpress using Credentials
     
    You will create a User Name and Password by following the Wordpress setup
