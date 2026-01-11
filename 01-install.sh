#!/bin/bash
userid=$(id -u)
echo $userid
if [ $userid -ne 0 ]; then
    echo -e "\e[31m ERROR please take root access \e[0m"
    exit 1
fi
validate(){
    if [ $1 -ne 0 ]; then
        echo "installing $2 is failed"
        exit 1
    else
        echo "installing $2 is success"
    fi 
}
dnf list installed mysql
if [ $? -ne 0 ]; then 
    dnf install mysql -y
    validate $? "mysql"
else
    echo -e " mysql is already installed....\e[31m SKIPPING \e[0m"
fi
dnf list installed nginx
if [ $? -ne 0 ]; then
    dnf install nginx -y
    validate $? "nginx"
else
    echo -e "nginx is already installed....\e[31m SKIPPING \e[0m"
fi