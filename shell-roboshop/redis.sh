userid=$(id -u)
if [ $userid -ne 0 ]; then
    echo "ERROR...pls take root access"
    exit 1
fi
start_time=$(date +%s)
G="\e[31m"
R="\e[32m"
W="\e[0m"
log_folder="/var/log/shell-roboshop"
script_name=$( echo $0 | cut -d "." -f1 )
log_file="$log_folder/$script_name.log"
mkdir -p $log_folder
validate(){
    if [ $1 -ne 0 ]; then
        echo -e "$2...$R fialed $W" | tee -a $log_file
    else
        echo -e "$2...$G success $W" | tee -a $log_file
    fi
}
dnf module disable redis -y &>>$log_file
validate $? "disabling redis"
dnf module enable redis:7 -y &>>$log_file
validate $? "enabling redis"
dnf install redis -y &>>$log_file
validate $? "installing redis"
sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c proctect-mode no' /etc/redis/redis.conf
validate $? "allowing connections and changed protected mode"
systemctl enable redis &>>$log_file
validate $? "enabling redis"
systemctl start redis
validate $? "starting redis"