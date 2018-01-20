#!/bin/sh
ZONEDIR="/etc/bind"
# The DNS service that you are using : bind9, named ...
DNSSERVICE="bind9"

# ZONE : the zone (passed as first argument)
ZONE=$1
# ZONEFILE : the zone file (passed as second argument)
ZONEFILE=$2
# Here we go !
cd $ZONEDIR
# check what's currently loaded
/usr/sbin/named-checkzone $ZONE $ZONEFILE.signed
# Grab serial from zone file
OLDSERIAL=`/usr/sbin/named-checkzone $ZONE $ZONEFILE | egrep -ho '[0-9]{10}'`
# Generate new serial with today's date: YYYYMMDDHH (year, month, day, hour)
NEWSERIAL=`date +%Y%m%d%H -d "today"`
# if $NEWSERIAL is less than or equal to $OLDSERIAL
# then it means the zone file has already been generated today
# so let's compute the difference and increment +1
if [ "$NEWSERIAL" -lt "$OLDSERIAL" ]; then
	DIFF=$(($OLDSERIAL-$NEWSERIAL))
	NEWSERIAL=$(($NEWSERIAL+$DIFF+1))
fi
# Write new serial +1 in zone file
sed -i 's/'$OLDSERIAL'/'$(($NEWSERIAL+1))'/' $ZONEFILE
# Sign zone and increment serial of signed file
/usr/sbin/dnssec-signzone -A -3 $(head -c 1000 /dev/random | sha1sum | cut -b 1-16) -N increment -o $1 -t $2
# restart DNS service to load newly-signed zone file
/etc/init.d/$DNSSERVICE reload
# Show what's currently loaded
/usr/sbin/named-checkzone $ZONE $ZONEFILE.signed
CHECKRESULT=`/usr/sbin/named-checkzone $ZONE $ZONEFILE.signed`
