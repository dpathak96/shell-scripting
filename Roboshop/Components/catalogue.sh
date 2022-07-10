#!bin/bash

echo "--------<<<<<<<catalogue setup>>>>>>>>>---------"

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

DOWNLOAD() {
  curl -s -L -o /tmp/${1}.zip "https://github.com/roboshop-devops-project/${1}/archive/main.zip" &>>${LOG_FILE}
  STAT_CHECK $? "Download ${1} code"
}

DOWNLOAD catalogue

yum install nodejs make gcc-c++ -y
STAT_CHECK $? "Install NodeJS"

useradd roboshop &>>${LOG_FILE}
STAT_CHECK $? "Add application user"
