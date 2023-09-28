#!/bin/bash -xe

# Install Httpd, MySQL, PHP, Firewalld, and Dependencies
# AWS Docs: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/hosting-wordpress-aml-2023.html
sudo dnf update -y
sudo dnf install wget php-mysqlnd httpd php-fpm php-mysqli mariadb105-server php-json php php-devel -y
sudo dnf install firewalld -y

# Start and Enable Httpd
sudo systemctl start httpd
sudo systemctl enable httpd

# Start and Enable MySQL
sudo systemctl start mariadb
sudo systemctl enable mariadb

# Start and Enable Firewalld
sudo systemctl start firewalld
sudo systemctl enable firewalld

# Allow HTTP and HTTPS traffic through the firewall
sudo firewall-cmd --add-service=http --permanent
sudo firewall-cmd --add-service=https --permanent
sudo firewall-cmd --reload

# Create Virtual Host Directory and Set Permissions
sudo mkdir /var/www/mark-dns.de
sudo chown -R apache:apache /var/www/mark-dns.de/
sudo chmod 755 /var/www/mark-dns.de/

# Create Virtual Host Configuration for 'mark-dns.de'
sudo touch /etc/httpd/conf.d/mark-dns.de.conf

sudo tee /etc/httpd/conf.d/mark-dns.de.conf > /dev/null <<EOF
<VirtualHost *:80>
    ServerName mark-dns.de
    ServerAlias www.mark-dns.de
    DocumentRoot /var/www/mark-dns.de
    ServerAdmin webmaster@mark-dns.de
    ErrorLog /var/log/httpd/mark-dns.de_error.log
    CustomLog /var/log/httpd/mark-dns.de_access.log combined
</VirtualHost>
<IfModule mod_setenvif.c>
  SetEnvIf X-Forwarded-Proto "^https$" HTTPS
</IfModule>
EOF

# Reload the Apache configuration to apply changes
sudo ln -s /etc/httpd/conf.d/mark-dns.de.conf
sudo systemctl reload httpd

# Download WordPress, Move to Appropriate Directory, and Set Permissions
sudo cd /tmp/
sudo wget https://wordpress.org/latest.tar.gz
sudo tar -xzvf latest.tar.gz
sudo mv wordpress/* /var/www/mark-dns.de/
sudo chown -R apache:apache /var/www/mark-dns.de/