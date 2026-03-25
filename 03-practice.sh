#!/bin/bash
sg_id="sg-04ed9a90b34bd15be"
ami_id="ami-0220d79f3f480ecf5"
hostzone_id="Z010927213W8PEK90FFQB"
domain_name="anandsurya.online"
for instance in $@
do
    INSTANCE_ID=$(aws ec2 run-instances --image-id $ami_id --instance-type t3.micro --security-group-ids $sg_id --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query 'Instances[0].InstanceId' --output text)
    if [ $instance != "frontend" ]; then
        ip=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
        record_name="$instance.$domain_name"
    else
        ip=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
        record_name="$domain_name"
    fi
    echo "$instance :: $ip"
    aws route53 change-resource-record-sets \
  --hosted-zone-id $hostzone_id \
  --change-batch '{
    "Changes": [
      {
        "Action": "UPSERT",
        "ResourceRecordSet": {
          "Name": "'$record_name'",
          "Type": "A",
          "TTL": 1,
          "ResourceRecords": [{"Value": "'$ip'"}]
        }
      }
    ]
  }'
done