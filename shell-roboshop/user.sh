userid=$(id -u)
if [ $userid -ne 0 ]; then
    echo "ERROR...please take root access"
    exit 1
fi
R="\e[31m"
G="\e[32m"
W="\e[0m"
log_folder="/var/log/shell-roboshop"
script_name=$( echo $0 | cut -d "." -f1 )
log_file="$log_folder/$script_name"
mkdir -p $log_folder
SCRIPT_DIR=$PWD
validate(){
    if [ $1 -ne 0 ]; then
        echo -e "$2...$R FAILED $W" | tee -a $log_file
    else
        echo -e "$2...$G SUCCESS $W" | tee -a $log_file
    fi
}
dnf module disable nodejs -y &>>$log_folder
validate $? "disabling nodejs"
dnf module enable nodejs:20 -y &>>$log_folder
validate $? "enabling nodejs"
dnf install nodejs -y &>>$log_folder
validate $? "installing nodejs"
id roboshop &>>$log_folder
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "robosho system user" roboshop &>>$log_folder
    validate $? "adding system user"
else
    echo -e "user already exist...$G SKIPPING $W"
fi
mkdir /app
validate $? "making app directory"
curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip &>>$log_folder
validate $? "downloading the code"
cd /app
validate $? "changing to /app directory"
rm -rf /app/*
validate $? "removing existing code"
unzip /tmp/user.zip &>>$log_folder
validate $? "unziping the code"
npm install &>>$log_folder
validate $? "installing dependencies"
cp $SCRIPT_DIR/user.service /etc/systemd/system/user.service &>>$log_folder
validate $? "creating systemctl service"
systemctl restart user
validate $? "restarting user"
systemctl enable user &>>$log_folder
validate $? "enabling the user"
systemctl start user
validate $? "starting the user"

