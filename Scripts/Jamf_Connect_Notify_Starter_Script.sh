#!/bin/zsh
# Jamf Connect Starter Script
# Update Line 21 and line 27 replacing the number and org name

# Caffeinate Mac to keep awake
/usr/bin/caffeinate -d -i -m -u & caffeinatePID=$!

#variables
NOTIFY_LOG="/var/tmp/depnotify.log"
#For TOKEN_BASIC, use same file path location as set for OIDCIDTokenPath in com.jamf.connect.login
TOKEN_BASIC="/private/tmp/token"
TOKEN_GIVEN_NAME=$(echo "$(cat $TOKEN_BASIC)" | sed -e 's/\"//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | grep given_name | cut -d ":" -f2)
TOKEN_UPN=$(echo "$(cat $TOKEN_BASIC)" | sed -e 's/\"//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | grep upn | cut -d ":" -f2)


echo $TOKEN_GIVEN_NAME
echo $TOKEN_UPN

### Update DeterminateManual to how many policies you have
echo "STARTING RUN" >> $NOTIFY_LOG # Define the number of increments for the progress bar
# Update Polices here
echo "Command: DeterminateManual: 15" >> $NOTIFY_LOG

###Jamf Triggers
echo "Command: Image: /Library/Resources/logo.png" >> $NOTIFY_LOG
echo "Command: MainTitle: Installing Apps and Settings." >> $NOTIFY_LOG
# Update Org name here
echo "Command: MainText: Thanks for choosing a Mac at Myorg! We want you to have a few applications and settings configured before you get started with your new Mac. This process should take 10 to 20 minutes to complete. \n \n If you need additional software or help, please visit the Self Service app in your Applications folder or on your Dock.'" >> $NOTIFY_LOG

# Jamf Policy: 1
echo "Status: Setting up your Mac 5% Complete..." >> $NOTIFY_LOG
/usr/local/bin/jamf policy -event "rose"
echo "Command: DeterminateManualStep: 1" >> $NOTIFY_LOG

# Jamf Policy: 2
echo "Status: Setting up your Mac 10% Complete..." >> $NOTIFY_LOG
/usr/local/bin/jamf policy -event "jc"
echo "Command: DeterminateManualStep: 2" >> $NOTIFY_LOG

# Jamf Policy: 3
echo "Status: Setting up your Mac 15% Complete..." >> $NOTIFY_LOG
/usr/local/bin/jamf policy -event "account"
echo "Command: DeterminateManualStep: 3" >> $NOTIFY_LOG

# Jamf Policy: 4
echo "Status: Setting up your Mac 20% Complete..." >> $NOTIFY_LOG
/usr/local/bin/jamf policy -event "name"
echo "Command: DeterminateManualStep: 4" >> $NOTIFY_LOG

# Jamf Policy: 5
echo "Status: Setting up your Mac 25% Complete..." >> $NOTIFY_LOG
/usr/local/bin/jamf policy -event "chrome"
echo "Command: DeterminateManualStep: 5" >> $NOTIFY_LOG

# Jamf Policy: 6
echo "Status: Setting up your Mac 30% Complete..." >> $NOTIFY_LOG
/usr/local/bin/jamf policy -event "portal"
echo "Command: DeterminateManualStep: 6" >> $NOTIFY_LOG

# Jamf Policy: 7
echo "Status: Setting up your Mac 35% Complete..." >> $NOTIFY_LOG
/usr/local/bin/jamf policy -event "adobecc"
echo "Command: DeterminateManualStep: 7" >> $NOTIFY_LOG

# Jamf Policy: 8
echo "Status: Setting up your Mac 40% Complete..." >> $NOTIFY_LOG
/usr/local/bin/jamf policy -event "reader"
echo "Command: DeterminateManualStep: 8" >> $NOTIFY_LOG

# Jamf Policy: 9
echo "Status: Setting up your Mac 50% Complete..." >> $NOTIFY_LOG
/usr/local/bin/jamf policy -event "office"
echo "Command: DeterminateManualStep: 9" >> $NOTIFY_LOG

# Jamf Policy: 10
echo "Status: Setting up your Mac 60% Complete..." >> $NOTIFY_LOG
/usr/local/bin/jamf policy -event "officetmp"
echo "Command: DeterminateManualStep: 10" >> $NOTIFY_LOG

# Jamf Policy: 11
echo "Status: Setting up your Mac 70% Complete..." >> $NOTIFY_LOG
/usr/local/bin/jamf policy -event "dock"
echo "Command: DeterminateManualStep: 11" >> $NOTIFY_LOG

# Jamf Policy: 12
echo "Status: Setting up your Mac 80% Complete..." >> $NOTIFY_LOG
/usr/local/bin/jamf policy -event "splash"
echo "Command: DeterminateManualStep: 12" >> $NOTIFY_LOG

# Jamf Policy: 13
echo "Status: Setting up your Mac 85% Complete..." >> $NOTIFY_LOG
/usr/local/bin/jamf policy -event "protect"
echo "Command: DeterminateManualStep: 13" >> $NOTIFY_LOG

# Jamf Policy: 14
echo "Status: Setting up your Mac 90% Complete..." >> $NOTIFY_LOG
/usr/local/bin/jamf policy -event "av"
echo "Command: DeterminateManualStep: 14" >> $NOTIFY_LOG

# Jamf Policy: 15
echo "Status: Setting up your Mac 99% Complete..." >> $NOTIFY_LOG
/usr/local/bin/jamf policy -event "filevault"
echo "Command: DeterminateManualStep: 15" >> $NOTIFY_LOG

sleep 5

###Clean Up
sleep 3
echo "Command: Quit" >> $NOTIFY_LOG
sleep 1
rm -rf $NOTIFY_LOG
 
 # Kill caffeinate process
kill "$caffeinatePID"

#6 - Disable notify screen from loginwindow process
/usr/local/bin/authchanger -reset -JamfConnect