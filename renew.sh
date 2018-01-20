#!/bin/sh

cd /etc/bind/

MAILTO="contact@valentin-deville.eu"
LIST=`ls -l db*.signed | awk '{print $9}'`
ERROR=false
CONTENT=""

for domain in $LIST
do
	domain=`echo $domain |cut -c 4- |rev |cut -c 8- | rev`
	command=`sh /etc/bind/dnssec-zonesigner.sh ${domain} db.${domain}` 
	if [ $? -ne 0 ]; then
		ERROR=true
	fi
	CONTENT="${CONTENT} $command"
done

msg="DNS Zones auto renew."
subject="ERROR: ${ERROR} - ${msg}"

/usr/sbin/sendmail $MAILTO << EOF 
From: DNS1 Server
Subject: ${subject}

${msg}

Report of your renew:

${CONTENT}


Script created by Valentin DEVILLE (https://github.com/MyTheValentinus) 
EOF
