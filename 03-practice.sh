#!/bin/bash
userid=$(id -u)
if [ $userid -ne 0 ]; then
    echo "ERROR...plsease take root access"
    exit 1
fi
checking(){
    if [ $1 -ne 0 ]; then
        echo "installing $2 failed"
        exit 1
    else
        echo "installing $2 success"
    fi 
}
dnf install mysql -y
checking $? "mysql"
dnf install nginx -y
checking $? "nginx"
