userid=$(id -u)
if [ $userid -ne 0 ]; then
    echo "ERROR...please take root access"
    exit 1
fi
R="\e[31m"
G="\e[32m"
W="\e[0m"
log_folder="/var/lod/shell-roboshop"
script_name=$( echo $0 | cut -d "." -f1 )
log_file="$log_folder/$script_name.log"
mkdir -p $log_folder
SCRIPT_DIR=$PWD
validate(){
    if [ $1 -ne 0 ]; then
        echo -e "$2...$R FAILED $W" | tee -a $log_file
    else
        echo -e "$2...$G SUCCESS $W" | tee -a $log_file
    fi
}
dnf module disable nginx -y &>>$log_file
validate $? "disabling nginx"
dnf module enable nginx:1.24 -y &>>$log_file
validate $? "enabling nginx 1.24"
dnf install nginx -y &>>$log_file
validate $? "installing nginx"
systemctl enable nginx &>>$log_file
validate $? "enabling nginx"
systemctl start nginx
validate $? "starting nginx"
rm -rf /usr/share/nginx/html/* &>>$log_file
validate $? "removing exist code"
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$log_file
validate $? "downloading the code"
cd /usr/share/nginx/html &>>$log_file
validate $? "changing to html directory"
unzip /tmp/frontend.zip &>>$log_file
validate $? "unziping the code"
cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf &>>$log_file
validate $? "changing nginx configration"
systemctl restart nginx 
validate $? "restarting nginx"