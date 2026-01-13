#!/bin/bash
userid=$(id -u)
if [ $userid -ne 0 ]; then
    echo "ERROR please take root access"
    exit 1
fi

funky(){
    if [ $1 -ne 0 ]; then
        echo "deleting $2 is failed"
        exit 1
    else
        echo "deleting $2 is success"
    fi
}
rpm -q mysql
if [ $? -eq 0 ]; then
    dnf remove mysql &>>$log_file
    funky $? "mysql"
else
    echo "mysql package is already deleted"
fi 

rpm -q nginx
if [ $? -eq 0 ]; then
    dnf remove nginx &>>$log_file
    funky $? "nginx"
else
    echo "nginx package is already deleted"
fi