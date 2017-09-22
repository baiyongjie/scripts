#!/bin/bash
# author:baiyongjie
# date:2017/09/21
# useradd xianhuahua
# passwd xianhuahua
# change user longin
# change ssh port


OSVERSION=`sed -r "s/.*[ ]([0-9])(.*)/\1/"  /etc/redhat-release`
if [ $OSVERSION -eq 6 ]
then
        LOCALIP=`ifconfig  | grep "inet addr:" | grep -v '127.0.0.1' | sed 's/^.*addr:\(.*\)  Bc.*$/\1/g' |grep -E "^192.168*|10.*|172.16.*" | tail -1`
elif [ $OSVERSION -eq 7 ]
then
        #echo -e "OS Version: $(cat /etc/redhat-release) \n script exit..."
        LOCALIP=`ifconfig | grep inet | grep -Ev "inet6|127.0.0.1" | sed 's/^.*inet \(.*\)  ne.*$/\1/g' |grep -E "^192.168.*|10.*|172.16.*"| tail -1`
        #exit
fi

adduser(){
username=xhhadmin
date +%s%N | sha256sum | base64 | head -c 16  > pwd-$LOCALIP-info.txt
#echo >>  pwd-$LOCALIP-info.txt
password=$(cat pwd-$LOCALIP-info.txt)
useradd $username
if [ $? -eq 0 ]
then
    echo -e "\n\nuser $username add  successfully !"
else
    echo "user $username add  failly !"
    exit
fi
echo "$username:$password" | chpasswd
if [ $? -eq 0 ]
then
    echo "user sudo add  successfully !"
else
    echo "user sudo add  failly !"
    exit
fi
sed -i  "99i $username   ALL=(ALL)   ALL" /etc/sudoers
if [ $? -eq 0 ]
then
    echo "user passwd add  successfully !"
else
    echo "user passwd add  failly !"
    exit
fi
echo -e "\n"
echo "pwd file: pwd-$LOCALIP-info.txt"
echo "OS Version: $(cat /etc/redhat-release)" >pwd-$LOCALIP-info.txt
echo "IP Address: $LOCALIP" >>pwd-$LOCALIP-info.txt
echo "New User: $username" >>pwd-$LOCALIP-info.txt
echo "$username Passwd: $password" >>pwd-$LOCALIP-info.txt
cat pwd-$LOCALIP-info.txt
echo -e "\n"
}

szinfo(){
rpm -qa | grep lrzsz &> /dev/null
if [ $? -ne 0 ]
then
    yum -y install lrzsz &> /dev/null
fi

sz pwd-$LOCALIP-info.txt 
if [ $? -eq 0 ]
then
    echo "sz successfully !"
else
    echo "sz failly , script exit .." && exit
fi
}

closerootlogin(){
filepath="/etc/ssh/sshd_config"
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
if [ $OSVERSION -eq 6 ]
then
    line=$(grep -n "^#PermitRootLogin" $filepath  | cut  -d":"  -f 1)
    a=a 
    sed -i  "$line$a PermitRootLogin no" $filepath
    if [ $? -eq 0 ]
    then
        echo -e "\nclose root login successfully ! "
    else
        echo -e "\nclose root login failly !"
    fi 
elif [ $OSVERSION -eq 7 ]
then
    line=$(grep -n "^PermitRootLogin" $filepath | cut -d":" -f 1)
    d=d
    i=i 
    sed -i $line$d $filepath
    sed -i "$line$i  PermitRootLogin no" $filepath
    if [ $? -eq 0 ]
    then
        echo -e "\nclose root login successfully ! "
    else
        echo -e "\nclose root login failly !"
    fi
fi
}

changeport=8848
changesshport(){
grep "#Port 22"  /etc/ssh/sshd_config  &> /dev/null
if [ $? -eq 0 ]
then
    sed -i "s/#Port 22/Port $changeport/" /etc/ssh/sshd_config
    grep "Port $changeport" /etc/ssh/sshd_config &> /dev/null
    if [ $? -eq 0 ]
    then
        echo -e "\nChange ssh port : 22-->$changeport"
    fi
else
    echo -e "\nChange ssh port failly !"
fi
echo 
}

sshdrestart(){
if [ $OSVERSION -eq 6 ]
then
    /etc/init.d/sshd  restart
elif [ $OSVERSION -eq 7 ]
then
    systemctl restart  sshd.service
    if [ $? -eq 0 ]
    then
	echo "server sshd  restart successfully !"
    else
        echo "server sshd  restart failly !"
    fi
fi
}

adduser
szinfo
#closerootlogin
changesshport
sshdrestart
