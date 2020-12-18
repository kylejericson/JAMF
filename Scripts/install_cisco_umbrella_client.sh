#!/bin/bash
#Created by Kyle Ericson
#Date 12/17/2020
#Version 1.0
#Purpose: Download and Install Cisco Umbrella Client

########VARS##########
APIFingerprint=""
APIOrganizationID=""
APIUserID=""
InstallMenubar="true"
########VARS##########

echo "APIFingerprint= $APIFingerprint" > /var/log/cisco_umbrella_client.log
echo "APIOrganization= $APIOrganization" >> /var/log/cisco_umbrella_client.log
echo "APIUser= $APIUser" >> /var/log/cisco_umbrella_client.log
echo "InstallMenubar= $InstallMenubar" >> /var/log/cisco_umbrella_client.log
sudo chmod 755 /var/log/cisco_umbrella_client.log

#check to see if Cisco Umbrella Client is already installed
if [[ -d "/Applications/OpenDNS\ Roaming\ Client/Umbrella\ Diagnostic.app" ]]; then
               echo "Cisco Umbrella Client is already installed, exiting script" >> /var/log/cisco_umbrella_client.log
               exit 0
                              else
               echo "Cisco Umbrella Client not installed, proceeding with install" >> /var/log/cisco_umbrella_client.log
fi

#Download the PKG
curl https://cisco-umbrella-client-downloads.s3.amazonaws.com/mac/production/RoamingClient_MAC.mpkg.zip -o /tmp/RoamingClient_MAC.mpkg.zip >> /var/log/cisco_umbrella_client.log

#Unzip
unzip /tmp/RoamingClient_MAC.mpkg.zip -d /tmp/ >> /var/log/cisco_umbrella_client.log

#Create the Plist
mkdir -p "/Library/Application Support/OpenDNS Roaming Client/" >> /var/log/cisco_umbrella_client.log
cat > "/Library/Application Support/OpenDNS Roaming Client/OrgInfo.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
<key>APIFingerprint</key>
<string>$APIFingerprint</string>
<key>APIOrganizationID</key>
<string>$APIOrganizationID</string>
<key>APIUserID</key>
<string>$APIUserID</string>
<key>InstallMenubar</key>
<$InstallMenubar/>
</dict>
</plist>
EOF

#Install the PKG
sudo installer -pkg /tmp/RoamingClient_MAC_*.pkg -target / >> /var/log/cisco_umbrella_client.log

echo "Cisco Umbrella has been installed" >> /var/log/cisco_umbrella_client.log
exit 0
