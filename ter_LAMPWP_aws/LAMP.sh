#!/bin/bash
sudo apt update
sudo apt install apache2 mysql-server mysql-client php7.2 php7.2-dev -y
sudo service apache2 start
sudo mysql -u root -e "CREATE USER 'ku9n'@'localhost' IDENTIFIED BY 'Password';"
sudo mysql -u root -e "FLUSH PRIVILEGES;"
sudo mysql -u root -e "CREATE DATABASE wordpressdb;"
sudo service mysql start
wget https://wordpress.org/latest.tar.gz
tar -xvzf latest.tar.gz
sudo cp -r wordpress/* /var/www/html
sudo apt install php7.2-mysql
sudo chown -R www-data:www-data /var/www/html
cd /var/www/html/
sudo rm index.html
sudo systemctl restart apache2
