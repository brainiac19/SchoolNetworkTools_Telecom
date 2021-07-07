#!/bin/sh

#Set wan2 name here
intName=wlan1
devName=wlan1

#Set gateway add here
gateway=100.71.64.1

echo adding gw to rt for "$intName"
/sbin/route add -host "$gateway" "$devName"