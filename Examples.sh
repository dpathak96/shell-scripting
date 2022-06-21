#!/bin/bash

username=motu

echo Adding user ${username}
useradd ${username}
echo User ${username} sucessfully created
echo Thank you


read -p 'Enter you name: ' name
read -p 'Enter your age: ' age

echo "your Name = ${name}, Your age = $age}"

