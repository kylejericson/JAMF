#!/bin/zsh

# Credits to Sean Rabbitt with original version
# Updated by Kyle Ericson on 6/10/25 to address the DMG rename from Jamf.

# Vendor supplied DMG file
VendorDMG="JamfConnect.dmg"
VendorCDR="JamfConnect.cdr"

# Temp Path
TMP_PATH=/private/tmp

# Jamf Connect Mounted Volume Name
JamfConnectVOLUME=/Volumes/JamfConnectLogin

# Jamf Connect installer package name as found in the DMG
INSTALLER_FILENAME="JamfConnectLogin.pkg"

# Launch Agent installer package name as found in the DMG
LAUNCHAGENT_FILENAME="JamfConnectLaunchAgent.pkg"

# Change installer filename to include full path
INSTALLER_FILENAME=$(echo "$JamfConnectVOLUME/$INSTALLER_FILENAME")
# Change lauchagent filename to include full path
LAUNCHAGENT_FILENAME=$(echo "$JamfConnectVOLUME/Resources/$LAUNCHAGENT_FILENAME")

# If we're coming in from Jamf Pro, we should have been passed a target mount point.  Otherwise, assume root directory is target drive
TARGET_MOUNT=$3
if [ -z "$TARGET_MOUNT" ]; then 
	TARGET_MOUNT="/"
fi 

# Download vendor supplied DMG file into /tmp/
/usr/bin/curl https://files.jamfconnect.com/$VendorDMG -o "$TMP_PATH"/"$VendorDMG" > /dev/null

# Convert .dmg file to accept the license silently
/usr/bin/hdiutil convert -quiet "$TMP_PATH"/"$VendorDMG" -format UDTO -o "$TMP_PATH"/"$VendorCDR"

# Mount vendor supplied DMG File
/usr/bin/hdiutil attach "$TMP_PATH"/"$VendorCDR" -nobrowse -quiet

# Copy PKG
cp -R $INSTALLER_FILENAME /tmp/JamfConnect.pkg

# Unmount JamfConnect Volume
/usr/bin/hdiutil detach "$JamfConnectVOLUME"

# Remove the downloaded vendor supplied DMG file
rm -f "$TMP_PATH"/"$VendorDMG"
rm -f "$TMP_PATH"/"$VendorCDR"


# Jamf Connect installer package name and where we've placed it with this 
INSTALLER_FILENAME="/private/tmp/JamfConnect.pkg"

# Target mount point
TARGET_MOUNT=$3
if [ -z "$TARGET_MOUNT" ]; then 
	TARGET_MOUNT="/"
fi 

# Stop Jamf Connect from Opening 
touch /Library/LaunchAgents/com.jamf.connect.plist

# Install the JamfConnect.pkg software
/usr/sbin/installer -pkg "$INSTALLER_FILENAME" -target "$TARGET_MOUNT"

# Remove the JamfConnect.pkg file
rm -f "$INSTALLER_FILENAME"

# Enable Notify
#/usr/local/bin/authchanger -reset -JamfConnect -Notify

exit 0
