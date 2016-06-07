#!/bin/bash

usage() { echo "Usage: $0 [-t <topicARN>]" 1>&2; exit 1; }

#start CloudWatch monitoring and alarms
while getopts ":t:" opt; do
  case $opt in
    t)
      echo "Amazon SNS Topic ARN: $OPTARG" >&2

		#install prereqs
		echo "Installing prerequisites"
		./install-awscli.sh
		./install-perl.sh

	  echo "Starting CloudWatch"
          cd cloudWatchScript
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
