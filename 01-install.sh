#!/bin/bash
USERID=$(id -u)
echo $USERID
if [ $USERID -ne 0 ]; then
    echo "ERROR please take rrot access"
    exit 1
fi
anand(){
    if [ $1 -ne 0 ]; then 
        echo "installin $2 failed"
        exit 1
    else
        echo "installing $2 success"
    fi
}
dnf install mysql -y
anand $? "mysql"
dnf install nginx -y
anand $? "nginx"
dnf install java -y
anand $? "java"
