#!/bin/bash
userid=$(id -u)
echo $userid
if [ $userid -ne 0 ]; then
    echo "ERROR please take root access"
    exit 1
fi
log_folder="/var/log/installed-packages"
scripit_name=$( echo $0 | cut -d "." -f1 )
log_file=$log_folder/$scripit_name
mkdir -p $log_folder
validate(){
    if [ $1 - eq 0 ]; then
        echo " installing $2 is success"
    else
        echo " installing $2 is failed"
        exit 1
    fi
}
for package in $@
do
echo package is : $package
done