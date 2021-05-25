#!/bin/sh
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 882456490456.dkr.ecr.us-east-1.amazonaws.com
docker build -t myrepo /home/bruno.santos/codes/poc/app-runner/. 

if [ $# -eq 0 ]; then
  docker tag myrepo:latest 882456490456.dkr.ecr.us-east-1.amazonaws.com/myrepo:latest 
  docker push 882456490456.dkr.ecr.us-east-1.amazonaws.com/myrepo:latest
else
  docker tag myrepo:latest 882456490456.dkr.ecr.us-east-1.amazonaws.com/myrepo:$1 
  docker push 882456490456.dkr.ecr.us-east-1.amazonaws.com/myrepo:$1
fi
