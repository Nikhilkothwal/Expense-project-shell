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

LOG_FOLDER="/var/logs/expense-logs"
LOG_FILE=$(echo $0 | cut -d "." -f1)
TIME_STAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOGFILE_NAME="$LOG_FOLDER/$LOG_FILE-$TIME_STAMP.log"

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2... $R FAILURE $N"
        exit 1
    else
        echo -e "$2.. $G SUCCESS $N" 
    fi
}

CHECK_ROOT(){
    if [ $USERID -ne 0 ]
    then
        echo -e "ERROR :: You must have sudo access for to run this command"
        exit 1
    fi    
}

mkdir -p $LOG_FOLDER
echo "the script was run at $TIME_STAMP"&>>$LOGFILE_NAME

CHECK_ROOT

dnf install nginx -y &>>$LOGFILE_NAME
VALIDATE $? "Installing nginx"

systemctl enable nginx &>>$LOGFILE_NAME
VALIDATE $? "Enabling nginx"

systemctl start nginx &>>$LOGFILE_NAME
VALIDATE $? "Starting nginx"

rm -rf /usr/share/nginx/html/* &>>$LOGFILE_NAME
VALIDATE $? "Removing existing version"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOGFILE_NAME
VALIDATE $? "Downloading application"

cd /usr/share/nginx/html &>>$LOGFILE_NAME
VALIDATE $? "moving to HTML directory"

unzip /tmp/frontend.zip &>>$LOGFILE_NAME
VALIDATE $? "unzipping the frontend code"

cp /home/ec2-user/Expense-project-shell/frontend.service /etc/nginx/default.d/expense.conf &>>$LOGFILE_NAME
VALIDATE $? "copied frontend service"

systemctl restart nginx &>>$LOGFILE_NAME
VALIDATE $? "Restarting nginx"