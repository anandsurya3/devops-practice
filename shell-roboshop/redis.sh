#!/bin/bash

userid=$(id -u)
if [ $userid -ne 0 ]; then
    echo "ERROR...దయచేసి root access తో రన్ చేయండి (Use sudo)"
    exit 1
fi

start_time=$(date +%s)
R="\e[31m"
G="\e[32m"
W="\e[0m"

log_folder="/var/log/shell-roboshop"
# script_name లో పాత్ లేకుండా కేవలం పేరు మాత్రమే వచ్చేలా మార్చాను
script_name=$(basename "$0" | cut -d "." -f1)
log_file="$log_folder/$script_name.log"

# ఫోల్డర్ క్రియేషన్
mkdir -p $log_folder

validate(){
    if [ $1 -ne 0 ]; then
        echo -e "$2...$R విఫలమైంది (Failed) $W" | tee -a $log_file
    else
        echo -e "$2...$G విజయవంతమైంది (Success) $W" | tee -a $log_file
    fi
}

# Redis పాత మాడ్యూల్స్ క్లియర్ చేయడం
dnf module disable redis -y &>>$log_file
validate $? "Redis మాడ్యూల్ డిసేబుల్ చేయడం"

dnf module enable redis:7 -y &>>$log_file
validate $? "Redis 7 మాడ్యూల్ ఎనేబుల్ చేయడం"

dnf install redis -y &>>$log_file
validate $? "Redis ఇన్‌స్టాల్ చేయడం"

# IP Address మార్పు మరియు Protected Mode ఆపడం
# ఇక్కడ sed కమాండ్ ని విడివిడిగా రాస్తే క్లారిటీ ఉంటుంది
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf &>>$log_file
sed -i 's/protected-mode yes/protected-mode no/g' /etc/redis/redis.conf &>>$log_file
validate $? "రిమోట్ కనెక్షన్స్ అనుమతించడం"

systemctl enable redis &>>$log_file
validate $? "Redis ఎనేబుల్ చేయడం"

systemctl start redis &>>$log_file
validate $? "Redis స్టార్ట్ చేయడం"

echo -e "$G స్క్రిప్ట్ పూర్తయింది! $W"