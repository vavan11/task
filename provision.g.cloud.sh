#!/bin/bash
echo "Provisioning virtual machine..."
# Add repo
yes "" | sudo add-apt-repository ppa:ondrej/mysql-5.6
sudo locale-gen "en_US.UTF-8"
sudo apt-get update && sudo apt-get -y upgrade
# install Zip
sudo apt-get -y install unzip

#Install nginx and defoult host
sudo apt-get -y install nginx
sleep 3 && sudo systemctl stop nginx
sudo rm /etc/nginx/sites-available/default
sudo cp ~/default /etc/nginx/sites-available/default
sudo a+r /etc/nginx/sites-available/default

# Configuring ssl to nginx
sudo mkdir /etc/nginx/ssl
sudo openssl req -x509 -sha256 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt -days 365 -nodes -subj "/C=UA/ST=Lviv/L=Lviv/O=Global Security/OU=IT Department/CN=example.com"
sudo nginx -t
sudo systemctl start nginx


# Install mysql
touch ~/msqlrootpass
echo "Your root password for mysql" > ~/msqlrootpass
tr -cd '[:alnum:]' < /dev/urandom | fold -w10 | head -n1 >> ~/msqlrootpass
mysqlpass=$(awk 'NR==2{print $1; exit}' ~/msqlrootpass)
export DEBIAN_FRONTEND="noninteractive"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $mysqlpass"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $mysqlpass"
sudo apt-get install -y mysql-server-5.6

#Creating DATABASE
echo "Your jirauser password for mysql" > ~/msqljirauserpass
tr -cd '[:alnum:]' < /dev/urandom | fold -w8 | head -n1 >> ~/msqljirauserpass
msqljirauserpass=$(awk 'NR==2{print $1; exit}' ~/msqljirauserpass)
mysql --password=$mysqlpass --user=root -e "CREATE USER 'jirauser'@'localhost' IDENTIFIED BY '$msqljirauserpass'"
mysql --password=$mysqlpass --user=root -e "CREATE DATABASE jiradb CHARACTER SET utf8 COLLATE utf8_bin"
mysql --password=$mysqlpass --user=root -e "GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,ALTER,INDEX on jiradb.* TO 'jirauser'@'localhost' IDENTIFIED BY '$msqljirauserpass'"

# Configure mysql
sleep 2 &&  sudo /etc/init.d/mysql stop
sudo chmod +w /etc/mysql/mysql.conf.d/mysqld.cnf
sudo sed -i '27a\character-set-server=utf8' /etc/mysql/mysql.conf.d/mysqld.cnf
sudo sed -i '28a\collation-server=utf8_bin' /etc/mysql/mysql.conf.d/mysqld.cnf
sudo sed -i '29a\default-storage-engine=INNODB' /etc/mysql/mysql.conf.d/mysqld.cnf
sudo sed -i '51s/16M/256M/g' /etc/mysql/mysql.conf.d/mysqld.cnf
sudo sed -i '52a\innodb_log_file_size = 2GB' /etc/mysql/mysql.conf.d/mysqld.cnf
sudo sed -i '53a\transaction-isolation = READ-COMMITTED' /etc/mysql/mysql.conf.d/mysqld.cnf
sudo chmod -w /etc/mysql/mysql.conf.d/mysqld.cnf
sudo /etc/init.d/mysql start


# Install Confluence
wget -P /tmp https://www.atlassian.com/software/confluence/downloads/binary/atlassian-confluence-6.2.1-x64.bin
sudo chmod +x /tmp/atlassian-confluence-6.2.1-x64.bin
yes "" | sudo /tmp/atlassian-confluence-6.2.1-x64.bin
sleep 5 && sudo /etc/init.d/confluence stop
sudo rm /opt/atlassian/confluence/conf/server.xml
sudo cp ~/server.xml /opt/atlassian/confluence/conf/server.xml
sudo chmod a+r /opt/atlassian/confluence/conf/server.xml

# install the MySQL database driver to Confluence
sudo wget -P /tmp/ https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.42.zip
sudo unzip /tmp/mysql-connector-java-5.1.42.zip
sudo cp ~/mysql-connector-java-5.1.42/mysql-connector-java-5.1.42-bin.jar /opt/atlassian/confluence/confluence/WEB-INF/lib/

sudo /etc/init.d/confluence start

sleep 5 && sudo netstat -tlpn
cat ~/msqljirauserpass
