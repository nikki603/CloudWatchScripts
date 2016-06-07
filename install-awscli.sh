#!/bin/bash

echo "Checking for AWS CLI...";
	command -v aws >/dev/null 2>&1 || {
			echo "Installing AWS CLI";
			curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
			sudo apt-get install unzip
			unzip awscli-bundle.zip
			sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
	
			echo "$(tput setaf 3)You must set your default region name for the CloudWatch monitoring to work$(tput sgr 0)";
			aws configure
			complete -C '/usr/local/aws/bin/aws_completer' aws
			
			echo "Cleaning up install files";
			rm awscli-bundle.zip
		}
