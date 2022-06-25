#!/bin/bash

userid=$(id -u)
if [ "${userid}" -ne 0 ]; then
 echo you need to be root user to perform this script
exit
fi

echo welcome to the script
