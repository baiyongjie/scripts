#!/bin/bash
##############################
###owned by Winchannel ITS ####
###version 1.2 2018-03-05 created by Baiyongjie ####
###############################

#++++++++++++++++++++++++#
###version 1.2###
#Add yum repo install
#Add Tomcat Jvm PS-Old-Monitoring
#++++++++++++++++++++++++#

menu(){
echo -e "
Now user:$(who | awk '{print $1}'|tail -1)
Now the time:$(date "+%Y-%m-%d-%T")
==========================
Menu:
==========================
  \033[32mj:java / tc:t_config / p:t_port / jv:jvm_ps_old /d:t_dump / tr:t_restart / tf:t_tlog / ngx:nginx
  o:vi / oo:vim / ds:OS_status / n:netstat/ c:/bin/bash / l:clear / y:yum repo / q:exit script\033[0m
=========================="
}

#show runing tomcat
tomcat_status(){
echo  "User-Pid-   --------Tomcat  directory-------"
ps -ef|grep java | grep -v grep |grep -v DocumentService-1.2.jar | awk '{print $1, $2,  $(NF-3)}' |sed 's/-Dcatalina.home=//g'
}

#show tomcat configure files
tomcat_config(){
tomcat_status;echo
read -p "Please enter the pid or tomcat path: " pidORpath;echo
tomcat_status | grep $pidORpath &> /dev/null
if [ -d $pidORpath ]
then
    TOMCAT_PATH=$pidORpath
else
    TOMCAT_PATH=$(tomcat_status | grep $pidORpath | awk '{print $3}')
fi
 
if [ ! -d $TOMCAT_PATH ] ||  [ -z $TOMCAT_PATH ] 
then
    echo " $TOMCAT_PATH  is Null Directory..  Script exit.. "
    exit
fi

#catalina.sh
echo -e "\033[36m$TOMCAT_PATH/bin/catalina.sh\033[0m"
echo -e "\033[32m----  Catalina  config  begin----\033[0m"
grep -E "^JAVA_HOME=|^export JAVA_HOME="   $TOMCAT_PATH/bin/catalina.sh
grep  "^JAVA_OPTS="   $TOMCAT_PATH/bin/catalina.sh
grep  "^CATALINA_OPTS=" $TOMCAT_PATH/bin/catalina.sh
echo -e "\033[32m----  Catalina  config  end-----\033[0m\n"

#server.xml
echo -e "\033[36m$TOMCAT_PATH/conf/server.xml\033[0m"
echo -e "\033[32m----  server.xml  config  begin----\033[0m"
grep "shutdown=" "$TOMCAT_PATH/conf/server.xml"
grep "Connector executor=" "$TOMCAT_PATH/conf/server.xml"
grep "Connector port=" "$TOMCAT_PATH/conf/server.xml"
grep "appBase" "$TOMCAT_PATH/conf/server.xml" 
grep "docBase" "$TOMCAT_PATH/conf/server.xml"
echo -e "\033[32m----  server.xml  config  end-----\033[0m\n"

#find the root path
#root_path
grep "docBase" "$TOMCAT_PATH/conf/server.xml"   > /dev/null
if [ $? -eq 0 ]
then
    grep -B 1 "docBase" "$TOMCAT_PATH/conf/server.xml" | grep ' <!--'  > /dev/null 
    if [ $? -eq 0 ]
    then
        appbase=$(grep "appBase" "$TOMCAT_PATH/conf/server.xml" | awk -F= '{print $3}'|awk -F\" '{print $2}')
	if [ "$appbase" = "webapps" ]
        then
            root_path=$TOMCAT_PATH/$appbase 
        fi
    else
        docbase=$(grep "docBase" "$TOMCAT_PATH/conf/server.xml" | awk  '{print $4}' |awk -F"=" '{print $2}' | tr -d '"')
        root_path=$docbase 
    fi
else
    appbase=$(grep "appBase" "$TOMCAT_PATH/conf/server.xml" | awk -F= '{print $3}'|awk -F\" '{print $2}')
    if [ "$appbase" = "webapps" ]
    then
        root_path=$TOMCAT_PATH/$appbase 
    fi
fi

#find file is webapps/$(*)/sfa.properties 
sfa_properties=$(find $root_path -type f -name sfa.properties  | grep "WEB-INF/classes/config" )
echo -e "\033[36m$sfa_properties\033[0m"  | grep $sfa_properties  &>/dev/null
if [ $? -eq 0 ]
then
    echo -e "\033[36m$sfa_properties\033[0m"
    echo -e "\033[32m----  sfa.properties  config  begin---- \033[0m"
    grep "^project="  $sfa_properties
    grep "^mediaPath=" "$sfa_properties"
    grep "^mediaServerUrl=" "$sfa_properties"
    grep "^mobile.cache.maxfiles=" "$sfa_properties"
    grep "^mobile.cache.filepath=" "$sfa_properties"
    grep "^mobile.cacheType=" "$sfa_properties"
    grep "^mongodb.serverIp=" "$sfa_properties"
    grep "^mongodb.port=" "$sfa_properties"
    grep "^mongodb.username=" "$sfa_properties"
    grep "^mongodb.password=" "$sfa_properties"
    grep "^mongodb.poolsize=" "$sfa_properties"
    echo -e "\033[32m----  sfa.properties  config  end---- \033[0m\n"
fi

#find file is webapps/$(*)/jdbc.properties
jdbc_properties=$(find $root_path -type f -name jdbc.properties  | grep "WEB-INF/classes/config" )
echo -e "\033[36m$jdbc_properties\033[0m"   | grep $jdbc_properties  &>/dev/null
if [ $? -eq 0 ]
then
    echo -e "\033[36m$jdbc_properties\033[0m"
    echo -e "\033[32m----  jdbc.properties  config  begin---- \033[0m"
    grep "^jdbc.url=" $jdbc_properties
    grep "^jdbc.username=" $jdbc_properties
    grep "^jdbc.password="  $jdbc_properties
    echo -e "\033[32m----  jdbc.properties  config  end---- \033[0m\n"
else
    echo -e "\033[36mNot find files: jdbc.properties ...\033[0m"
fi

#find file is APP_HOME/$(*)/jdbc.properties
if [ -d $TOMCAT_PATH/APP_HOME/config ] 
then
    jdbc_properties=$(find $TOMCAT_PATH/APP_HOME/config  -type f -name jdbc.properties)
    echo -e "\033[36m$jdbc_properties\033[0m"   | grep $jdbc_properties  &>/dev/null
    if [ $? -eq 0 ]
    then
        echo -e "\033[36m$jdbc_properties\033[0m"
        echo -e "\033[32m----  jdbc.properties  config  begin---- \033[0m"
        grep "^jdbc.url=" $jdbc_properties
        grep "^jdbc.username=" $jdbc_properties
        grep "^jdbc.password="  $jdbc_properties
        echo -e "\033[32m----  jdbc.properties  config  end---- \033[0m\n"
    fi
fi

#find file is webapps/$(*)/base.properties
base_properties=$(find $root_path -type f -name base.properties  | grep "WEB-INF/classes/config" )
echo -e "\033[36m$base_properties\033[0m"   | grep $base_properties &>/dev/null
if [ $? -eq 0 ]
then
    echo -e "\033[36m$base_properties\033[0m"
    echo -e "\033[32m----  base.properties  config  begin---- \033[0m"
    grep "^job.baseJob=" $base_properties
    grep "^server.type.value=" $base_properties
    grep "^security.property.placeholder="  $base_properties
    echo -e "\033[32m----  base.properties  config  end---- \033[0m\n"
fi

#find file is APP_HOME/$(*)/base.properties
if [ -d $TOMCAT_PATH/APP_HOME ]
then
    base_properties=$(find $TOMCAT_PATH/APP_HOME/config  -type f -name base.properties)
    echo -e "\033[36m$base_properties\033[0m"   | grep $base_properties &>/dev/null
    if [ $? -eq 0 ]
    then
        echo -e "\033[36m$base_properties\033[0m"
        echo -e "\033[32m----  base.properties  config  begin---- \033[0m"
        grep "^job.baseJob=" $base_properties
        grep "^server.type.value=" $base_properties
        grep "^security.property.placeholder="  $base_properties
        echo -e "\033[32m----  base.properties  config  end---- \033[0m\n"  
    fi
fi
}

#input pid find port or inpit port find pid
find_tomcat_port(){
tomcat_status;echo
read -p "Please enter the pid or port: " PORTPID;echo
tomcat_status | awk '{print $2}' | grep $PORTPID &> /dev/null
if [ $? -eq 0 ]
then
    netstat -nplt | grep $PORTPID;echo
else
    portt=$(netstat -nplt|grep $PORTPID | awk '{print $7}' | cut  -d"/" -f 1 | tail -1) 
    ps -ef|grep $portt | grep -v grep
fi 
}

#dump tomcat info
dump_tomcat(){
tomcat_status;echo
read -p "Please enter the pid of the dump target: " PID;echo

inputpid=$(tomcat_status | grep $PID) && > /dev/null
if [ $? -eq 0 ]
then
    echo -e "You input tomcat is : $inputpid\n"
    read -p "continue? [y|n]" input;echo
    if [ $input = y ]
    then
	mkdir -p /data/dump/$(date "+%Y-%m-%d")  > /dev/null
	echo "jmap -heap  $PID  start .."
	jmap -heap  $PID &> /data/dump/$(date "+%Y-%m-%d")/jmap_heap_$PID.txt   
	echo -e "Path:/data/dump/$(date "+%Y-%m-%d")/jmap_heap_$PID.txt\njmap -heap  $PID  end.. \n"
	echo "jmap -histo  $PID  start .."
	jmap -histo $PID &> /data/dump/$(date "+%Y-%m-%d")/jmap_histo_$PID.txt
	echo -e "Path:/data/dump/$(date "+%Y-%m-%d")/jmap_histo_$PID.txt\njmap -histo  $PID  end.. \n"
	echo -e "\njstack -F  $PID  start .."
	jstack -F  $PID &> /data/dump/$(date "+%Y-%m-%d")/jstack_F_$PID.txt
	echo -e "Path:/data/dump/$(date "+%Y-%m-%d")/jstack_F_$PID.txt\njstack -F  $PID  end.. \n"
	echo "jstack -l  $PID  start .."
	jstack -l $PID &> /data/dump/$(date "+%Y-%m-%d")/jstack_l_$PID.txt
	echo -e "Path:/data/dump/$(date "+%Y-%m-%d")/jstack_l_$PID.txt\njstack -l  $PID  end.. \n"
        echo "jmap -dump:format=b  $PID  start .."
        jmap -F -dump:format=b,file=/data/dump/$(date "+%Y-%m-%d")/jmap_dump_$PID.dump $PID
    else
	continue
    fi
fi
}


restart_tomcat(){
tomcat_status;echo
read -p "Please input your restart tomcat pid or path: " repidORpath
tomcat_status | grep $repidORpath &> /dev/null
if [ $? -eq 0 ]
then
    repid=$(tomcat_status | grep  $repidORpath |  awk '{print $2}')
    repath=$(tomcat_status | grep  $repidORpath |  awk '{print $3}')
    echo -e "\nwant to restart: \033[36mpid:$repid $repath\033[0m"
    read -p "Are you sure you want to restart it?[y|n]" retyn
    if [ $retyn = y ]
    then
        kill -9 $repid
        sleep 3
        $repath/bin/startup.sh
        echo;read -p "tailf $repath/logs/catalina.out?[y|n]"  tlog
        if [ $tlog = y ]
        then
            tail -f $repath/logs/catalina.out 
        else
            continue
        fi
    else
        continue
    fi
else
    echo -e "\ninput error:not find pid or path.."
fi
}

tailf_log(){
tomcat_status;echo
read -p "Please enter the pid or path of tomcat to view the log:" taillog
tailpid=$(tomcat_status | grep  $taillog |  awk '{print $2}')
tailpath=$(tomcat_status | grep  $taillog |  awk '{print $3}')
if [ x$taillog = x$tailpid ]
then
    tail -f $tailpath/logs/catalina.out
else
    tail -f $taillog/logs/catalina.out
fi
}

yum_repo(){
OSVERSION=`sed -r "s/.*[ ]([0-9])(.*)/\1/"  /etc/redhat-release`
rpm -qa | grep  wget  > /dev/null
if [ $? -ne 0 ]
then
    yum -y install wget
    if [ $? -ne 0 ]
    then
        echo -e "\n\033[36mwget not install..\033[0m"
        continue
    fi
fi

mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
if [ $OSVERSION -eq 6 ]
then
    wget -O /etc/yum.repos.d/CentOS6-Base-163.repo  http://mirrors.163.com/.help/CentOS6-Base-163.repo  > /dev/null
    wget -O /etc/yum.repos.d/CentOS6-epel-ali.repo  http://mirrors.aliyun.com/repo/Centos-6.repo  > /dev/null
    yum clean all
    yum makecache
    yum repolist all
    echo  -e "\n\033[36mThe source has been installed.\033[0m"
elif [ $OSVERSION -eq 7 ]
then
    wget -O /etc/yum.repos.d/CentOS7-Base-163.repo  http://mirrors.163.com/.help/CentOS7-Base-163.repo > /dev/null
    wget -O /etc/yum.repos.d/CentOS7-epel-ali.repo  http://mirrors.aliyun.com/repo/Centos-7.repo  > /dev/null
    yum clean all
    yum makecache 
    yum repolist all
    echo  -e "\n\033[36mThe source has been installed.\033[0m"
else
    echo  -e "\n\033[36mOS Version don't know.\033[0m"
    break
fi
}

jvm_ps_old(){
ps -ef | grep java | grep -Ev "grep|application.properties" | awk '{print $2, $(NF-3)}' |sed 's/-Dcatalina.home=//'  > runing_tomcat.tmp

if [ ! -s runing_tomcat.tmp ]
then
   echo -e "\n\033[36mNot Runing Tomcat...\033[0m"
   rm -f runing_tomcat.tmp
   continue
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

    echo -e "\033[40;36mtomcat-pid:$tomcat_pid   tomcat-path:$tomcat_path  \njdk-path:$java_home   jdk-version:$java_version\033[0m"  
    echo -e "\033[40;32mPS Old Generation: $PS_Old\033[0m" 

done
rm -f  runing_tomcat.tmp
continue
}


os_status(){
rpm -qa | grep dstat > /dev/null
if [ $? -eq 0 ]
then
    dstat  -c -d -m -n -r --fs -t  2  5
else
    yum -y install dstat  > /dev/null
    dstat  -c -d -m -n -r --fs -t  2  5
fi
}

while true 
do
    menu
    read -p "Please input your option: "  option;echo
    case $option in
        n)
        netstat -n | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a, S[a]}';;
        j)
        tomcat_status;;
	tc)
	tomcat_config;;
	p)
	find_tomcat_port;;
        jv)
        jvm_ps_old;;
	d)
	dump_tomcat;;
        tr)
        restart_tomcat;;
        tf)
        tailf_log;;
        ngx)
        ps -ef|grep nginx | grep -v grep;;
	ds)
	os_status;;
        o)  
        read -p "enter the path you want to open the file:" vpath
        vi $vpath;;
        oo)
        read -p "enter the path you want to open the file:" vpath
        vim $vpath;;
        c)
        /bin/bash;;
        l)
        clear;;
        y)
        yum_repo;;
        q)
        exit;;
        *)
        echo "inpit error..please input it again..[j|tc|p|jv|d|tr|tf|ngx|o|oo|c|l|q]";;
    esac
done
