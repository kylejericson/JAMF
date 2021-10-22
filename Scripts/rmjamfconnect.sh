#!/bin/zsh
#	This will uninstall Jamf Connect and reset the login window
# 	Created by Kyle Ericson
#	Version 1.0

/usr/local/bin/authchanger -reset
rm /usr/local/bin/authchanger
rm /usr/local/lib/pam/pam_saml.so.2
rm -r /Library/Security/SecurityAgentPlugins/JamfConnectLogin.bundle
launchctl unload /Library/LaunchAgents/com.jamf.connect.plist
killall 'Jamf Connect'
rm -rf "/Applications/Jamf Connect.app"

echo "Done removing Jamf Connect"
echo "Open Directory Utility and remove the field: NetworkUserField from all accounts before installing Jamf Connect again"

exit 0
