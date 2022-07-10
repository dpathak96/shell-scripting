#!bin/bash

echo "-----<<<<<< MONGODB SETUP >>>>>---------"

LOG_FILE=/tmp/roboshop.log
rm -rf ${LOG_FILE}

STAT_CHECK() {
  if [ $1 -ne 0 ]; then
    echo -e "\033[34m${2} - FAILED\e[0m"
    exit 1
  else
    echo -e "\e[1;33m${2} - SUCCESS\e[0m"
  fi
}

DOWNLOAD() {
  curl -s -L -o /tmp/${1}.zip "https://github.com/roboshop-devops-project/${1}/archive/main.zip" &>>${LOG_FILE}
  STAT_CHECK $? "Download ${1} code"
}

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

rabbitmqctl list_users | grep roboshop &>>${LOG_FILE}
if [ $? -ne 0 ]; then
  rabbitmqctl add_user roboshop roboshop123 &>>${LOG_FILE}
  STAT_CHECK $? "Create app user in Rabbitmq"
fi

rabbitmqctl set_user_tags roboshop administrator &>>{LOG_FILE} && rabbitmqctl
set_permissions -p / roboshop ".*" ".*" ".*"  &>>${LOG_FILE}
STAT_CHECK $? "Configure app user permission"



echo "--------<<<<<<<< MySQL SETUP >>>>>> ------------"

DOWNLOAD mysql

yum install mysql-community-server -y &>>{LOG_FILE}
STAT_CHECK $? "Install MYSQL"

systemctl enable mysql &>>{LOF_FILE} && systemctl start mysql &>>{LOG_FILE}
STAT_CHECK $? "Start mysql"
