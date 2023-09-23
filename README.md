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

( optional - but recommended ) 
  Will be used on the EC2 Instance terminal to initiate MySQL and connect it to RDS

  * NOTE: RDS Endpoint output will include the port number appended to the end
    - DO not use the port number in the MySQL command to connect to the database

  Ex:
  Output --> rds_endpoint: <RDS Endpoint>:3306
  MySQL command: <RDS Endpoint>

### Create EC2 

- Choose the proper User Data script depending on which Amazon Linux AMI you prefer
* Amazon Linux 2 ( Default in this repo ), Amazon Linux 2023, Amazon Linux

### Connect local MySQL on EC2 to RDS

From EC2 Terminal:
```
$ mysql -h <RDS Endpoint> -u <DB User Name> -p
```
* Enter password when prompted ( password from AWS Secrets Manager )

### Setup Wordpress server using the RDS Credentials

* Wordpress comes with a built-in Admin page to modify the website
Follow instructions:
  1. Use Credentials from RDS Module
    - DB Name
    - DB User
    - DB Password

  2. Wordpress will provide config data 
    - Copy generated code into wordpress/wp-config.php

  3. Sign in to Wordpress using Credentials
    - You will create a User Name and Password by following Wordpress setup
