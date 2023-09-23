#!/bin/bash -xe
# Install Httpd, MariaDB, and Wordpress for Amazon Linux 2023
sudo dnf update -y
sudo dnf install -y httpd wget php-fpm php-mysqli php-json php php-devel
sudo dnf install -y mariadb105-server
sudo wget https://wordpress.org/latest.tar.gz
sudo tar -xzf latest.tar.gz
sudo mkdir /var/www/html/wordpress
sudo cp -r wordpress/* /var/www/html/wordpress

# Change DocumentRoot to "/wordpress" and replace 'index.html' with 'index.php' in httpd conf file
sudo sed -i 's|DocumentRoot "/var/www/html"|DocumentRoot "/var/www/html/wordpress"|' /etc/httpd/conf/httpd.conf
sudo sed -i 's/DirectoryIndex index\.html/DirectoryIndex index.php/' /etc/httpd/conf/httpd.conf

# Output Instructions for connecting to MySQL/MariaDB to text file
sudo mkdir /var/www/html/info
echo "# How To Connect to MariaDB" | sudo tee -a /var/www/html/info/info.txt
echo 'Enter: "mysql -h <RDS Endpoint> -u <username> -p"' | sudo tee -a /var/www/html/info/info.txt
echo "" | sudo tee -a /var/www/html/info/info.txt
echo "Next, enter DB Password" | sudo tee -a /var/www/html/info/info.txt
sudo echo "Database instructions created at '/var/www/html/info/info.txt'"

# Start & Enable Httpd and MariaDB
sudo systemctl start httpd 
sudo systemctl start mariadb
sudo systemctl enable httpd
sudo systemctl enable mariadb
