#!bin/bash

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

set-hostname -skip-apply ${COMPONENT}

DOWNLOAD() {
  curl -s -L -o /tmp/${1}.zip "https://github.com/roboshop-devops-project/${1}/archive/main.zip" &>>${LOG_FILE}
  STAT_CHECK $? "Download ${1} code"
}


NODEJS() {
component=${1}
 yum install nodejs make gcc-c++ -y
 STAT_CHECK $? "Install NodeJS"

 id roboshop &>>{LOG_FILE}

 if [ $? -ne 0 ]; then
  useradd roboshop &>>{LOG_FILE}
  STAT_CHECK $? "Add Application user"
 fi

 curl -s -L -o /tmp/{component}.zip "https://github.com/roboshop-devops-project/{component}/archive/main.zip" &>>{LOG_FILE}
 STAT_CHECK $? "Download {component}"

cd /tmp

 unzip -o ${1}.zip
 STAT_CHECK $? "unzip ${1} content"

 cd /home/roboshop/${1}

 sudo yum install npm &>>{LOG_FILE}
 STAT_CHECK $? "NPM install"

 chown roboshop:roboshop -R /home/roboshop

 sed -i -e 's/MONGO_DNSNAME/mongo.roboshop.interior/' /home/roboshop/${1}/systemd.service
 STAT_CHECK $? "Update IP address in systemd file"


 mv /home/roboshop/${1}/systemd.service /etc/systemd/system/${1}.service
 STAT_CHECK $? "Moved content in system file"

 systemctl daemon-reload &>>{LOG_FILE} && systemctl start {component} &>>{LOG_FILE} && systemctl enable {component} &>>{LOG_FILE}
 STAT_CHECK $? "Start {component} service"

}