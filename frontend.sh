#!/bin/bash
#Find whether the user is having root permission or not
#Add colours for better User interface
#Create Log foler
#Create validate function to validate every step

UserID=$(id -u)

R="\[e31m"
G="\[e32m"
Y="\[e33m"
N="\[e0m"

mkdir -p /var/log/expense.logs

Log_folder="/var/log/expense.logs"
Log_file=$(echo $0 | cut -d "." -f1)
Timestamp=$(date +%d-%m-%Y-%H-%M-%S)
Log_file_name="$Log_folder/$Log_file-$Timestamp.log"

Validate(){
    if [ $1 -ne 0 ]; then
        echo "$2 ...$R Failure $R"
        exit 1
    else
        echo "$2 ...$G Success $G"
    fi
}

Check_root(){
    if [ UserID -ne 0 ]; then
    echo " $R Error: You should have root access to run this script $R"
    exit 1
    fi
}

dnf install nginx -y &>>$Log_file_name
Validate $? "Installing nginx"

systemctl enable nginx &>>$Log_file_name
Validate $? "Enabling nginx"

systemctl start nginx &>>$Log_file_name
Validate $? "Starting nginx"

rm -rf /usr/share/nginx/html/* &>>$Log_file_name
Validate $? "Removing existing files "

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$Log_file_name
Validate $? "Downloading application is "

cd /usr/share/nginx/html &>>$Log_file_name
Validate $? "Installing nginx"

unzip /tmp/frontend.zip &>>$Log_file_name
Validate $? "Installing nginx"

cp /home/ec2-user/Expense-Shell-Project/frontend.service /etc/nginx/default.d/expense.conf &>>$Log_file_name
Validate $? "Creating Nginx Reverse Proxy"

systemctl restart nginx &>>$Log_file_name
Validate $? "Restarting nginx"