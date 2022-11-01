#!/bin/bash
# Created by Kyle Ericson
# Add admin rights to current user

U1=$(/bin/echo "show State:/Users/ConsoleUser" | /usr/sbin/scutil | /usr/bin/awk '/Name :/&&!/loginwindow/{print $3}')
U2=$(id -un $U1)
echo "Current username is:$U2"
/usr/sbin/dseditgroup -o edit -a $U2 -t user admin
dscl . -append /groups/admin GroupMembership $U2
exit 0