#!/bin/bash
# Created by Kyle Ericson
# Version 1.0
# Use this to setup Sysaid config
# Vendor Website: https://www.sysaid.com
# Vendor Manual Agent Deployment https://documentation.sysaid.com/docs/manual-agent-deployment
# serverURL arg - URL of the server SysAid is running on. This information can be found at the user's profile menu > About > Your server URL (Required)
# account arg - Your SysAid account ID. This information can be found at the user's profile menu > About > Your account (Required)
# serial arg - Your SysAid serial number. This information can be found at the user's profile menu > About > Serial key for your account (Required)
# These values are mapped with 
# serverURL arg = sysAidServerURL
# account rg = accountID
# serial arg= serial


# Set the variables with the desired values
sysAidServerURL="" # Example https://myorg.sysaidit.com
accountID="" # Example myorg
serial="" # Example 1AAA1AAAA111A11A


xmlFile="/Applications/SysAid Helpdesk.app/Contents/MacOS/AgentConfigurationFile.xml" # Default XML config path don't change

# Stop the Agent
sh /Applications/SysAid Helpdesk.app/Contents/MacOS/scripts/StopAgent.sh

# Use sed command to update the values in the XML file
sed -i '' "s|<SysAidServerURL name=\"ServerURL\">.*</SysAidServerURL>|<SysAidServerURL name=\"ServerURL\">${sysAidServerURL}</SysAidServerURL>|g" "$xmlFile"
sed -i '' "s|<AccountID name = \"AccountName\">.*</AccountID>|<AccountID name = \"AccountName\">${accountID}</AccountID>|g" "$xmlFile"
sed -i '' "s|<Serial name = \"Serial\">.*</Serial>|<Serial name = \"Serial\">${serial}</Serial>|g" "$xmlFile"

# Ensure ownership is set
chmod 777 "/Applications/SysAid Helpdesk.app/Contents/MacOS/AgentConfigurationFile.xml"

sleep 5

# Start the agent
sh /Applications/SysAid Helpdesk.app/Contents/MacOS/scripts/StartAgent.sh
 
exit 0
