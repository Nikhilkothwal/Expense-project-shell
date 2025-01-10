#!/bin/bash
#Find whether the user is having root permission or not
#Add colours for better User interface
#Create Log foler
#Create validate function to validate every step

UserID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

mkdir -p /var/log/expense.logs

LOG_FOLDER=/var/logs/expense.logs
LOG_FILE=$(echo $0 | cut -d"." -f1)
TIME_STAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOGFILE_NAME="$LOG_FOLDER/$LOG_FILE-$TIME_STAMP.log"

CHECK_ROOT(){
    if [$USERID -ne 0]
    then
        echo -e "$R ERROR : You must have sudo access for to run this command $N"
        exit 1
    fi    
}

VALIDATE(){
    if [$1 -ne 0 ]
    then
        echo "$2... $R FAILURE $N"
        exit 1
    else
        echo "$2.. $G SUCCESS $N" 
}

CHECK_ROOT

dnf install nginx -y &>>$LOGFILE_NAME
VALIDATE $? "Installing nginx"

systemctl enable nginx &>>$LOGFILE_NAME
VALIDATE $? "Enabling nginx"

systemctl start nginx &>>$LOGFILE_NAME
VALIDATE $? "Starting nginx"

rm -rf /usr/share/nginx/html/* &>>$LOGFILE_NAME
VALIDATE $? "Removing existing files "

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOGFILE_NAME
VALIDATE $? "Downloading application is "

cd /usr/share/nginx/html &>>$LOGFILE_NAME
VALIDATE $? "Installing nginx"

unzip /tmp/frontend.zip &>>$LOGFILE_NAME
VALIDATE $? "Installing nginx"

cp /home/ec2-user/Expense-project-shell/frontend.service /etc/nginx/default.d/expense.conf &>>$LOGFILE_NAME
VALIDATE $? "Creating Nginx Reverse Proxy"

systemctl restart nginx &>>$LOGFILE_NAME
VALIDATE $? "Restarting nginx"