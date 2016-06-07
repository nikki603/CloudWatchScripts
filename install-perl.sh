#!/bin/bash

echo "Checking for PERL...";
if perl < /dev/null > /dev/null 2>&1 ; then
	echo "PERL detected"	
else
    echo "Installing PERL";
	sudo apt-get install libwww-perl libdatetime-perl
fi
