#!/bin/bash
userid=$(id -u)
echo $userid
if [ $userid -ne 0 ]; then
    echo "ERROR RA BOKKA please take root access"
    exit 1

}
dnf remove mysql -y

dnf remove nginx -y


echo "please enter the number"
read number
if [ $(($number % 2)) -ne 0 ]; then
    echo "given number is odd"
else
    echo "given number is even"
fi

