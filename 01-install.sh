#!/bin/bash
userid=$(id -u)
echo $userid
if [ $userid -ne 0 ]; then
    echo -e "\e[32m ERROR please take root acces \e[0m"
    exit 1
fi
dnf list installed mysql
if [ $? -eq 0 ]; then
    dnf install mysql -y
    if [ $? -eq 0 ]; then
        echo "installing mysql is failed"
        exit 1
    else
        echo "installing mysql is success"
    fi
else
    echo -e "mysql already installed....\e[33m SKIPPING \e[0m"
fi
dnf list installed nginx
if [ $? -eq 0 ]; then
    dnf install nginx -y
    if [ $? -eq 0 ]; then
        echo "installing mysql is failed"
        exit 1
    else
        echo "insatlling nginx is success"
    fi
else
    echo -e "nginx already installed....\e[33m SKIPPING \e[0m"
fi
  
  echo $0