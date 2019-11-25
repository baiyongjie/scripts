#!/bin/bash
# author:baiyongjie
# time：2017/09/13
# chanage login.defs & profile & sshd_config & system-auth
# version 1.0

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

loginpath=/etc/login.defs
sshcfgpath=/etc/ssh/sshd_config
profilepath=/etc/profile
sysauthpath=/etc/pam.d/system-auth-ac

sedlogin()
{
#sed chanage login 
grep "PASS_MAX_DAYS[^I]99999" $loginpath  &>/dev/null
if [ $? -eq 0 ]
then
sed -i  s'/PASS_MAX_DAYS[^I]99999/PASS_MAX_DAYS   90/'g   $loginpath
fi

grep "PASS_MIN_LEN[^I]5"  $loginpath  &>/dev/null
if [ $? -eq 0 ]
then
sed -i  s'/PASS_MIN_LEN[^I]5/PASS_MIN_LEN    10/'g  $loginpath
fi

grep "PASS_WARN_AGE[^I]7"  $loginpath  &>/dev/null
if [ $? -eq 0 ]
then
sed -i  s'/PASS_WARN_AGE[^I]7/PASS_WARN_AGE   30/'g  $loginpath
fi

#check sed chanage 
grep "PASS_MAX_DAYS   90" $loginpath &>/dev/null 
if [ $? -eq 0 ]
then
echo -e  '\nsed "PASS_MAX_DAY    90" Succeed!'
fi

grep "PASS_MIN_LEN    10"  $loginpath  &>/dev/null
if [ $? -eq 0 ]
then
echo 'sed "PASS_MIN_LEN    10" Succeed!'
fi

grep "PASS_WARN_AGE   30"  $loginpath  &>/dev/null
if [ $? -eq 0 ]
then
echo -e 'sed "PASS_WARN_AGE   30" Succeed!\n'
fi
}

sshcfgsed()
{
grep "^ClientAliveInterval 0" $sshcfgpath  
if [ $? -ne 0 ]
then
echo "ClientAliveInterval 0" >>  $sshcfgpath
echo -e '\necho "ClientAliveInterval 0" Succeed!'
fi

grep "^ClientAliveCountMax 30" $sshcfgpath 
if [ $? -ne 0 ]
then
echo "ClientAliveCountMax 30" >>  $sshcfgpath
echo -e 'echo "ClientAliveCountMax 30" Succeed!\n'
fi
}

profilesed()
{
echo 
grep "export TMOUT=1800" $profilepath
if [ $? -ne 0 ]
then
echo -e "\n##########ssh Time out#########"  >> $profilepath
echo "export TMOUT=1800" >> $profilepath
echo -e '\necho "export TMOUT=1800" Succeed!\n'
fi
source $profilepath
echo
}

sysauth()
{
if [ $OSVERSION -eq 7 ]
then
        echo -e "OS Version: $(cat /etc/redhat-release) \n script exit..."
        exit
fi

rpm -qa|grep crack &> /dev/null
if [ $? -ne 0 ]
then
yum -y install  cracklib &> /dev/null
fi

rpm -qa|grep crack  &> /dev/null && echo
dline=$(grep -n "pam_cracklib.so"  $sysauthpath | cut -d":" -f1)
i=i
d=d
sed -i --follow-symlinks  $dline$d  $sysauthpath
if [ $? -eq 0 ]
then
echo && echo "delete $sysauthpath $dline line Succeed!"
fi

sed -i --follow-symlinks "$dline$i password    requisite     pam_cracklib.so retry=5  difok=3 minlen=10 ucredit=3 lcredit=3 dcredit=2" $sysauthpath
if [ $? -eq 0 ]
then
echo "inside $sysauthpath $dline line Succeed!"
echo "sed $sysauthpath Succeed!" && echo
fi
}

sedlogin
sshcfgsed
profilesed
sysauth

