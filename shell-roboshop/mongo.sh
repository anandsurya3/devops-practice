userid=$(id -u)
R="\e[31m"
G="\e[32m"
W="\3[0m"
if [ $userid -ne 0 ]; then
    echo"ERROR...take root access"
    exit 1
fi

logs_folder="/var/log/shell-roboshop"
script_name=$( echo $0 | cut -d "." -f1 )
log_file="$logs_folder/$script_name.log"
mkdir -p $logs_folder
validate(){
    if [ $1 -ne 0 ]; then
        echo -e "$2...$R FAIL $W" | tee -a $log_file
    else
        echo -e "$2...$G SUCCESS $W" | tee -a $log_file
    fi
}
cp mongo.repo /etc/yum.repos.d/mongo.repo &>>$log_file
dnf install mongo-org -y &>>$logfile
validate $? "installing mongodb"
systemctl enable mongod &>>$logfile
validate $? "enable mongodb"
systemctl start mongod
validate $? "start mongodb"
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
validate $? "allowing connections"
systemctl restart mongod
validate $? "restarting mongodb"