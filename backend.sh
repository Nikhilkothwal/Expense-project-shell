#!/bin/bash
#check whether the user is root user or not
#create log folder
#Add colours for better user interface

UserID=$(id -u)

R="\[e31m"
G="\[e32m"
Y="\[e33m"
N="\[e0m"

mkdir -p /var/log/expense.logs

Log_folder="/var/log/expense.logs"
Log_file=$(echo $0 | cut -d "." -f1)
Timestamp=$(date +%Y-%m-%d-%H-%M-%S)
Log_file_name="$Log_folder/$Log_file-$Timestamp.log"

Validate(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 ...$R Failure $N"
        exit 1
    else
        echo -e "$2 ...$G Success $N"
    fi
}

Check_root(){
    if [ UserID -ne 0 ]; then
        echo " $R Error: You should have root access to run this script $N"
        exit 1
    fi
}

dnf module disable nodejs -y &>>$Log_file_name
Validate $? "Diabling nodejs"

dnf module enable nodejs:20 -y &>>$Log_file_name
Validate $? "Enabling nodejs"

dnf install nodejs -y &>>$Log_file_name
Validate $? "Installing nodejs"

id expense &>>$Log_file_name

if [ $? -ne 0 ]; then
useradd expense &>>$Log_file_name
Validate $? "Adding user was"
else
echo -e "expense user already exists ....$Y Skipping $N"
fi

mkdir -p /app &>>$Log_file_name
Validate $?"Creating a directory for /app is"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$Log_file_name
Validate $? "Downloading the application"

cd /app &>>$Log_file_name
Validate $? "Change to /app directory"

rm -rf /app/* &>>$Log_file_name
Validate $? "Remove all the existing files in /app"

unzip /tmp/backend.zip &>>$Log_file_name
Validate $? "Unzipping the file in "

npm install &>>$Log_file_name
Validate $? "Installing npm"

cp /home/ec2-user/Expense-Shell-Project/backend.service /etc/systemd/system/backend.service

dnf install mysql -y &>>$Log_file_name
Validate $? "Installing mysql client"

mysql -h database-server.nithinlearning.site -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$Log_file_name
Validate $? "Setting up transactions schema and tables"

systemctl daemon-reload &>>$Log_file_name
Validate $? "Deamon reload"

systemctl enable backend &>>$Log_file_name
Validate $? "Enabling backend service"

sudo systemctl restart backend &>>$Log_file_name
Validate $? "Restarting backend serice"