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

yum install nginx -y >>${LOG_FILE}
STAT_CHECK $? "Nginx installation"

curl -f -s -L -o /tmp/frontend.zip "https://github.com/roboshop-devops-project/frontend/archive/main.zip" >>${LOG_FILE}
STAT_CHECK $? "Download Frontend"

rm -rf /usr/share/gninx/html/*
STAT_CHECK $? "Remove Old HTML Pages"

cd /tmp && unzip /tmp/frontend.zip &>>${LOG_FILE}
STAT_CHECK $? "Extracting NGINX Content"

cd /tmp/frontend-main/static/ && cp -r * /usr/share/nginx/html/
STAT_CHECK $? "Copying frontend content"

cp /ymp/frontend-main/localhost.conf /ect/nginx/default.d/roboshop.conf
STAT_CHECK $? "Update Nginx Config File"

syatemctl start nginx && systemctl restart nginx &>>${LOG_FILE}
STAT_CHECK $? "Restart Nginx"
