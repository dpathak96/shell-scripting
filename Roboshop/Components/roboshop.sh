#!/bin/bash

user_id=$(id -u)
if [ "${user_id}" -ne 0 ]; then
  echo you should be root user to perform this script
  exit
fi

export COMPONENT=$1
if [ -z "${COMPONENT}" ]; then
  echo Component input missing
  exit
fi

if [ ! -e Components/${COMPONENT}.sh ]; then
  echo Given component script doesnot exist
  exit
fi

bash Components/${COMPONENT}.sh