#!/bin/bash

## simple if statement

read -p 'Enter your age: ' age
if [ "${age}" -lt 18]; then
  echo you are a minor
else
  echo you are a major
fi