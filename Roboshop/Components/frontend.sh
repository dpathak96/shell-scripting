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

sed -i -e '/catalogue/ s/localhost/catalogue.roboshop.interior/' \
    -i -e '/cart/ s/localhost/cart.roboshop.interior/' \
    -i -e '/user/ s/localhost/user.roboshop.interior/' \
    -i -e '/shipping s/localhost/shipping.roboshop.interior/' \
    -i -e '/payment/ s/localhost/payment.roboshop.interior/' /etc/nginx/default.d/roboshop.conf


systemctl enable nginx && systemctl restart nginx &>>${LOG_FILE}
STAT_CHECK $? "Restart Nginx"
