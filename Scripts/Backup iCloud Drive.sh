#!/bin/bash
#Source: https://www.jessesquires.com/blog/2019/09/27/icloud-backup-using-rsync/
#Used for copying iCloud folder to current user's desktop
#Deploy with Jamf Pro
#Created by Kyle Ericson

USER=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ && ! /loginwindow/ { print $3 }' )

DEST="/Users/$USER/Desktop/iCloud-Backup/"

SRC="/Users/$USER/Library/Mobile Documents/com~apple~CloudDocs/"

rsync --verbose --recursive --delete-before --whole-file --times --exclude=".DS_Store" --exclude=".Trash/" "$SRC" "$DEST"

sudo chown -Rv $USER /Users/$USER/Desktop/iCloud-Backup

exit 0