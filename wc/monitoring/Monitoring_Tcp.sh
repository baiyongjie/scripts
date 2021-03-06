#!/bin/bash

###version 1.0 2018-02-24 created by Baiyongjie ####
###Monitoring Tcp Access Send Email. ####

#根据实际情况填写，邮件中调用
server_name="Server name"
NowTime=$(date +%Y-%m-%d-%H:%M)
CLOSE_WAIT=$(netstat -n | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a, S[a]}' | grep CLOSE_WAIT|awk '{print $2}')

if [ -n $CLOSE_WAIT ]
then
    echo -e "\n----Now time: $NowTime----\n"  >>  /tmp/MonTcp-V1.0.log
    echo -e "Server Name: $server_name\nTcp Access Number:\n" >>  /tmp/MonTcp-V1.0.log
    netstat -n | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a, S[a]}'  >> /tmp/MonTcp-V1.0.log
fi

CLOSE_WAIT1=$(tail -30 /tmp/MonTcp-V1.0.log  | grep CLOSE_WAIT|awk '{print $2}' | head -1)
CLOSE_WAIT2=$(tail -30 /tmp/MonTcp-V1.0.log  | grep CLOSE_WAIT|awk '{print $2}' | tail -1)

if [ $CLOSE_WAIT1 -lt 300 ] && [ $CLOSE_WAIT2 -gt 300 ]
then
    tail -14 /tmp/MonTcp-V1.0.log | mail  -s "$server_name Tcp Access Too high !"  to-Email-address
elif [ $CLOSE_WAIT1 -gt 300 ] && [ $CLOSE_WAIT2 -lt 300 ]
then
    tail -14 /tmp/MonTcp-V1.0.log | mail  -s "$server_name Tcp Access Restore !"  to-Email-address
