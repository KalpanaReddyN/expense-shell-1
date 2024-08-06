#!/bin/bash

source ./common.sh

check_root

echo "Please enter DB password:"
read -s mysql_root_password 

dnf module disable nodejs -y &>>$LOGFILE

dnf module enable nodejs:20 -y &>>$LOGFILE

dnf install nodejs -y &>>$LOGFILE

id expense &>>$LOGFILE                   # useradd expense is not idoempotent bcoz if v run multiple times v get error.
if [ $? -ne 0 ]
then
    useradd expense &>>$LOGFILE 
else
    echo -e "Expense user already created...$Y SKIPPING $N"
fi

mkdir -p /app &>>$LOGFILE               # -p creates is directory is not there, if directoey present it will be normal.

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOGFILE

cd /app
rm -rf /app/*             # this removes all the content in app directory and then it will unzip again. this helps when we try to run again n again
unzip /tmp/backend.zip &>>$LOGFILE

npm install &>>$LOGFILE

#check your repo and path
cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service &>>$LOGFILE

systemctl daemon-reload &>>$LOGFILE

systemctl start backend &>>$LOGFILE

systemctl enable backend &>>$LOGFILE

dnf install mysql -y &>>$LOGFILE

mysql -h db.kalpanadevops.online -uroot -p${mysql_root_password} < /app/schema/backend.sql &>>$LOGFILE

systemctl restart backend &>>$LOGFILE