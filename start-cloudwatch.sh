# Assumes using AMI image 'ubuntu-with-cloudwatch-scripts'
# AWS CLI and PERL already installed. Scripts in cloudWatchScript folder.
# chmod 755 complete on script files to execute.
# Default region name set to us-east-1
# Amazon SNS Topic ARN already exists that emails GNOC
# To execute: ~/cloudWatchScript/start-cloudwatch.sh -t <topicARN>

#!/bin/bash

usage() { echo "Usage: $0 [-t <topicARN>]" 1>&2; exit 1; }

startMonitor() {
	echo "Creating Cloudwatch custom metrics";
	crontab -l > monitorCron;
	echo "*/5 * * * * ~/cloudWatchScript/aws-scripts-mon/mon-put-instance-data.pl --mem-util --disk-space-util --disk-path=/ --from-cron" >> monitorCron;
	crontab monitorCron
	rm monitorCron
	echo "Reporting metrics every 5 minutes";
}

getInstanceMetadata() {

	if [ -f "$/var/tmp/aws-mon/instance-id" ]; then
		rm /var/tmp/aws-mon/instance-id
	fi
	ec2InstanceId=$(ec2metadata --instance-id | cut -d " " -f 2);
	echo "InstanceID: "  $ec2InstanceId;
	ec2Name=$(ec2metadata --local-hostname);
	echo "Instance Hostname:"  $ec2Name;

	disk=$(/bin/df -k -l -P / | grep /dev/disk | awk '{print $1}');
	echo "Instance Filesystem:" $disk;
}

createAlarms() {
	echo "Creating alarms...";
	if [ -n "$ec2InstanceId" -a -n "$ec2Name" ]; then

		if [ -n "$disk" ]; then
			aws cloudwatch put-metric-alarm \
			--alarm-name "$ec2Name-DiskUtil-75" \
			--alarm-description "Alarm when Disk Space Used exceeds 75%" \
			--metric-name DiskSpaceUtilization \
			--namespace System/Linux \
			--statistic Average \
			--period 300 \
			--threshold 75 \
			--comparison-operator GreaterThanThreshold \
			--dimensions Name=Filesystem,Value=$disk Name=MountPath,Value=/ Name=InstanceId,Value=$ec2InstanceId \
			--evaluation-periods 2 \
			--alarm-actions $OPTARG \
			--unit Percent
			echo "Created $ec2Name-DiskUtil-75 alarm";

			aws cloudwatch put-metric-alarm \
			--alarm-name "$ec2Name-DiskUtil-50" \
			--alarm-description "Alarm when Disk Space Used exceeds 50%" \
			--metric-name DiskSpaceUtilization \
			--namespace System/Linux \
			--statistic Average \
			--period 300 \
			--threshold 50 \
			--comparison-operator GreaterThanThreshold \
			--dimensions Name=Filesystem,Value=$disk Name=MountPath,Value=/ Name=InstanceId,Value=$ec2InstanceId \
			--evaluation-periods 2 \
			--alarm-actions $OPTARG \
			--unit Percent
			echo "Created $ec2Name-DiskUtil-50 alarm";
		else
			echo "$(tput setaf 1)DiskSpaceUtilization alarms not created. \
		 Missing filesystem name$(tput sgr 0)";
		fi

		aws cloudwatch put-metric-alarm --alarm-name $ec2Name-CPUUtil-75 \
		--alarm-description "Alarm when CPU exceeds 75%" \
		--metric-name CPUUtilization \
		--namespace AWS/EC2 \
		--statistic Average --period 300 --threshold 75 \
		--comparison-operator GreaterThanThreshold  \
		--dimensions  Name=InstanceId,Value=$ec2InstanceId \
		--evaluation-periods 2 \
		--alarm-actions $OPTARG \
		--unit Percent
		echo "Created $ec2Name-CPUUtil-75 alarm";

		aws cloudwatch put-metric-alarm --alarm-name $ec2Name-CPUUtil-50 \
		--alarm-description "Alarm when CPU exceeds 50%" \
		--metric-name CPUUtilization \
		--namespace AWS/EC2 \
		--statistic Average --period 300 --threshold 50 \
		--comparison-operator GreaterThanThreshold  \
		--dimensions  Name=InstanceId,Value=$ec2InstanceId \
		--evaluation-periods 2 \
		--alarm-actions $OPTARG \
		--unit Percent
		echo "Created $ec2Name-CPUUtil-50 alarm"; 

		aws cloudwatch put-metric-alarm --alarm-name $ec2Name-MemoryUtil-50 \
		--alarm-description "Alarm when Memory Usage exceeds 50%" \
		--metric-name MemoryUtilization \
		--namespace System/Linux \
		--statistic Average --period 300 --threshold 50 \
		--comparison-operator GreaterThanThreshold  \
		--dimensions  Name=InstanceId,Value=$ec2InstanceId \
		--evaluation-periods 2 \
		--alarm-actions $OPTARG \
		--unit Percent
		echo "Created $ec2Name-MemoryUtil-50 alarm";

		aws cloudwatch put-metric-alarm --alarm-name $ec2Name-MemoryUtil-75 \
		--alarm-description "Alarm when Memory Usage exceeds 75%" \
		--metric-name MemoryUtilization \
		--namespace System/Linux \
		--statistic Average --period 300 --threshold 75 \
		--comparison-operator GreaterThanThreshold  \
		--dimensions  Name=InstanceId,Value=$ec2InstanceId \
		--evaluation-periods 2 \
		--alarm-actions $OPTARG \
		--unit Percent
		echo "Created $ec2Name-MemoryUtil-75 alarm";
	else
		echo "$(tput setaf 1)Cloudwatch alarms not created. \
	 Missing parameters$(tput sgr 0)";
	fi
}

while getopts ":t:" opt; do
  case $opt in
    t)
      echo "Amazon SNS Topic ARN: $OPTARG" >&2
	  
	  startMonitor
	  getInstanceMetadata
	  createAlarms
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