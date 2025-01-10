#!/bin/bash
#check whether the user is root user or not
#create log folder
#Add colours for better user interface

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

echo "the script was run at $TIME_STAMP" &>>$LOGFILE_NAME

CHECK_ROOT

dnf module disable nodejs -y &>>$LOGFILE_NAME
VALIDATE $? "Disabling existing nodejs"

dnf module enable nodejs:20 -y &>>$LOGFILE_NAME
VALIDATE $? "Enabling nodejs 20"

dnf install nodejs -y &>>$LOGFILE_NAME
VALIDATE $? "Installing nodejs"

id expense &>>$LOGFILE_NAME
if [ $? -ne 0 ]
then
    useradd expense &>>$LOGFILE_NAME
    VALIDATE $? "Adding user was"
else
    echo -e "expense user already exists ....$Y Skipping $N"
fi

mkdir -p /app &>>$LOGFILE_NAME
VALIDATE $? "Creating app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOGFILE_NAME
VALIDATE $? "Downloading the backend app"

cd /app
rm -rf /app/*

unzip /tmp/backend.zip &>>$LOGFILE_NAME
VALIDATE $? "Unzipping the file"

npm install &>>$LOGFILE_NAME
VALIDATE $? "Installing npm"

cp /home/ec2-user/Expense-project-shell/backend.service /etc/systemd/system/backend.service
#prepare mysql schema
dnf install mysql -y &>>$LOGFILE_NAME
VALIDATE $? "Installing mysql client"

mysql -h mysql.kothwal.site -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$LOGFILE_NAME
VALIDATE $? "Setting up transactions schema and tables"

systemctl daemon-reload &>>$LOGFILE_NAME
VALIDATE $? "Deamon reload"

systemctl enable backend &>>$LOGFILE_NAME
VALIDATE $? "Enabling backend service"

sudo systemctl restart backend &>>$LOGFILE_NAME
VALIDATE $? "Restarting backend serice"