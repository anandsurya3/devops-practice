#!/bin/bash
userid=$(id -u)
if [ $userid -ne 0 ]; then
    echo "ERROR please take root access"
    exit 1
fi
dnf remove mysql -y
dnf remove nginx -y