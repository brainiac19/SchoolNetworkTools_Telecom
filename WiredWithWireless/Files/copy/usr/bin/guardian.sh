#!/bin/sh
echo Guardian Initiated $(date)>>/tmp/log/guardian.log

#Exception day set here to 1
Holiday=0

#Dual wan switch
Dual=0

if [ "$Holiday" = 1 ]; then
	echo Warning: Holiday exception enabled, it will not be disabled automatically $(date)>>/tmp/log/guardian.log
fi

if [ "$Dual" = 0 ]; then
	echo Warning: Dual wan disabled $(date)>>/tmp/log/guardian.log
fi

#Set network up/down time here
NetAvailTime=6
NetDownTime=23:59
NetDownHour=$(echo $NetDownTime|cut -d : -f 1)
NetDownMin=$(echo $NetDownTime|cut -d : -f 2)


#Interface name
Int1=wan
Int2=wlan1

#Device name
Dev1=eth0.2
Dev2=wlan1

#Ping add
InternetPingAdd=114.114.114.114
GatewayPingAdd=110.188.66.35

#Use backup network or not
Backup=0
#Backup m"$Int1"3 rule name
BackupRuleName=4g
#Regular dual "$Int1" rule name
DualWanRuleName=balanced




#Functions
pingfunc()
{
result1=$(ping -W 3 -c 2 -I "$Dev1" "$InternetPingAdd"|grep '[1-2] packets received')
result2=$(ping -W 3 -c 2 -I "$Dev2" "$InternetPingAdd"|grep '[1-2] packets received')


if [ ${#result1} -lt 1 ]; then
	resultGateway1=$(ping -W 3 -c 2 -I "$Dev1" "$GatewayPingAdd"|grep '[1-2] packets received')
	if [ ${#resultGateway1} -lt 1 ]; then
		echo 0
		echo 0
	else
		echo 1
		echo 0
	fi
else
	echo 1
	echo 1
fi

if [ ${#result2} -lt 1 ]; then
	resultGateway2=$(ping -W 3 -c 2 -I "$Dev2" "$GatewayPingAdd"|grep '[1-2] packets received')
	if [ ${#resultGateway2} -lt 1 ]; then
		echo 0
		echo 0
	else
		echo 1
		echo 0
	fi
else
	echo 1
	echo 1
fi
}



intDownFunc()
{
grepIntDown1=$(ifstatus "$Int1"|grep '"up": false')
grepIntDown2=$(ifstatus "$Int2"|grep '"up": false')
if [ ${#grepIntDown1} -lt 1 ]; then
	echo Shutting "$Int1" down $(date)>>/tmp/log/guardian.log
	ifdown "$Int1"
fi

if [ "$Dual" = 1 ] && [ ${#grepIntDown2} -lt 1 ]; then
	echo Shutting "$Int2" down $(date)>>/tmp/log/guardian.log
	ifdown "$Int2"
fi
}




reconFunc()
{

if [ "$2" = 0 ] || [ "$4" = 0 ]; then
currentTimeStamp=$(date)
echo ConnectionLost $currentTimeStamp
fi

NowTime=$(date +%s)
DeconfigTime1=$(cat /tmp/DeconfigTime1)
sub1=0
if [ ${#DeconfigTime1} -gt 1 ]; then
	sub1=$(expr "$NowTime" - "$DeconfigTime1")
fi

if [ "$sub1" -gt 10 ]; then
	if [ "$2" = 0 ]; then
		if [ "$1" = 0 ]; then
			echo restarting "$Int1" by guardian $(date)>>/tmp/log/guardian.log
			grep1Up=$(ifstatus "$Int1"|grep '"up": true')
			if [ ${#grep1Up} -gt 1 ]; then
				ifdown "$Int1"
			fi
			ifup "$Int1"
			sleep 5
		fi
		echo "$Int1" logging in by guardian $(date)>>/tmp/log/guardian.log
		result1=$(sh /usr/bin/login1.sh|grep "uPm")
		if [ ${#result1} -gt 1 ]; then
			echo account suspended, sleeping for 2.5 mins $(date)>>/tmp/log/guardian.log
			sleep 150
		fi
	fi
else
	sleep 10
fi




if [ "$Dual" = 1 ] ; then

NowTime=$(date +%s)
DeconfigTime2=$(cat /tmp/DeconfigTime2)
sub2=0
if [ ${#DeconfigTime2} -gt 1 ]; then
	sub2=$(expr "$NowTime" - "$DeconfigTime2")
fi

if [ "$sub2" -gt 10 ]; then
	if [ "$4" = 0 ]; then
		if [ "$3" = 0 ]; then
			echo restarting "$Int2" by guardian $(date)>>/tmp/log/guardian.log
			grep2Up=$(ifstatus "$Int2"|grep '"up": true')
			if [ ${#grep2Up} -gt 1 ]; then
				ifdown "$Int2"
				sleep 1
			fi
			ifup "$Int2"
			sleep 20
		fi
		echo "$Int2" logging in by guardian $(date)>>/tmp/log/guardian.log
		result2=$(sh /usr/bin/login2.sh|grep "uPm")
		if [ ${#result2} -gt 1 ]; then
			echo account suspended, sleeping for 2.5mins $(date)>>/tmp/log/guardian.log
			sleep 150
		fi
	fi
else
	sleep 10
fi

fi

}


separatedLease()
{
grepIntDown1=$(ifstatus "$Int1"|grep '"up": true')
grepIntDown2=$(ifstatus "$Int2"|grep '"up": true')
if [ ${#grepIntDown1} -gt 1 ] && [ ${#grepIntDown2} -gt 1 ]; then
	UpTime1=$(ifstatus "$Int1"|grep 'uptime'|grep -o "[0-9]*")
	UpTime2=$(ifstatus "$Int2"|grep 'uptime'|grep -o "[0-9]*")
	sub=$(expr "$UpTime1" - "$UpTime2")
	abs=${sub#-}
	if [ "$abs" -lt 5 ]; then
		ifdown "$Int1"
		sleep 10
		ifup "$Int1"
		sleep 3
		echo Executed interface restart to separate lease renew $(date)>>/tmp/log/guardian.log
	fi
fi

}

InfPing()
{
while true
do
	pingfunc
	sleep 20
done
}

Debug()
{
echo Debugging dns
echo $(cat /tmp/resolv.conf.d/resolv.conf.auto)
}

Guardian()
{
while true
do
	week=$(date "+%w")
	hour=$(date "+%H")
	min=$(date "+%M")
	if [ "$Holiday" = 1 ] || [ "$week" -lt 5 -a "$week" -gt 0 -a "$hour" -gt $(expr "$NetAvailTime" - 1) -a "$hour" -lt "$NetDownHour" -o "$week" -lt 5 -a "$week" -gt 0 -a "$hour" -eq "$NetDownHour" -a "$min" -ne "$NetDownMin" ] || [ "$week" -eq 5 -a "$hour" -gt $(expr "$NetAvailTime" - 1) ] || [ "$week" -eq 6 ] || [ "$week" -eq 0 -a "$hour" -lt "$NetDownHour" -o "$week" -eq 0 -a "$hour" -eq "$NetDownHour" -a "$min" -ne "$NetDownMin" ]; then
		if [ "$Dual" = 1 ]; then
		separatedLease
		fi
		reconFunc $(pingfunc)
	else
		if [ "$Backup" = 1 ]; then
			intDownFunc
		fi
	fi
	sleep 30
done
}

Guardian>>/tmp/log/guardian.log




