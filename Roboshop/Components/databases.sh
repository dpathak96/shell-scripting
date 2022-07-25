#!bin/bash

echo "-----<<<<<< MONGODB SETUP >>>>>---------"

source common.sh

DOWNLOAD mongodb

yum install -y mongodb-org &>>{LOG_FILE}
STAT_CHECK $? "Install MongoDB"

sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf &>>{LOG_FILE}

systemctl enable mongod &>>{LOG_FILE} && systemctl restart mongod &>>{LOG_FILE}
STAT_CHECK $? "Start MongoDB Service"

curl -s -L -o /tmp/mongodb.zip "https://github.com/roboshop-devops-project/mongodb/archive/main.zip" &>>${LOG_FILE}
STAT_CHECK $? "Download mongodb code"

cd /tmp && unzip -o /tmp/mongodb.zip &>>${LOG_FILE}
STAT_CHECK $? "Extract MongoDB code"

cd /tmp/mongodb-main
mongo < catalogue.js &>>{LOG_FILE} && mongo < users.js &>>{LOG_FILE}
STAT_CHECK $? "Load Schema"



echo "---------<<<<<<<<< REDIS SETUP >>>>>>>>-----------"

DOWNLOAD redis

yum install redis -y &>>{LOG_FILE}
STAT_CHECK $? "Install Redis"

sed -i 's/127.0.0.1/0.0.0.0/'  /etc/redis.conf &>>{LOG_FILE}
STAT_CHECK $? "Update config file"


systemctl enable redis &>>{LOG_FILE} && systemctl start redis &>>{LOG_FILE}
STAT_CHECK $? "start redis"



echo "----------<<<<<<<<< RABBITMQ SETUP >>>>>>>>>-------"

curl -s "https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh" | sudo bash &>>{LOG_FILE}
STAT_CHECK $? "Repositories for rabbit mq"

yum install https://github.com/rabbitmq/erlang-rpm/releases/download/v23.2.6/erlang-23.2.6-1.el7.x86_64.rpm rabbitmq-server -y &>>{LOG_FILE}
STAT_CHECK $? "Install Erlang dependency"

yum install rabbitmq-server -y &>>{LOG_FILE}
STAT_CHECK $? "Install RabbitMQ server"

systemctl enable rabbitmq-server &>>{LOG_FILE} && systemctl start rabbitmq-server &>>${LOG_FILE}
STAT_CHECK $? "Start RabbitMQ"

id roboshop

if [ $? -ne 0 ]; then
  useradd roboshop &>>{LOG_FILE}
  STAT_CHECK $? "Add Application user"
fi

rabbitmqctl set_user_tags roboshop administrator &>>{LOG_FILE} && rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"  &>>${LOG_FILE}
STAT_CHECK $? "Configure app user permission"



echo "--------<<<<<<<< MySQL SETUP >>>>>> ------------"

curl -s -L -o /etc/yum.repos.d/mysql.repo https://raw.githubusercontent.com/roboshop-devops-project/mysql/main/mysql.repo &>>{LOG_FILE}
STAT_CHECK $? "Configure Yum Repos"

yum install mysql-community-server -y
STAT_CHECK $? "Install MYSQL"

systemctl enable mysqld && systemctl start mysqld
STAT_CHECK $? "Start mysql"

DEFAULT_PASSWORD=$(grep 'temporary password' /var/log/mysqld.log | awk '{print $NF}')

echo 'show databases;' | mysql -uroot -pRoboShop@1 &>>{LOG_FILE}
if [ $? -ne 0 ]; then
 echo "ALTER USER 'root'@'localhost' IDENTIFIED BY 'RoboShop@1';" >/tmp/pass.sql
 mysql --connect-expired-password -uroot -p"${DEFAULT_PASSWORD}" </tmp/pass.sql &>>{LOG_FILE}
fi


#As per the Application need, we are choosing MySQL 5.7 version.
#
#
#
#
#Install MySQL
## yum install mysql-community-server -y
#
#Start MySQL.
## systemctl enable mysqld
## systemctl start mysqld
#
#Now a default root password will be generated and given in the log file.
## grep temp /var/log/mysqld.log
#
#Next, We need to change the default root password in order to start using the database service.
## mysql_secure_installation
#
#You can check the new password working or not using the following command.
#
## mysql -u root -p
#
#Run the following SQL commands to remove the password policy.
#> uninstall plugin validate_password;
#Setup Needed for Application.
#As per the architecture diagram, MySQL is needed by
#
#Shipping Service
#So we need to load that schema into the database, So those applications will detect them and run accordingly.
#
#To download schema, Use the following command
#
## curl -s -L -o /tmp/mysql.zip "https://github.com/roboshop-devops-project/mysql/archive/main.zip"
#Load the schema for Services.
#
## cd /tmp
## unzip mysql.zip
## cd mysql-main
## mysql -u root -pRoboShop@1 <shipping.sql