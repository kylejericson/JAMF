#!/bin/sh
# Created by Kyle Ericson

# unlock the sysprefs before unlocking specific panes: 
security authorizationdb write system.preferences allow 

# unlock energysaver: 
security authorizationdb write system.preferences.energysaver allow

# unlock datetime:
security authorizationdb write system.preferences.datetime allow

# unlock printing:
security authorizationdb write system.preferences.printing allow

# unlock network:
security authorizationdb write system.preferences.network allow

# add staff to lpadmin group
/usr/sbin/dseditgroup -o edit -t group -a staff _lpadmin

exit 0