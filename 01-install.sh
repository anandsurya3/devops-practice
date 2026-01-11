#!/bin/bash
userid=$(id -u)
if [ $userid -ne 0 ]; then
    echo -e "\e[31m ERROR please take access \e[0m"
    exit 1
fi
log_folder="/var/log/shell-practice2"
script_name=$( echo $0 cut | -d "." -f1 )
log_file=$log_folder/$script_name
mkdir -p $log_folder
checking(){
    if [ $1 -ne 0 ]; then  
        echo "installing $2 is failed"
        exit 1
    else
        echo "installing $2 is success"
    fi
}
dnf list installed mysql &>>$log_file
if [ $? -ne 0 ]; then
    dnf install mysql -y &>>$log_file
    checking $? "mysql"
else 
    echo "mysql is already installed....SKIPPING"
fi
dnf list installed nginx &>>$log_file
if [ $? -ne 0 ]; then
    dnf install nginx -y &>>$log_file
    checking $? "nginx"
else
    echo "nginx is already installed....SKIPPING"
fi