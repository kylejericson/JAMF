#!/bin/bash
# Written by Kyle Ericson
# Version 1.0
# Installs Duo Device Health macOS

# Download
curl -L "https://dl.duosecurity.com/DuoDeviceHealth-latest.dmg" -o /tmp/DuoDeviceHealth-latest.dmg
# Mount DMG
hdiutil attach /tmp/DuoDeviceHealth-latest.dmg -nobrowse
# Run Installer
/usr/sbin/installer -pkg /Volumes/DuoDeviceHealth/Install-DuoDeviceHealth.pkg -target / 
# Wait for Installer
sleep 15
# Unmount DMG
hdiutil detach /Volumes/DuoDeviceHealth || :

exit 0