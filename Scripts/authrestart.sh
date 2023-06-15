#!/bin/sh

# Created by Kyle Ericson

# Update with your username & password
username="kyleericson"
password="pass"

# Create the plist file
plutil -create xml1 /tmp/fv.plist
plutil -insert 'Username' -string "${username}" /tmp/fv.plist
plutil -insert 'Password' -string "${password}" /tmp/fv.plist

# Set permissions
chmod 755 /tmp/fv.plist

# Use the plist file as input for the fdesetup command
cat /tmp/fv.plist | sudo fdesetup authrestart -delayminutes -1 -inputplist

exit 0