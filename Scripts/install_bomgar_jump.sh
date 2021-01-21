#!/bin/zsh
#Created by Kyle Ericson
# Steps:
#1. Create the jump client dmg from the Bomgar console
#2. Create policy in Jamf to Cache the dmg and run this script after.
#3. Scope and deploy.
#The Bomgar DMG should have been installed cached prior to this script running, but we should make sure...

if [ -a "/Library/Application Support/JAMF/Waiting Room/bomgar-scc-"*".dmg" ]; then

# Attach the Disk Image
    hdiutil attach /Library/Application\ Support/JAMF/Waiting\ Room/bomgar-scc-*.dmg

# Run the installer
    /Volumes/bomgar-scc/Double-Click\ To\ Start\ Support\ Session.app/Contents/MacOS/sdcust

# Wait a minute for it to finish up
    sleep 90

# Unmount the disk image
    hdiutil detach /Volumes/bomgar-scc

# Wait for the unmount to complete
    sleep 25

# Delete the disk image
    rm -R /Library/Application\ Support/JAMF/Waiting\ Room/bomgar-scc-*.dmg


else

echo "Bomgar NOT Present"
exit 1

fi
exit 0