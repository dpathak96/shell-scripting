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

sudo ln -s /usr/local/bin/npm /usr/bin/npm

npm install
STAT_CHECK $? "NPM install"



# mv /home/roboshop/catalogue/systemd.service /etc/systemd/system/catalogue.service
# systemctl daemon-reload
# systemctl start catalogue
# systemctl enable catalogue