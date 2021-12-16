#!/bin/bash
# Created by Kyle Ericson
# Remove Bomgar
for KILLPID in `ps ax | grep 'bomg*' | awk ' { print $1;}'`; do 
  kill -9 $KILLPID;
done
rm -rf /Library/LaunchDaemons/com.bomgar.bomgar-ps-*
rm -rf /Library/LaunchAgents/com.bomgar.bomgar-scc*
rm -rf /Users/Shared/bomgar-scc-*
rm -rf /Applications/com.bomgar*
exit 0