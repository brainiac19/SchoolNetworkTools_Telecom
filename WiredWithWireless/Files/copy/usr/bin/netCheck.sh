#!/bin/sh

#Interface name
Int1=wan
Int2=wlan1

#Device name
Dev1=eth0.2
Dev2=wlan1


Gateway1=$(ping -W 1 -c 1 -I "$Dev1" 110.188.66.35|grep '1 packets received')
Internet1=$(ping -W 1 -c 1 -I "$Dev1" 114.114.114.114|grep '1 packets received')

Gateway2=$(ping -W 1 -c 1 -I "$Dev2" 110.188.66.35|grep '1 packets received')
Internet2=$(ping -W 1 -c 1 -I "$Dev2" 114.114.114.114|grep '1 packets received')

if [ "$Gateway1" != '' ];then
echo "$Int1" gateway connected
fi

if [ "$Internet1" != '' ];then
echo "$Int1" Internet connected
fi

if [ "$Gateway2" != '' ];then
echo "$Int2" gateway connected
fi

if [ "$Internet2" != '' ];then
echo "$Int2" Internet connected
fi