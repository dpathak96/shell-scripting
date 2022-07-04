#!bin/bash
##echo frontend setup
##Frontend
##The frontend is the service in RobotShop to serve the web content over Nginx.

##To Install Nginx.

# yum install nginx -y
# systemctl enable nginx
# systemctl start nginx
#Let's download the HTML content that serves the RoboSHop Project UI and deploy under the Nginx path.

# curl -s -L -o /tmp/frontend.zip "https://github.com/roboshop-devops-project/frontend/archive/main.zip"
#Deploy in Nginx Default Location.

# cd /usr/share/nginx/html
# rm -rf *
# unzip /tmp/frontend.zip
# mv frontend-main/* .
# mv static/* .
# rm -rf frontend-master static README.md
# mv localhost.conf /etc/nginx/default.d/roboshop.conf
#Finally restart the service once to effect the changes.

# systemctl restart nginx

source Components/common.sh

yum install nginx -y >>${LOG_FILE}
STAT_CHECK $? "Nginx installation"

DOWNLOAD frontend

rm -rf /usr/share/gninx/html/*
STAT_CHECK $? "Remove Old HTML Pages"


cd /tmp/frontend-main/static/ && cp -r * /usr/share/nginx/html/
STAT_CHECK $? "Copying frontend content"

cp /tmp/frontend-main/localhost.conf /etc/nginx/default.d/roboshop.conf
STAT_CHECK $? "Update Nginx Config File"

systemctl enable nginx && systemctl restart nginx &>>${LOG_FILE}
STAT_CHECK $? "Restart Nginx"
