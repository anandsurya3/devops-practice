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
dnf install python3 gcc python3-devel -y &>>$log_file
id roboshp &>>$log_file
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$log_file
    validate $? "adding system user"
else
    echo -e "user already exist...$G SKIPPING $W"
fi
mkdir -p /app 
validate $? "creating /app directory"
curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>>$log_file
validate $? "downloading the code"
cd /app
validate $? "changing to /app directory"
unzip /tmp/payment.zip &>>$log_file
validate $? "unziping the code"
pip3 install -r requirements.txt &>>$log_file
validate $? "installing the dependencies"
cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service &>>$log_file
validate $? "creating the systemctl service"
systemctl daemon-reload
validate $? "daemon-reloading"
systemctl enable payment &>>$log_file
validate $? "enabilng payment"
systemctl start payment
validate $? "starting payment"