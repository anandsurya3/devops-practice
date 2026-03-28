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
dnf module disable nodejs -y &>>$log_file
validate $? "disabling nodejs"
dnf module enable nodejs:20 -y &>>$log_file
validate $? "enabling nodejs"
dnf install nodejs -y &>>$log_file
validate $? "installing nodejs"
id roboshop &>>$log_file
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "robosho system user" roboshop &>>$log_file
    validate $? "adding system user"
else
    echo -e "user already exist...$G SKIPPING $W"
fi
mkdir -p /app
validate $? "making app directory"
curl -L -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip &>>$log_file
validate $? "downloading the code"
cd /app
validate $? "changing to /app directory"
rm -rf /app/*
validate $? "removing existing code"
unzip /tmp/cart.zip &>>$log_file
validate $? "unziping the code"
npm install &>>$log_file
validate $? "installing dependencies"
cp $SCRIPT_DIR/cart.service /etc/systemd/system/cart.service &>>$log_file
validate $? "creating systemctl service"
systemctl daemon-reload
validate $? "daemon-realoding"
systemctl restart cart
validate $? "restarting cart"
systemctl enable cart &>>$log_file
validate $? "enabling the cart"
systemctl start cart
validate $? "starting the cart"