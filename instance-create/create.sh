#!/bin/bash


LID=lt-0dff91f714ca1d54d
LVER=1
#COMPONENT=$1

if [ -z "$1" ]; then
  echo "Component Name INput is needed"
  exit 1
fi

Instance_Create() {
  COMPONENT=$1
  INSTANCE_EXISTS=$(aws ec2 describe-instances --filters Name=tag:Name,Values=${COMPONENT}  | jq .Reservations[])
  STATE=$(aws ec2 describe-instances     --filters Name=tag:Name,Values=${COMPONENT}  | jq .Reservations[].Instances[].State.Name | xargs)
  if [ -z "${INSTANCE_EXISTS}" -o "$STATE" == "terminated"  ]; then
    aws ec2 run-instances --launch-template LaunchTemplateId=${LID},Version=${LVER}  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${COMPONENT}}, {Key=Project,Value=TODO}]" | jq
  else
    echo "Instance ${COMPONENT} already exists"
  fi


  IPADDRESS=$(aws ec2 describe-instances     --filters Name=tag:Name,Values=${COMPONENT}   | jq .Reservations[].Instances[].PrivateIpAddress | grep -v null |xargs)

  sed -e "s/COMPONENT/${COMPONENT}/" -e "s/IPADDRESS/${IPADDRESS}/" record.json >/tmp/record.json
  aws route53 change-resource-record-sets --hosted-zone-id Z02236711B9U9TNUOF7VY --change-batch file:///tmp/record.json
  sed -i -e "/${COMPONENT}/ d" ../inv
  echo "${IPADDRESS} COMPONENT=$(echo ${COMPONENT} | awk -F - '{print $1}')" >>../inv
}

if [ "$1" == "all" ]; then
  for instance in frontend todo login users redis ; do
    Instance_Create $instance-dev
  done
else
  Instance_Create $1-dev
fi

# AKIAWUVJXXHZHFNZUJM4
# 36T77vUlDQ7Uv8VZcz9xSgB3Q/NuekTicKs7aH/L

# key: Name , Value: Deployment 

# AKIAWUVJXXHZBOP4NPUO
# LxX0V2V9XhYkVx9a6qZHdlp4MoKlgiBE4AD0pIPB 
# AKIAWUVJXXHZOF2KWOM3
# z9MtkQ5MVmVUZvQ4FZMNFYgC7WWn7lbBIMFZF4s9