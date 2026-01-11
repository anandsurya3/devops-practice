#!/bin/bash
userid=$(id -u)
echo $userid
if [ $userid -ne 0 ]; then
    echo -e "\e[31m ERROR please take root access \e[0m"
    exit 1
fi
log_folder="/var/log/shell-practice"
script_name=$( echo $0 | cut -d "." -f1 )
log_file=$log_folder/$script_name.log
mkdir -p $log_folder 
validate(){
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
    validate $? "mysql"
else
    echo -e " mysql is already installed....\e[33m SKIPPING \e[0m"
fi
dnf list installed nginx &>>$log_file
if [ $? -ne 0 ]; then
    dnf install nginx -y &>>$log_file
    validate $? "nginx"
else
    echo -e "nginx is already installed....\e[33m SKIPPING \e[0m"
fi