#!/bin/bash

userid=$(id -u)
if [ "$userid" -ne 0 ]; then
    echo "ERROR: please take root access"
    exit 1
fi

log_folder="/var/log/installed-packages"
script_name=$(basename "$0" .sh)
log_file="$log_folder/$script_name.log"

mkdir -p "$log_folder"

validate() {
    if [ "$1" -eq 0 ]; then
        echo "Installing $2 SUCCESS" | tee -a "$log_file"
    else
        echo "Installing $2 FAILED" | tee -a "$log_file"
        exit 1
    fi
}

for package in "$@"
do
    dnf list installed "$package" &>>"$log_file"
    if [ $? -ne 0 ]; then
        echo "Installing $package..." | tee -a "$log_file"
        dnf install -y "$package" &>>"$log_file"
        validate $? "$package"
    else
        echo "$package already installed — SKIPPING" | tee -a "$log_file"
    fi
done
