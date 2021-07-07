#!/bin/sh

#Interface name
Int1=wan
Int2=wlan1

#Device name
Dev1=eth0.2
Dev2=wlan1

usleep 200000
echo removing gw from rt for "$Int1"
/sbin/route del -host 100.71.64.1 "$Dev1"
/sbin/route del -host 100.71.64.1 "$Dev2"
usleep 1799800000
echo adding gw to rt for "$Int1"
/sbin/route add -host 100.71.64.1 "$Dev1"