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

SYSTEMD_SETUP() {
  component=${1}
  chown roboshop:roboshop -R /home/Roboshop

  sudo sed -i -e 's/MONGO_DNSNAME/mongo.roboshop.interior/' \
          -e 's/REDIS_ENDPOINT/redis.roboshop.interior/' \
          -e 's/MONGO_ENDPOINT/mongo.roboshop.interior/' \
          -e 's/CATALOGUE_ENDPOINT/catalogue.roboshop.interior/' \
          -e 's/CART_ENDPOINT/cart.roboshop.interior/' \
          -e 's/DB_HOST/mysql.roboshop.interior/' \
          -e 's/CARTHOST/cart.roboshop.interior/' \
          -e 's/USERHOST/user.roboshop.interior/' \
          -e 's/AMQPHOST/rabbitmq.roboshop.interior/' /home/Roboshop/${1}/systemd.service
  STAT_CHECK $? "Update IP address in systemd file"

  mv /home/Roboshop/${1}/systemd.service /etc/systemd/${1}.service
  STAT_CHECK $? "Moved content in system file"

  systemctl daemon-reload &>>{LOG_FILE} && systemctl start ${1} &>>{LOG_FILE} && systemctl enable ${1} &>>{LOG_FILE}
  STAT_CHECK $? "Start ${1} service"
}


APP_USER_SETUP() {
component=${1}
 id roboshop &>>{LOG_FILE}

 if [ $? -ne 0 ]; then
  useradd roboshop &>>{LOG_FILE}
  STAT_CHECK $? "Add Application user"
 fi
}

DOWNLOAD() {
component=${1}
  curl -s -L -o /tmp/${1}.zip "https://github.com/roboshop-devops-project/${1}/archive/main.zip" &>>${LOG_FILE}
  STAT_CHECK $? "Download ${1} code"
  cd /tmp
  unzip -o ${1}.zip &>>{LOG_FILE}
  STAT_CHECK $? "unzip ${1} content"
}


NODEJS() {
 component=${1}
 yum install nodejs make gcc-c++ -y &>>{LOG_FILE}
 STAT_CHECK $? "Install NodeJS"

APP_USER_SETUP ${1}

 DOWNLOAD ${1}

 rm -rf /home/Roboshop && mkdir /home/Roboshop && mkdir /home/Roboshop/${1}
 STAT_CHECK $? "Copy ${1} Content"

cd /home/Roboshop/${1} && sudo yum install npm -y &>>{LOG_FILE}
 STAT_CHECK $? "NPM install"


 sudo mv /tmp/${1}-main/systemd.service /home/Roboshop/${1}/
 STAT_CHECK $? "Fetched system file"

 SYSTEMD_SETUP ${1}

}

JAVA() {
  component=${1}
  yum install maven -y
  STAT_CHECK $? "Installing Maven"

 APP_USER_SETUP ${1}

 DOWNLOAD ${1}

 rm -rf /home/Roboshop && mkdir /home/Roboshop && mkdir /home/Roboshop/${1}
 STAT_CHECK $? "Copy ${1} Content"

 sudo mv /tmp/${1}-main/* /home/Roboshop/${1}
 STAT_CHECK $? "Fetched system file"

 cd /home/Roboshop/${1} && mvn clean package && mv target/${1}-1.0.jar ${1}.jar &>>{LOG_FILE}
 STAT_CHECK $? "Compile Java Code"


 SYSTEMD_SETUP ${1}

}

PYTHON() {
  component=${1}
  yum install python36 gcc python3-devel -y &>>{LOG_FILE}
  STAT_CHECK $? "Install python Repo"

  APP_USER_SETUP

  DOWNLOAD ${1}

  rm -rf /home/roboshop/${1} && mkdir -p /home/Roboshop/${1} && cp -r /tmp/${1}-main/* /home/Roboshop/${1}/systemd.service.  &>>{LOG_FILE}

  cd /home/Roboshop/payment && pip3 install -r requirements.txt &>>{LOG_FILE}
  STAT_CHECK $? "Install Python dependencies"

  SYSTEMD_SETUP ${1}
}


GOLANG() {
  component=${1}
  yum install golang -y &>>{LOG_FILE}
  STAT_CHECK $? "install GOLANG"

  APP_USER_SETUP

  DOWNLOAD ${1}

  rm -rf /home/roboshop/${1} && mkdir -p /home/Roboshop/${1} && cp -r /tmp/${1}-main/* /home/Roboshop/${1}/systemd.service. &>>{LOG_FILE}

  cd /home/Roboshop/${1} && go mod init dispatch && go get &&  go build

  SYSTEMD_SETUP
}