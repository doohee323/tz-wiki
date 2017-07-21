#!/usr/bin/env bash

set -x

export USER=vagrant  # for vagrant
export PROJ_NAME=wiki
export HOME_DIR=/home/$USER
export PROJ_DIR=/vagrant
export SRC_DIR=/vagrant/resources  # for vagrant

sudo sh -c "echo '' >> $HOME_DIR/.bashrc"
sudo sh -c "echo 'export PATH=$PATH:.' >> $HOME_DIR/.bashrc"
sudo sh -c "echo 'export HOME_DIR='$HOME_DIR >> $HOME_DIR/.bashrc"
sudo sh -c "echo 'export SRC_DIR='$SRC_DIR >> $HOME_DIR/.bashrc"
source $HOME_DIR/.bashrc

sudo apt-get install software-properties-common git -y
sudo add-apt-repository ppa:ondrej/php -y

sudo apt-get update

### [install nginx] ############################################################################################################
sudo apt-get install nginx -y

sudo cp $SRC_DIR/nginx/nginx.conf /etc/nginx/nginx.conf
sudo cp -Rf $SRC_DIR/nginx/wiki /etc/nginx/sites-available
sudo ln -s /etc/nginx/sites-available/wiki /etc/nginx/sites-enabled/wiki
# curl http://127.0.0.1:80
sudo service nginx stop
sudo nginx -s stop

### [install mysql] ############################################################################################################
echo "mysql-server mysql-server/root_password password passwd123" | sudo debconf-set-selections
echo "mysql-server mysql-server/root_password_again password passwd123" | sudo debconf-set-selections
sudo apt-get install mysql-server -y

if [ -f "/etc/mysql/mysql.conf.d/mysqld.cnf" ]
then
    sudo sed -i "s/bind-address/#bind-address/g" /etc/mysql/mysql.conf.d/mysqld.cnf
else
    sudo sed -i "s/bind-address/#bind-address/g" /etc/mysql/my.cnf
fi

# sudo systemctl status mysql.service
# sudo systemctl stop mysql.service
# sudo systemctl start mysql.service
sudo systemctl restart mysql.service
# mysqladmin -p -u root version
# sudo mysql -u root -p mysql
# passwd123

sudo apt-get install ufw
sudo ufw allow 3306
sudo ufw enable -y

sudo mysql -u root -ppasswd123 -e \
"use mysql; \
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'passwd123'; \
FLUSH PRIVILEGES; \
"
sudo mysql -u root -ppasswd123 -e \
"CREATE DATABASE wikidb; \
CREATE USER wikiuser@localhost; \
SET PASSWORD FOR wikiuser@localhost= PASSWORD('passwd123'); \
GRANT ALL PRIVILEGES ON wikidb.* TO wikiuser@localhost IDENTIFIED BY 'passwd123'; \
FLUSH PRIVILEGES; \
"

### [install php] ############################################################################################################
sudo apt-get install php7.0-fpm -y
sudo apt-get install php7.0-mysql -y
sudo apt-get install php7.0-mbstring -y
sudo apt-get install php7.0-xml -y
sudo apt install zip unzip php7.0-zip -y

sudo apt-get install php7.0-curl -y
sudo apt-get install php7.0-intl -y
sudo apt-get install php7.0-gd -y
sudo apt-get install texlive -y

sudo sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php/7.0/fpm/php.ini
sudo sed -i "s/;error_log = php_errors.log/error_log = php_errors.log/g" /etc/php/7.0/fpm/php.ini
sudo sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 200M/g" /etc/php/7.0/fpm/php.ini
sudo sed -i "s/post_max_size = 8M/post_max_size = 200M/g" /etc/php/7.0/fpm/php.ini
sudo sed -i "s/max_execution_time = 300/max_execution_time = 24000/g" /etc/php/7.0/fpm/php.ini
sudo sed -i "s/max_input_time = 300/max_input_time = 24000/g" /etc/php/7.0/fpm/php.ini
sudo sed -i "s/memory_limit = 128MB/memory_limit = 2048M/g" /etc/php/7.0/fpm/php.ini
sudo service php7.0-fpm stop 

### [open firewalls] ############################################################################################################
sudo ufw allow "Nginx Full"
sudo iptables -I INPUT -p tcp --dport 21 -j ACCEPT
sudo iptables -I INPUT -p tcp --dport 22 -j ACCEPT
sudo iptables -I INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -I INPUT -p tcp --dport 443 -j ACCEPT
sudo iptables -I INPUT -p tcp --dport 3306 -j ACCEPT
sudo service iptables save
sudo service iptables restart

### [install wiki] ############################################################################################################
su - $USER

cd $PROJ_DIR
git clone https://gerrit.wikimedia.org/r/p/mediawiki/core.git
sudo mv core /var/www/mediawiki

sudo apt install composer -y
cd /var/www/mediawiki/
composer install --no-dev
sudo chown www-data:www-data /var/www/mediawiki/ -R

### [start services] ############################################################################################################

sudo /etc/init.d/mysql restart  
#mysql -h localhost -P 3306 -u root -p

sudo nginx -s stop
sudo nginx
sudo service php7.0-fpm restart

#curl http://192.168.82.170

exit 0
