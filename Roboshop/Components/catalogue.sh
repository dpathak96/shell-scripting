!#bin/bash

source Components/common.sh

yum install nodejs make gcc-c++ -y &>>${LOG_FILE}
STAT_CHECK $? "Install NodeJS"

useradd roboshop &>>${LOG_FILE}
STAT_CHECK $? "Add application user"

DOWNLOAD() {
  curl -s -L -o /tmp/${1}.zip "https://github.com/roboshop-devops-project/${1}/archive/main.zip" &>>${LOG_FILE}
  STAT_CHECK $? "Download ${1} code"
}

DOWNLOAD catalogue


