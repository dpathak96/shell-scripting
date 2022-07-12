#!bin/bash

echo "--------<<<<<<<catalogue setup>>>>>>>>>---------"

source common.sh


yum install nodejs make gcc-c++ -y &>>{LOG_FILE}
STAT_CHECK $? "Install NodeJS"

id roboshop &>>{LOG_FILE}

if [ $? -ne 0 ]; then
  useradd roboshop &>>{LOG_FILE}
  STAT_CHECK $? "Add Application user"
fi

curl -s -L -o /tmp/catalogue.zip "https://github.com/roboshop-devops-project/catalogue/archive/main.zip" &>>{LOG_FILE}
STAT_CHECK $? "Download catalogue"

unzip -o /tmp/catalogue.zip
STAT_CHECK $? "unzip catalogue content"

cd /home/roboshop/catalogue

sudo yum install npm &>>{LOG_FILE}
STAT_CHECK $? "NPM install"

chown roboshop:roboshop -R /home/roboshop

sed -i -e 's/MONGO_DNSNAME/mongo.roboshop.interior/' /home/roboshop/catalogue/systemd.service
STAT_CHECK $? "Update IP address in systemd file"


mv /home/roboshop/catalogue/systemd.service /etc/systemd/system/catalogue.service
STAT_CHECK $? "Moved content in system file"

systemctl daemon-reload &>>{LOG_FILE} && systemctl start catalogue &>>{LOG_FILE} && systemctl enable catalogue &>>{LOG_FILE}
STAT_CHECK $? "Start Catalogue service"
