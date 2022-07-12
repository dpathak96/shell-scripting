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

DOWNLOAD catalogue

rm -rf /home/roboshop/catalogue && mkdir -p /home/roboshop/catalogue && cp -r /tmp/catalogue-main/* /home/roboshop/catalogue
STAT_CHECK $? "Copy Catalogue content"

cd /home/roboshop/catalogue && npm install &>>{LOG_FILE}
STAT_CHECK $? "NPM install"



# mv /home/roboshop/catalogue/systemd.service /etc/systemd/system/catalogue.service
# systemctl daemon-reload
# systemctl start catalogue
# systemctl enable catalogue