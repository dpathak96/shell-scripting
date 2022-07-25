#!bin/bash

source common.sh

echo "--------<<<<<<<catalogue setup>>>>>>>>>---------"

NODEJS catalogue

sudo cd /tmp/catalogue-main && cp server.js /home/roboshop/catalogue/
STAT_CHECK $? "fixed exit code error"