#!/bin/bash

###version 1.0 2018-02-24 created by Baiyongjie ####
###Monitoring Tomcat Ps Old & auto restart Tomcat ####

script_pwd=$(pwd)
#根据实际情况填写，邮件中调用
server_name="中可-Mcm-Web-172.16.10.190"

ps -ef|grep java | grep -Ev "grep|application.properties" | awk '{print $2, $(NF-3)}' |sed 's/-Dcatalina.home=//'  > runing_tomcat.tmp

lockfile=/tmp/.$(basename $0)
if [ -f "$lockfile" ]
then
    echo -e '\033[40;36mThe script is already exist,please next time to run this script.\033[0m'   
    exit
else
    touch $lockfile
fi

cat runing_tomcat.tmp  | while read tomcat_pid tomcat_path
do 
    java_home=$(grep -E  '^JAVA_HOME|^export JAVA_HOME' $tomcat_path/bin/catalina.sh | cut -d"=" -f 2| sed 's/"//g' |sed 's#/$##')
    if [ -z $java_home ]
    then
        java_home=$(grep -E  '^JAVA_HOME|^export JAVA_HOME' $tomcat_path/bin/startup.sh | cut -d"=" -f 2| sed 's/"//g' |sed 's#/$##')
        if [ -z $java_home ]
        then
            java_home=$(grep -E '^JAVA_HOME|^export JAVA_HOME' /etc/profile | cut -d"=" -f 2| sed 's/"//g' |sed 's#/$##' )
        fi
    fi
    java_version=$(echo $java_home |  sed 's#/$##' |awk -F/ '{print $(NF-0)}')

    if [ $java_version = "jdk1.6.0_31" -o  $java_version = "jdk1.6.0_45"  -o $java_version = "jdk1.7.0_02"  ] 
    then
        PS_Old=$($java_home/bin/jmap -heap $tomcat_pid | awk '{print $1}'|tail -n 6 | head  -n 1 |sed 's/%//g' )
    elif [ $java_version = "jdk1.7.0_79" -o $java_version = "jdk1.8.0_25" -o $java_version = "jdk1.8.0_45" ]
    then
        PS_Old=$($java_home/bin/jmap -heap $tomcat_pid | grep -A 4 "PS Old Generation" | tail -1 |sed 's/% used//g'|sed 's/   //' )
    else
        echo "java_version is not exist!"
        exit
    fi
    
    echo -e "\033[40;36mtomcat-pid:$tomcat_pid   tomcat-path:$tomcat_path  \njdk-path:$java_home   jdk-version:$java_version\033[0m"   >> /var/log/cron 
    echo -e "\033[40;32mPS Old Generation: $PS_Old\033[0m"    >> /var/log/cron 

    if [  -z "$PS_Old" ]
    then
        echo "the PS Old Generation is not exist!"
        rm -rf $lockfile
        exit
    else
        tmp1=`awk -v tmp2=$PS_Old -v tmp3=99.0  'BEGIN{print(tmp2>tmp3)?"0":"1"}'`
        if [ $tmp1 -eq 1 ]
        then
            continue
        else
            tmp1=`awk -v tmp2=$PS_Old -v tmp3=99.0  'BEGIN{print(tmp2>tmp3)?"0":"1"}'`
            if [ $tmp1 -eq 0 ]
            then
                echo -e "\n\n----Now time: `date +%Y-%m-%d-%H:%M`----\n"  >>  /tmp/MonTomcatPsOld.log
                echo "Server Name:$server_name" >> /tmp/MonTomcatPsOld.log
                echo -e "tomcat-pid:$tomcat_pid   tomcat-path:$tomcat_path  \njdk-path:$java_home   jdk-version:$java_version" >> /tmp/MonTomcatPsOld.log 
                echo -e "\nPS Old Generation: $PS_Old\nTomcat Port:\n"  >>  /tmp/MonTomcatPsOld.log 
                netstat -nplt | grep $tomcat_pid   >>  /tmp/MonTomcatPsOld.log
                echo -e "\n\n ---jmap -heap  $tomcat_pid  Info: ---" >>  /tmp/MonTomcatPsOld.log
                $java_home/bin/jmap -heap  $tomcat_pid >>  /tmp/MonTomcatPsOld.log  
                tail -63 /tmp/MonTomcatPsOld.log  | mail  -s "$server_name Ps Old Too high." misterbyj@163.com
            fi
        fi
    fi
done

rm -f $lockfile $script_pwd/runing_tomcat.tmp
