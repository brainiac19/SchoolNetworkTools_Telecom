#!/bin/sh

#Set wan1 name here
intName=wan
devName=eth0.2

#Set gateway add here
gateway=100.71.64.1

echo adding gw to rt for "$intName"
/sbin/route add -host "$gateway" "$devName"