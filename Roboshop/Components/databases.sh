#!bin/bash

#-----<<<<<< MONGODB SETUP >>>>>---------

LOG_FILE=/tmp/roboshop.log
rm -rf ${LOG_FILE}

STAT_CHECK() {
  if [ $1 -ne 0 ]; then
    echo -e "\e[1;31m${2} - FAILED\e[0m"
    exit 1
  else
    echo -e "\e[1;32m${2} - SUCCESS\e[0m"
  fi
}

curl -s -o /etc/yum.repos.d/mongodb.repo https://raw.githubusercontent.com/roboshop-devops-project/mongodb/main/mongo.repo &>>{LOG_FILE}
STAT_CHECK $? "Download MongoDB Repo"

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

