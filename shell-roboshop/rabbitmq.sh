userid=$(id -u)
if [ $userid -ne 0 ]; then
    echo " ERROR...please take root access"
    exit 1
fi
log_folder="/var/log/shell-robosho"
script_name=$( echo $0 | cut -d "." -f1 )
log_file="$log_folder/$script_name"
mkdir -p $log_folder
R="\e[31m"
G="\e[32m"
W="\e[0m"
validate(){
    if [ $1 -ne 0 ]; then
        echo -e "$2...$R FIALED $W" | tee -a $log_folder
    else
        echo -e "$2...$G SUCCESS $W" | tee -a $log_folder
    fi
}
cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>>$log_file
validate $? " adding repo"
dnf install rabbitmq-server &>>$log_file
validate $? "installing rabbitmq-server"
systemctl enable rabbitmq-server &>>$log_file
validate $? "enabling rabbitmq-server"
systemctl start rabbitmq-server
validate $? "starting rabbitmq-server"
rabbitmqctl add_user roboshop roboshop123 &>>$log_file
validate $? "adding roboshop user"
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$log_file
validate $? "setting passwd"
