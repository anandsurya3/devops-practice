#!/bin/bash
userid=$(id -u)
if [ $userid -ne 0 ]; then
    echo "ERROR....please take root access"
    exit 1
fi
log_folder="/var/log/packages"
script_name=$( echo $0 | cut -d "." -f1 )
log_file="$log_folder/$script_name"
mkdir -p $log_folder
validate(){
    if [ $1 -ne 0 ]; then
        echo "installing $2 is failed" | tee -a $log_file
        exit 1
    else
        echo "installing $2 is success" | tee -a $log_file
    fi 
}
for packages in $@
do
    dnf list installed $packages &>>$log_file
    if [ $? -ne 0 ]; then
        dnf install $packages -y &>>$log_file
    else
        echo " $packages already installed....SKIPPING"
    fi
done