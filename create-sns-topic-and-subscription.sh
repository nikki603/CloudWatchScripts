# Create a new Amazon SNS topic and email subscription
# An email will be sent to the email address provided to confirm the subscription. 
# Confirm within 2 hours.

#!/bin/bash

usage() { echo "Usage: $0 [-t <topicName>] [-e <emailAddress>]" 1>&2; exit 1; }

while getopts ":t:e:" opt; do
  case $opt in
    t)
	  topicName=${OPTARG}
	  echo "Amazon SNS Topic Name: $topicName" >&2
      ;;
	e)
	  email=${OPTARG}
	  echo "Email address: $email" >&2
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
	  usage
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
	  usage
      exit 1
      ;;
  esac
done
shift $((OPTIND-1))

if [ -n $topicName -a -n $email ]; then
	topicArn=$(aws sns create-topic --name $topicName --query 'TopicArn' --output text);

	if [ -n $topicArn ]; then
		echo "Topic: "$topicArn " created";
		aws sns subscribe --topic-arn $topicArn --protocol email --notification-endpoint $email
	fi

else
	usage
fi
