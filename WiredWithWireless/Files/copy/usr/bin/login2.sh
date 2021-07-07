#!/bin/sh

#interface name
intName=wlan1

#device name
devName=wlan1


CURRENT_IP=$(ifconfig "$devName"|grep "inet addr"|awk '{print $2}'|awk -F: '{print $2}')
curT=$((`date '+%s'`*1000))
curT2=$((`date '+%s'`*1000-7000))
LOGIN_STATUS1=$(timeout 1 curl -s --interface "$Dev2" -X POST "http://110.188.66.35:801/eportal/?c=Portal&a=login&login_method=1&user_account=%2C1%2C手机号替换此处&user_password=密码替换此处&wlan_user_ip=${CURRENT_IP}&wlan_user_ipv6=&wlan_user_mac=000000000000&wlan_ac_ip=校园网路由ip替换此处&wlan_ac_name=校园网路由设备名替换此处&jsVersion=3.1" -H "Connection: keep-alive" -H "User-Agent: Mozilla/5.0 (Linux; Android 8.1.0; 16th Plus) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.99 Mobile Safari/537.36" -H "DNT: 1" -H "Accept: */*" -H "Referer: http://110.188.66.35/" -H "Accept-Language: en-US,en;q=0.9,zh-CN;q=0.8,zh;q=0.7")
echo "$LOGIN_STATUS1"|base64 -d
echo ------------------------