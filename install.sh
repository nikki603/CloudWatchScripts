#!/bin/bash

usage() { echo "Usage: $0 [-t <topicARN>]" 1>&2; exit 1; }

#start CloudWatch monitoring and alarms
while getopts ":t:" opt; do
  case $opt in
    t)
      echo "Amazon SNS Topic ARN: $OPTARG" >&2
	  
	  # set permissions
		echo "Setting permissions"
		chmod 755 ~/cloudWatchScript/*.sh

		#install prereqs
		echo "Installing prerequisites"
		cd cloudWatchScript
		./install-awscli.sh
		./install-perl.sh
	  
	  echo "Starting CloudWatch"
	  ./start-cloudwatch.sh -t $OPTARG
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

if [ -n $OPTARG ]; then
  usage
fi