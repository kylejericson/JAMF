#!/bin/bash
# Created by Kyle Ericson
# Version 1.0
# installs Vanta Agent and registers it to a enduser

# Update theses to your orgs needs.
AGENT_KEY="rtvgbh5rvcnn928h2ag5ten11148q3ucwfj3f8zkr2grdk696rt0"
OWNER_EMAIL="kyle@ericsontech.com"
REGION="us"
# Update theses to your orgs needs.

#### Don't Edit Below this Line ########
vantaCliPath="/usr/local/vanta/vanta-cli"
# Check if the file exists
if [ -e "$vantaCliPath" ]; then
    echo "Vanta is already installed. Exiting."
else
    CONF_FILE="/private/etc/vanta.conf"
currentTimestamp=$(date +%s)
cat <<EOL > "$CONF_FILE"
{
    "ACTIVATION_REQUESTED_NONCE": $currentTimestamp,
    "AGENT_KEY": "$AGENT_KEY",
    "NEEDS_OWNER": true,
    "OWNER_EMAIL": "$aadUser",
    "REGION": "$REGION"
}
EOL

# Set permissions and owner/group
chmod 755 "$CONF_FILE"
chown root:wheel "$CONF_FILE"

echo "Configuration file $CONF_FILE created and permissions set successfully."

# Download Vanta agent pkg
echo "Starting the download of Vanta Agent"
curl -L "https://app.vanta.com/osquery/download/macOS" -o /tmp/vanta.pkg || { echo "Error downloading Vanta Agent"; exit 1; }
echo "Download done"
echo "Starting the install of Vanta Agent"
/usr/sbin/installer -pkg /tmp/vanta.pkg -target / || { echo "Error installing Vanta Agent"; exit 1; }
echo "Install done"
exit 0
fi
