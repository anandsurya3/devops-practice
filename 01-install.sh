#!/bin/bash
userid=$(id -u)
echo $userid
if [ $userid -ne 0 ]; then
    echo -e "\e[32m ERROR please take root acces \e[0m"
    exit 1
fi
dnf installed mysql
if [ $? -ne 0 ]; then
    dnf install mysql -y
    if [ $? -ne 0 ]; then
        echo "installing mysql is failed"
        exit 1
    else
        echo "installing mysql is success"
    fi
else
    echo "mysql already installed....SKIPPING"
fi
dnf installed nginx
if [ $? -ne 0 ]; then
    dnf install nginx -y
    if [ $? -ne 0 ]; then
        echo "installing mysql is failed"
        exit 1
    else
        echo "insatlling nginx is success"
    fi
else
    echo "nginx already installed....SKIPPING"
fi
  