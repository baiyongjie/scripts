#!/bin/bash

### version 1.0 2018-02-22 ####
### created by Baiyongjie  ####

menu(){
echo  "
Now user:$(who | awk '{print $1}')
Now the time:$(date "+%Y-%m-%d-%T")
OS_version:$(cat /etc/redhat-release )
==========================
Menu:
==========================
     -- 1. Show tcp_status   
     -- 2. Show Run_tomcat
     -- 3. Show tomcat_config  
     -- 4. Find tomcat_port
     -- 5. Dump tomcat_info    
     -- 6. Show OS_status
     -- 7. Show disk_free     
     -- 8. Show disk_io_status
     -- 9. Show Memory_free
     -- [88|quit|exit]. Exit script 
==========================
"

}

tcp_status(){
netstat -n | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a, S[a]}'
}

tomcat_status(){
echo  "-User-Pid-   --------Tomcat  directory-------"
ps -ef|grep java | grep -v grep |grep -v DocumentService-1.2.jar | awk '{print $1, $2,  $(NF-3)}' |sed 's/-Dcatalina.home=//g'
}

tomcat_config(){
tomcat_status;echo
read -p "Please enter the pid: " TOMCAT_PID;echo
TOMCAT_PATH=$(tomcat_status | grep $TOMCAT_PID | awk '{print $3}')
if [ ! -d $TOMCAT_PATH ] ||  [ -z $TOMCAT_PATH ] 
then
    echo " $TOMCAT_PATH  is Null Directory..  Script exit.. "
    exit
fi 

#catalina.sh
echo -e "\033[36m$TOMCAT_PATH/bin/catalina.sh\033[0m"
echo -e "\033[32m----  Catalina  config  begin----\033[0m"
grep  "^JAVA_HOME="   $TOMCAT_PATH/bin/catalina.sh
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

#sfa_properties
grep "docBase" "$TOMCAT_PATH/conf/server.xml"   > /dev/null
if [ $? -eq 0 ]
then
    grep "docBase" "$TOMCAT_PATH/conf/server.xml" | grep ' <!--<Context'  > /dev/null
    if [ $? -eq 0 ]
    then
        appbase=$(grep "appBase" "$TOMCAT_PATH/conf/server.xml" | awk -F= '{print $3}'|awk -F\" '{print $2}')
	if [ "$appbase" = "webapps" ]
        then
            sfa_properties=$(find $TOMCAT_PATH/$appbase -type f -name sfa.properties  | grep "WEB-INF/classes/config")
            echo -e "\033[36m$sfa_properties\033[0m"
        fi
    else
        docbase=$(grep "docBase" "$TOMCAT_PATH/conf/server.xml" | awk  '{print $4}' |awk -F"=" '{print $2}' | tr -d '"')
        sfa_properties=$(find $docbase -type f -name sfa.properties  | grep "WEB-INF/classes/config")
        echo -e "\033[36m$sfa_properties\033[0m"
    fi
else
    appbase=$(grep "appBase" "$TOMCAT_PATH/conf/server.xml" | awk -F= '{print $3}'|awk -F\" '{print $2}')
    if [ "$appbase" = "webapps" ]
    then
        sfa_properties=$(find $TOMCAT_PATH/$appbase -type f -name sfa.properties  | grep "WEB-INF/classes/config")
        echo -e "\033[36m$sfa_properties\033[0m"
    fi
fi
 
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

#jdbc_properties
grep "docBase" "$TOMCAT_PATH/conf/server.xml"   > /dev/null
if [ $? -eq 0 ]
then
    grep "docBase" "$TOMCAT_PATH/conf/server.xml" | grep ' <!--<Context'  > /dev/null
    if [ $? -eq 0 ]
    then
        appbase=$(grep "appBase" "$TOMCAT_PATH/conf/server.xml" | awk -F= '{print $3}'|awk -F\" '{print $2}')
        if [ "$appbase" = "webapps" ]
        then
            jdbc_properties=$(find $TOMCAT_PATH/$appbase -type f -name jdbc.properties  | grep "WEB-INF/classes/config")
            echo -e "\033[36m$jdbc_properties\033[0m"
        fi
    else
        docbase=$(grep "docBase" "$TOMCAT_PATH/conf/server.xml" | awk  '{print $4}' |awk -F"=" '{print $2}' | tr -d '"')
        jdbc_properties=$(find $docbase -type f -name jdbc.properties  | grep "WEB-INF/classes/config")
        echo -e "\033[36m$jdbc_properties\033[0m"
    fi
else
    appbase=$(grep "appBase" "$TOMCAT_PATH/conf/server.xml" | awk -F= '{print $3}'|awk -F\" '{print $2}')
    if [ "$appbase" = "webapps" ]
    then
        jdbc_properties=$(find $TOMCAT_PATH/$appbase -type f -name jdbc.properties  | grep "WEB-INF/classes/config")
        echo -e "\033[36m$jdbc_properties\033[0m"
    fi
fi

echo -e "\033[32m----  jdbc.properties  config  begin---- \033[0m"
grep "^jdbc.url=" $jdbc_properties
grep "^jdbc.username=" $jdbc_properties
grep "^jdbc.password="  $jdbc_properties
echo -e "\033[32m----  jdbc.properties  config  end---- \033[0m\n"

#base_properties
grep "docBase" "$TOMCAT_PATH/conf/server.xml"   > /dev/null
if [ $? -eq 0 ]
then
    grep "docBase" "$TOMCAT_PATH/conf/server.xml" | grep ' <!--<Context'  > /dev/null
    if [ $? -eq 0 ]
    then
        appbase=$(grep "appBase" "$TOMCAT_PATH/conf/server.xml" | awk -F= '{print $3}'|awk -F\" '{print $2}')
        if [ "$appbase" = "webapps" ]
        then
            base_properties=$(find $TOMCAT_PATH/$appbase -type f -name base.properties  | grep "WEB-INF/classes/config")
            echo -e "\033[36m$base_properties\033[0m"
        fi
    else
        docbase=$(grep "docBase" "$TOMCAT_PATH/conf/server.xml" | awk  '{print $4}' |awk -F"=" '{print $2}' | tr -d '"')
        base_properties=$(find $docbase -type f -name base.properties  | grep "WEB-INF/classes/config")
        echo -e "\033[36m$base_properties\033[0m"
    fi
else
    appbase=$(grep "appBase" "$TOMCAT_PATH/conf/server.xml" | awk -F= '{print $3}'|awk -F\" '{print $2}')
    if [ "$appbase" = "webapps" ]
    then
        base_properties=$(find $TOMCAT_PATH/$appbase -type f -name base.properties  | grep "WEB-INF/classes/config")
        echo -e "\033[36m$base_properties\033[0m"
    fi
fi

echo -e "\033[32m----  base.properties  config  begin---- \033[0m"
grep "^job.baseJob=" $base_properties
grep "^server.type.value=" $base_properties
grep "^security.property.placeholder="  $base_properties
echo -e "\033[32m----  base.properties  config  end---- \033[0m\n"
}

vim_tomcat_configfile(){
read -p "Open config file?[y|n]" yn
if [ $yn = y ]
then 
    read -p "Input file path: " path
    vim $path
else
    break
fi
}

find_tomcat_port(){
tomcat_status;echo
read -p "Please enter the pid: " PORTPID;echo
netstat -nplt | grep $PORTPID;echo
}

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
	echo "jmap -dump:format=b  $PID  start .."
	jmap -dump:format=b,file=/data/dump/$(date "+%Y-%m-%d")/jmap_dump_$PID.dump $PID
	echo -e "\njstack -F  $PID  start .."
	jstack -F  $PID &> /data/dump/$(date "+%Y-%m-%d")/jstack_F_$PID.txt
	echo -e "Path:/data/dump/$(date "+%Y-%m-%d")/jstack_F_$PID.txt\njstack -F  $PID  end.. \n"
	echo "jstack -l  $PID  start .."
	jstack -l $PID &> /data/dump/$(date "+%Y-%m-%d")/jstack_l_$PID.txt
	echo -e "Path:/data/dump/$(date "+%Y-%m-%d")/jstack_l_$PID.txt\njstack -l  $PID  end.. \n"
    else
        echo "exit script .."
	exit
    fi
fi
}

os_status(){
rpm -qa | grep dstat > /dev/null
if [ $? -eq 0 ]
then
    dstat  -c -d -m -n -r --fs -t  2  8
else
    yum -y install dstat  > /dev/null
    dstat  -c -d -m -n -r --fs -t  2  8
fi
}

judge_number(){
while true
do
menu

read -p "Enter a number: "  number;echo
if  [ $number = "quit" ] || [ $number = "exit" ]
then 
    exit
fi

if [ $number -ge 0 ] 
then   
    tmp=true
    break
else
    echo "error .. Enter a number .."
fi
done
}

run_case(){
while [ $tmp = true ]
do
    case $number in
        1)
        tcp_status
        break;;
        2)
        tomcat_status
	break;;
	3)
	tomcat_config 
        vim_tomcat_configfile
	break;;
	4)
	find_tomcat_port
	break;;
	5)
	dump_tomcat
	break;;
	6)
	os_status
	break;;
        7)
        df -h
        break;;
	8)
	iostat -c -x -k 2 5
	break;;
	9)
	free -m
	break;;
        88|quit|exit)
        exit;;
    esac
done
}

clear

while true
do
    judge_number
    run_case
done
