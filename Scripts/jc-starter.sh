#!/bin/zsh
# Created by Kyle Ericson
# Version 1.0
# Credits to this script which some items were used from https://raw.githubusercontent.com/jamf/DEPNotify-Starter/master/depNotify.sh

ORG_NAME="My Org Name"
BANNER_IMAGE_PATH="/Library/Resources/logo.png"
NOTIFY_LOG="/var/tmp/depnotify.log"
POLICY_ARRAY=(
    "Setting up your Mac 10% Complete...,rose"
    "Setting up your Mac 20% Complete...,username"
    "Setting up your Mac 30% Complete...,itadmin"
    "Setting up your Mac 40% Complete...,hostname"
    "Setting up your Mac 50% Complete...,portal"
    "Setting up your Mac 60% Complete...,excel"
    "Setting up your Mac 70% Complete...,onenote"
    "Setting up your Mac 80% Complete...,outlook"
    "Setting up your Mac 90% Complete...,powerpoint"
    "Setting up your Mac 99% Complete...,word"
    
  )
  
ARAY_LENGTH="${#POLICY_ARRAY[@]}"
for (( index = 1; index <= count; index ++ )); do
  echo "${index} of ${count}: ${POLICY_ARRAY[index]}"
done 

#ARAY_LENGTH="$((${#POLICY_ARRAY[@]}))"
echo "STARTING RUN" >> $NOTIFY_LOG # Define the number of increments for the progress bar
echo "Command: Image: $BANNER_IMAGE_PATH" >> $NOTIFY_LOG
echo "Command: MainTitle: Installing Apps and Settings." >> $NOTIFY_LOG
echo "Command: MainText: Thanks for choosing a Mac at $ORG_NAME! We want you to have a few applications and settings configured before you get started with your new Mac. This process should take 10 to 20 minutes to complete. \n \n If you need additional software or help, please visit the Self Service app in your Applications folder or on your Dock." >> $NOTIFY_LOG
echo "Command: DeterminateManual: $ARAY_LENGTH" >> $NOTIFY_LOG

# Loop to run policies
  for POLICY in "${POLICY_ARRAY[@]}"; do
    echo "Status: $(echo "$POLICY" | cut -d ',' -f1)" >> $NOTIFY_LOG
      /usr/local/bin/jamf policy -event "$(echo "$POLICY" | cut -d ',' -f2)"
      echo "Command: DeterminateManualStep: ${POLICY_ARRAY[index]}" >> $NOTIFY_LOG
done
sleep 5

###Clean Up
sleep 3
echo "Command: Quit" >> $NOTIFY_LOG
sleep 1
rm -rf $NOTIFY_LOG
 
#Disable notify screen from loginwindow process
/usr/local/bin/authchanger -reset -JamfConnect
exit 0