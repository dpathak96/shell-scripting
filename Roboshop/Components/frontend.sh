#!bin/bash

source common.sh

yum install nginx -y >>${LOG_FILE}
STAT_CHECK $? "Nginx installation"

DOWNLOAD frontend

rm -rf /usr/share/gninx/html/*
STAT_CHECK $? "Remove Old HTML Pages"

cd /tmp && unzip -o /tmp/frontend.zip &>>{LOG_FILE}
STAT_CHECK $? "Extracting frontend content"

cd /tmp/frontend-main/static/ && cp -r * /usr/share/nginx/html/
STAT_CHECK $? "Copying frontend content"

cp /tmp/frontend-main/localhost.conf /etc/nginx/default.d/roboshop.conf
STAT_CHECK $? "Update Nginx Config File"

systemctl enable nginx && systemctl restart nginx &>>${LOG_FILE}
STAT_CHECK $? "Restart Nginx"
