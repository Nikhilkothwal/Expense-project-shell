#!/bin/bash

#Check whether the user is having root permission or not
#Add colours for better User interface
#Create a Log folder
#Create a validate function to validate last step

USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\[e33m"
N="\e[0m"

mkdir -p /var/logs/expense.logs

LOG_FOLDER=/var/logs/expense.logs
LOG_FILE=$(echo $0 | cut -d"." -f1)
TIME_STAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOGFILE_NAME="$LOG_FOLDER/$LOG_FILE-$TIME_STAMP.log"

CHECK_ROOT(){
    if [$USERID -ne 0 ]
    then
        echo -e "$R ERROR : You must have sudo access for to run this command $N"
        exit 1
    fi    
}

VALIDATE(){
if [$1 -ne 0 ]
then
        echo -e "$2... $R FAILURE $N"
        exit 1
    else
        echo -e "$2.. $G SUCCESS $N" 
    fi
}

CHECK_ROOT

echo "the script was running at: $TIME_STAMP" &>>LOGFILE_NAME

dnf install mysql -y &>>LOGFILE_NAME
VALIDATE $? "Installing mysql.."

systemctl enable mysqld&>>LOGFILE_NAME
VALIDATE $? "enabling mysql is.."

systemctl start mysqld&>>LOGFILE_NAME
VALIDATE $? "starting mysql is"

systemctl status mysqld&>>LOGFILE_NAME
VALIDATE $? "Starting mysql.."

mysql -h mysql.kothwal.site -u root -pExpenseApp@1 -e 'show databases;' &>>LOGFILE_NAME

if [$? -ne 0]
then
    echo "mysql root user setup was not successful"&>>LOGFILE_NAME
    mysql_secure_installation --set-root-pass ExpenseApp@1
    VALIDATE $? "setup of root user is"
else
    echo -e "mysql root password was already setup $Y SKIPPING $Y"
fi

