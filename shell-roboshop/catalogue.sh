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
validate(){
    if [ $1 -ne 0 ]; then
        echo -e "$2...$R FAILED $W" | tee -a $log_file
    else
        echo -e "$2...$G SUCCESS $W" | tee -a $log_file
    fi
}
dnf module disable nodejs -y &>>$log_file
validate $? "disabeling nodejs"
dnf module enable nodejs:20 -y &>>$log_file
validate $? "enabling nodejs:20" 
dnf install nodejs -y &>>$log_file
validate $? "installing nodejs"
id roboshop &>>$log_file
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin/ --comment "roboshop system user" roboshop
    validate $? "adding system user"
else
    echo -e "user already exist...$G SKIPPING $W"
fi
mkdir -p /app
validate $? "creating /app directory"
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$log_file
validate $? "downloading the code"
cd /app
validate $? "changing the /app directory"
rm -rf /app/*
validate $? "Removing exist code"
unzip /tmp/catalogue.zip &>>$log_file
validate $? "unzip the code"
npm install &>>$log_file
validate $? "installing dependencies"
cp PWD/catalogue.service /etc/systemd/system.catalogue.service &>>$log_file
validate $? "creating systemctl services"
systemctl daemon-reload
validate $? "daemon-reloading"
systemctl enable catalogue &>>$log_file
validate $? "enabling catalogue"
systemctl start catalogue
validate $? "starting catalogue"
cp PWD/mongo.repo /etc/mongo.repos.d/mongo.repo
dnf install mongodb-mongosh -y &>>$log_file
validate $? "installing mongodb client"
index=$(mongosh mongodb.daws86s.fun --quiet --eval "db.getMongo().getDBNames().indexOf('catalogue')") &>>$log_file
if [ $index -le 0 ]; then
    mongosh --host mongodb.anandsurya.online </app/db/master-data.js &>>$log_file
    validate $? "load the db"
else
    echo -e "db already loaded...$G SKIPPING $W"
fi
systemctl restart catalogue
validate $? "restarting catalogue"