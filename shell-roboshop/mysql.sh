userid=$(id -u)
if [ $userid -ne 0 ]; then
    echo "ERROR...please take root access"
    exit 1
fi
log_folder="/var/log/shell-roboshop"
script_name=$( echo $0 | cut -d "." -f1 )
log_file="$log_folder/$script_name"
mkdir -p $log_folder
R="\e[31m"
G="\e[32m"
W="\e[0m"
validate(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 ...$R FAILED $W" | tee -a $log_file
    else
        echo -e $2...$G SUCCESS $W | tee -a $log_file
    fi

}
dnf install mysql-server -y &>>$log_file
validate $? "installing mysql server"
systemctl enable mysql
validate $? "enabling mysql" &>>$log_file
systemctl start mysql
validate $? "starting mysql"
mysql_secure_installation --set-root-pass surya123
validate $? "setup mysql password"