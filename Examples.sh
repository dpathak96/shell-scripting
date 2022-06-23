#!/bin/bash

username=nanu

echo Script to add user $username
useradd $username
echo $username successfully added

ADD=$((2+3))
echo ADD = $ADD


DATE=$(date)
echo Good Morning Everyone, Todays date is ${DATE}