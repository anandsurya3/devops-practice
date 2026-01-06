#!/bin/bash
userid=$(id -u)
echo $userid
if [ $userid -ne 0 ]; then
    echo "ERROR RA BOKKA please take root access"
    exit 1
fi
surya(){
    if [ $1 -ne 0 ]; then
        echo "deleting $2 is failed"
        exit 1
    else
        echo "deleting $2 is success"
    fi 
}
dnf remove mysql -y
surya $? "mysql"
dnf remove nginx -y
surya $? "nginx"
dnf remove java -y
surya $? "java"

echo "please enter the number"
read number
if [ $(($number % 2)) -eq 0 ]; then
    echo "given number is even"
else
    echo "given number is odd"
fi
for i in {1..12}
do
echo $i
done
