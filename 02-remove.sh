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

    dnf remove mysql
    funky $? "mysql"



    dnf remove nginx
    funky $? "nginx"
