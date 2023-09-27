#!/bin/bash -xe

# install required packages
sudo apt update -y
sudo apt install -y apache2 \
                 ghostscript \
                 libapache2-mod-php \
                 mysql-server \
                 php \
                 php-bcmath \
                 php-curl \
                 php-imagick \
                 php-intl \
                 php-json \
                 php-mbstring \
                 php-mysql \
                 php-xml \
                 php-zip

sudo systemctl start apache2
sudo systemctl enable apache2
sudo systemctl start mysql
sudo systemctl enable mysql

# allow Apache firewall
sudo ufw allow 'Apache Full'

# creating virtual host
sudo mkdir /var/www/mark-dns.de
sudo chown -R www-data.www-data /var/www/mark-dns.de/
sudo chmod 755 /var/www/mark-dns.de/

sudo touch /etc/apache2/sites-available/mark-dns.de.conf

sudo tee /etc/apache2/sites-available/mark-dns.de.conf > /dev/null <<EOF
<VirtualHost *:80>
    ServerName mark-dns.de
    ServerAlias www.mark-dns.de
    DocumentRoot /var/www/mark-dns.de
    ServerAdmin webmaster@mark-dns.de
    ErrorLog /var/log/apache2/mark-dns.de_error.log
    CustomLog /var/log/apache2/mark-dns.de_access.log combined
</VirtualHost>
<IfModule mod_setenvif.c>
  SetEnvIf X-Forwarded-Proto "^https$" HTTPS
</IfModule>
EOF

sudo a2ensite mark-dns.de
sudo a2dissite 000-default
sudo a2enmod rewrite
sudo systemctl reload apache2

# download wordpress and configure it.
sudo cd /tmp/
sudo wget https://wordpress.org/latest.tar.gz
sudo tar -xzvf latest.tar.gz
sudo mv wordpress/* /var/www/mark-dns.de/
sudo chown -R www-data.www-data /var/www/mark-dns.de/
