#!/bin/bash

###owned by Winchannel ITS ####
###version 1.0 2018-02-24 created by Baiyongjie ####
###Monitoring Tomcat Ps Old & auto restart Tomcat ####

script_pwd=$(pwd)
#根据实际情况填写，邮件中调用
server_name="192.168.1.121-公司Linux测试服务器"
dump_path=/data/dump/$(date +%Y-%m-%d)

#将正在运行中的tomcat输入到一个临时文件中
ps -ef|grep java | grep -v grep | awk '{print $2, $(NF-3)}' |sed 's/-Dcatalina.home=//'  > runing_tomcat.tmp

#脚本运行后生成一个锁文件，如锁文件存在则说明脚本正在运行则退出脚本
lockfile=/tmp/.$(basename $0)
if [ -f "$lockfile" ]
then
    echo -e '\033[40;36mThe script is already exist,please next time to run this script.\033[0m'   
    exit
else
    touch $lockfile
fi

#将tomcat pid和路径从文件中读取并赋值给变量tomcat_pid和tomcat_path
cat runing_tomcat.tmp  | while read tomcat_pid tomcat_path
do 
    #获取tomcat使用的jdk路径
    java_home=$(grep -E  '^JAVA_HOME|^export JAVA_HOME' $tomcat_path/bin/catalina.sh | cut -d"=" -f 2| sed 's/"//g' |sed 's#/$##')
    if [ -z $java_home ]
    then
        java_home=$(grep -E  '^JAVA_HOME|^export JAVA_HOME' $tomcat_path/bin/startup.sh | cut -d"=" -f 2| sed 's/"//g' |sed 's#/$##')
        if [ -z $java_home ]
        then
            java_home=$(grep -E '^JAVA_HOME|^export JAVA_HOME' /etc/profile | cut -d"=" -f 2| sed 's/"//g' |sed 's#/$##' )
        fi
    fi
    #获取jdk版本
    java_version=$(echo $java_home |  sed 's#/$##' |awk -F/ '{print $(NF-0)}')

    ###调试使用### 
    #echo -e "\033[40;36mtomcat-pid:$tomcat_pid   tomcat-path:$tomcat_path  \njdk-path:$java_home   jdk-version:$java_version\033[0m"

    #获取tomcat老年代的使用率
    if [ $java_version = "jdk1.6.0_31" -o  $java_version = "jdk1.6.0_45"  -o $java_version = "jdk1.7.0_02"  ] 
    then
        PS_Old=$($java_home/bin/jmap -heap $tomcat_pid | awk '{print $1}'|tail -n 6 | head  -n 1 |sed 's/%//g' )
    elif [ $java_version = "jdk1.7.0_79" -o $java_version = "jdk1.8.0_45" ]
    then
        PS_Old=$($java_home/bin/jmap -heap $tomcat_pid | grep -A 4 "PS Old Generation" | tail -1 |sed 's/% used//g'|sed 's/   //' )
    else
        echo "java_version is not exist!"
        exit
    fi

    ###调试使用###
    #echo -e "\033[40;32mPS Old Generation: $PS_Old\033[0m"

    #检测tomcat老年代
    if [  -z "$PS_Old" ]
    then
        echo "the PS Old Generation is not exist!"
        rm -rf $lockfile
        exit
    else
        #判断老年代使用率是否超过99%，如超过则dump重启
        tmp1=`awk -v tmp2=$PS_Old -v tmp3=99.0  'BEGIN{print(tmp2>tmp3)?"0":"1"}'`
        if [ $tmp1 -eq 1 ]
        then
            continue
        else
            tmp1=`awk -v tmp2=$PS_Old -v tmp3=99.0  'BEGIN{print(tmp2>tmp3)?"0":"1"}'`
            if [ $tmp1 -eq 0 ]
            then
                ###echo 作为调试使用
                #echo -e "\033[40;36mtomcat-pid:$tomcat_pid   tomcat-path:$tomcat_path  \njdk-path:$java_home   jdk-version:$java_version\033[0m"
                #echo -e "\033[40;32mPS Old Generation: $PS_Old\033[0m"
                mkdir -p $dump_path &> /dev/null
                echo -e "----Now time: `date +%Y-%m-%d-%H:%M`----\n"  >>  wincITS_tomcat-autodump.log
                echo "Server Name:$server_name" >> wincITS_tomcat-autodump.log
                echo -e "PS Old Generation: $PS_Old\nTomcat Path: $tomcat_path\nTomcat Port:\n"  >>  wincITS_tomcat-autodump.log 
                netstat -nplt | grep $tomcat_pid   >>  wincITS_tomcat-autodump.log
                echo -e "\ndump $tomcat_path start .. " >>  wincITS_tomcat-autodump.log
                $java_home/bin/jmap -heap  $tomcat_pid &> $dump_path/jmap_heap_$tomcat_pid.txt        
                $java_home/bin/jmap -histo $tomcat_pid &> $dump_path/jmap_histo_$tomcat_pid.txt
                $java_home/bin/jmap -dump:format=b,file=$dump_path/jmap_dump_$tomcat_pid.dump $tomcat_pid
                $java_home/bin/jstack -F  $tomcat_pid &> $dump_path/jstack_F_$tomcat_pid.txt
                $java_home/bin/jstack -l $tomcat_pid &> $dump_path/jstack_l_$tomcat_pid.txt
                echo -e "$dump_path/jmap_heap_$tomcat_pid.txt\n$dump_path/jmap_histo_$tomcat_pid.txt\n$dump_path/jmap_dump_$tomcat_pid.dump\n$dump_path/jstack_F_$tomcat_pid.txt\n$dump_path/jstack_l_$tomcat_pid.txt"  >> wincITS_tomcat-autodump.log
                kill -9 $tomcat_pid 
                sleep 3
                $tomcat_path/bin/startup.sh &> /dev/null
                echo -e "$tomcat_path  Restart...\n"  >>  wincITS_tomcat-autodump.log
                #send email
                tail -19 wincITS_tomcat-autodump.log  | mail  -s "$tomcat_path Ps-Old-Dump && Restart!" baiyongjie@winchannel.net
                cd $dump_path
                tar -zcf dumpfile-$(date "+%Y-%m-%d")-$tomcat_pid.tar.gz  jmap_heap_$tomcat_pid.txt jmap_histo_$tomcat_pid.txt jmap_dump_$tomcat_pid.dump jstack_F_$tomcat_pid.txt jstack_l_$tomcat_pid.txt  --remove-files
            fi
        fi
    fi
done

#删除锁文件
rm -f $lockfile $script_pwd/runing_tomcat.tmp
