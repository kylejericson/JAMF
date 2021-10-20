#!/bin/zsh
#	This will uninstall Jamf Connect and reset the login window
# 	Created by Kyle Ericson


/usr/local/bin/authchanger -reset
rm /usr/local/bin/authchanger
rm /usr/local/lib/pam/pam_saml.so.2
rm -r /Library/Security/SecurityAgentPlugins/JamfConnectLogin.bundle

exit 0
