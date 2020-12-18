#!/bin/zsh
# Script to download and install Kaseya Agent
# Updated from here:
# http://community.kaseya.com/xsp/f/26/t/20211.aspx
# Updated code by Kyle Ericson
# Date Dec 11 2020

#########################################################
# MODIFY VARS FOR YOUR ENV HERE
#########################################################

#Kaseya URL
vsaURL="https://kaseya.yourcompany.com"

# Package ID is found by copying the download link and the string after 'id='
# Example: setupDownload("/mkDefault.asp?id=123456789")
agentID="123456789"

#########################################################
# DO NOT MODIFY BELOW HERE #
#########################################################

# Browser user agent
useragent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11) AppleWebKit/601.1.56 (KHTML, like Gecko) Version/9.0 Safari/601.1.56"

# Download the agent
curl -A "$useragent" "$vsaURL/api/v2.0/AssetManagement/asset/download-agent-package?packageid=$agentID" -H "Connection: keep-alive" --compressed --output /tmp/KcsSetup.zip

# Unzip
unzip /tmp/KcsSetup.zip -d /tmp/

# Apply Permissions
chmod 755 /tmp/Agent/agentsetup.pkg

# Run the installer
sudo installer -pkg /tmp/Agent/agentsetup.pkg -target /

exit 0