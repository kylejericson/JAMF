#!/bin/zsh
#	This will uninstall Jamf Connect and reset the login window
# 	Created by Kyle Ericson
#	Version 3.0

# Get the logged in user's name
FAKE_USER=$(/bin/echo "show State:/Users/ConsoleUser" | /usr/sbin/scutil | /usr/bin/awk '/Name :/&&!/loginwindow/{print $3}')
CURRENT_USER=$(id -un $FAKE_USER)

/usr/local/bin/authchanger -reset
rm /usr/local/bin/authchanger
rm /usr/local/lib/pam/pam_saml.so.2
rm -r /Library/Security/SecurityAgentPlugins/JamfConnectLogin.bundle
launchctl bootout /Users/$CURRENT_USER/Library/LaunchAgents/com.jamf.connect.plist
#launchctl unload /Users/$CURRENT_USER/Library/LaunchAgents/com.jamf.connect.plist
rm -rf /Users/$CURRENT_USER/Library/LaunchAgents/com.jamf.connect.plist
killall 'Jamf Connect'
rm -rf "/Applications/Jamf Connect.app"

# Remove network info from user account
dscl . delete /Users/$CURRENT_USER dsAttrTypeStandard:NetworkUser
dscl . delete /Users/$CURRENT_USER dsAttrTypeStandard:OIDCProvider
dscl . delete /Users/$CURRENT_USER dsAttrTypeStandard:OktaUser
dscl . delete /Users/$CURRENT_USER dsAttrTypeStandard:AzureUser

echo "Done removing Jamf Connect"
exit 0