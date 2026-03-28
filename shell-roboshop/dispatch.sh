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
dnf install golang -y &>>$log_file
validate $? "installing golang"
id roboshop &>>$log_file
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nolgin --comment "roboshop system user" roboshop &>>$log_file
    validate $? "adding system user"
else
    echo -e "user already exist...$G SKIPPING $W"
fi
mkdir -p /app
validate $? "creating /app directory"
curl -L -o /tmp/dispatch.zip https://roboshop-artifacts.s3.amazonaws.com/dispatch-v3.zip &>>$log_file
validate $? "downloading the code"
cd /app
validate $? "changing /app directory"
rm -rf /app/* &>>$log_file
validate $? "removing exist code"
unzip /tmp/dispatch.zip &>>$log_file
validate $? "unziping the code"
go mod init dispatch &>>$log_file
validate $? "installing dependencies"
go get &>>$log_file
validate $? "go get"
go build &>>$log_file
validate $? "go build"
cp $SCRIPT_DIR/dispatch.service /etc/systemd/system/dispatch.service &>>$log_file
validate $? "creating systemctl service"
systemctl daemon-reload
validate $? "daemon-reloading"
systemctl enable dispatch &>>$log_file
validate $? "enabling dispatch"
systemctl start dispatch
validate $? "starting dispatch"