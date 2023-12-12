#!/bin/zsh

# Set the domain as a variable
domain="ericsontech.com"

localUsers=$(find /Users -maxdepth 1 -type d | cut -d "/" -f3-)
for localUser in $localUsers
do
    test=$(grep "@$domain" "/Users/$localUser/Library/Application Support/com.microsoft.CompanyPortalMac.usercontext.info" 2>/dev/null)
    if [ ! -z "$test" ]; then
        aadUser=$(grep "@$domain" "/Users/$localUser/Library/Application Support/com.microsoft.CompanyPortalMac.usercontext.info" | cut -d ">" -f2- | sed 's/<\/string>//')
        break  # Assuming you only want the first matching user
    fi
done

echo $aadUser
exit 0
