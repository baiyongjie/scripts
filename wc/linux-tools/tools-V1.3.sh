#!/bin/bash
###############################
###version 1.3 2018-04-13  ####
###created by Baiyongjie   ####
###############################

#++++++++++++++++++++++++#
###version 1.2###
#Add yum repo install
#Add Tomcat Jvm PS-Old-Monitoring
#++++++++++++++++++++++++#

#++++++++++++++++++++++++#
###version 1.3###
#modified menu function
#modified jv_ps_old  function
#modified dump function
#Add kill 
#Add docker function 
#++++++++++++++++++++++++#

menu(){
echo -e "\033[32m\nj:java / tc:t_config / p:t_port / jv:jvm_ps_old /d:t_dump / k:kill /tr:t_restart / tf:t_tlog / ngx:nginx
o:vi / oo:vim / ds:OS_status / n:netstat/ c:/bin/bash / l:clear / y:yum repo / dk:docker /q:exit\033[0m
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
grep -E "^JAVA_HOME=|^export JAVA_HOME="   $TOMCAT_PATH/bin/catalina.sh
grep  "^JAVA_OPTS="   $TOMCAT_PATH/bin/catalina.sh
grep  "^CATALINA_OPTS=" $TOMCAT_PATH/bin/catalina.sh
echo -e "\n"

#server.xml
echo -e "\033[36m$TOMCAT_PATH/conf/server.xml\033[0m"
grep "shutdown=" "$TOMCAT_PATH/conf/server.xml"
grep "Connector executor=" "$TOMCAT_PATH/conf/server.xml"
grep "Connector port=" "$TOMCAT_PATH/conf/server.xml"
grep "appBase" "$TOMCAT_PATH/conf/server.xml" 
grep "docBase" "$TOMCAT_PATH/conf/server.xml"
echo -e "\n"

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
    if [ $appbase = "webapps" ]
    then
        root_path=$TOMCAT_PATH/$appbase 
    else
        root_path=$appbase
    fi
fi

#root_path=/data/app/sfa/mengniu_zhuzhen/mobile_webapps
#find file is webapps/$(*)/sfa.properties 
sfa_properties=$(find $root_path -type f -name sfa.properties  | grep "WEB-INF/classes/config" )
echo -e "\033[36m$sfa_properties\033[0m"  | grep $sfa_properties  &>/dev/null
if [ $? -eq 0 ]
then
    echo -e "\033[36m$sfa_properties\033[0m"
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
    echo -e "\n"
fi

#find file is webapps/$(*)/jdbc.properties
jdbc_properties=$(find $root_path -type f -name jdbc.properties  | grep "WEB-INF/classes/config" )
echo -e "\033[36m$jdbc_properties\033[0m"   | grep $jdbc_properties  &>/dev/null
if [ $? -eq 0 ]
then
    echo -e "\033[36m$jdbc_properties\033[0m"
    grep "^jdbc.url=" $jdbc_properties
    grep "^jdbc.username=" $jdbc_properties
    grep "^jdbc.password="  $jdbc_properties
    echo -e "\n"
fi

#find file is APP_HOME/$(*)/jdbc.properties
if [ -d $TOMCAT_PATH/APP_HOME/config ] 
then
    jdbc_properties=$(find $TOMCAT_PATH/APP_HOME/config  -type f -name jdbc.properties)
    echo -e "\033[36m$jdbc_properties\033[0m"   | grep $jdbc_properties  &>/dev/null
    if [ $? -eq 0 ]
    then
        echo -e "\033[36m$jdbc_properties\033[0m"
        grep "^jdbc.url=" $jdbc_properties
        grep "^jdbc.username=" $jdbc_properties
        grep "^jdbc.password="  $jdbc_properties
        echo -e "\n"
    fi
fi

#find file is webapps/$(*)/base.properties
base_properties=$(find $root_path -type f -name base.properties  | grep "WEB-INF/classes/config" )
echo -e "\033[36m$base_properties\033[0m"   | grep $base_properties &>/dev/null
if [ $? -eq 0 ]
then
    echo -e "\033[36m$base_properties\033[0m"
    grep "^job.baseJob=" $base_properties
    grep "^server.type.value=" $base_properties
    grep "^security.property.placeholder="  $base_properties
    echo -e "\n"
fi

#find file is APP_HOME/$(*)/base.properties
if [ -d $TOMCAT_PATH/APP_HOME ]
then
    base_properties=$(find $TOMCAT_PATH/APP_HOME/config  -type f -name base.properties)
    echo -e "\033[36m$base_properties\033[0m"   | grep $base_properties &>/dev/null
    if [ $? -eq 0 ]
    then
        echo -e "\033[36m$base_properties\033[0m"
        grep "^job.baseJob=" $base_properties
        grep "^server.type.value=" $base_properties
        grep "^security.property.placeholder="  $base_properties
        echo -e "\n"
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
read -p "Please enter the pid of the dump target: " tpid;echo

tomcat_status | grep $tpid  > /dev/null
if [ $? -ne 0 ]
then
    echo "input error.. no pid.."
    continue
fi

tomcat_path=$(ps -ef| grep $tpid | grep -v grep |grep -v DocumentService-1.2.jar | awk '{print $(NF-3)}' |sed 's/-Dcatalina.home=//g')

java_home=$(grep -E  '^JAVA_HOME|^export JAVA_HOME' $tomcat_path/bin/catalina.sh | cut -d"=" -f 2| sed 's/"//g' |sed 's#/$##')
if [ -z $java_home ]
then
    java_home=$(grep -E  '^JAVA_HOME|^export JAVA_HOME' $tomcat_path/bin/startup.sh | cut -d"=" -f 2| sed 's/"//g' |sed 's#/$##')
    if [ -z $java_home ]
    then
        java_home=$(grep -E '^JAVA_HOME|^export JAVA_HOME' /etc/profile | cut -d"=" -f 2| sed 's/"//g' |sed 's#/$##' )
    fi
fi

if [ -d $java_home ]
then
    echo -e "You input tomcat is : pid:$tpid, path:$tomcat_path\n"
    read -p "continue? [y|n]" input;echo
    if [ $input = y ]
    then
	mkdir -p /data/dump/$(date "+%Y-%m-%d")  > /dev/null
	echo "jmap -heap  $tpid  start .."
	$java_home/bin/jmap -heap  $tpid &> /data/dump/$(date "+%Y-%m-%d")/jmap_heap_$tpid.txt   
	echo -e "Path:/data/dump/$(date "+%Y-%m-%d")/jmap_heap_$tpid.txt\njmap -heap  $tpid  end.. \n"
	echo "jmap -histo  $tpid  start .."
	$java_home/bin/jmap -histo $tpid &> /data/dump/$(date "+%Y-%m-%d")/jmap_histo_$tpid.txt
	echo -e "Path:/data/dump/$(date "+%Y-%m-%d")/jmap_histo_$tpid.txt\njmap -histo  $tpid  end.. \n"
	echo -e "\njstack -F  $tpid  start .."
	$java_home/bin/jstack -F  $tpid &> /data/dump/$(date "+%Y-%m-%d")/jstack_F_$tpid.txt
	echo -e "Path:/data/dump/$(date "+%Y-%m-%d")/jstack_F_$tpid.txt\njstack -F  $tpid  end.. \n"
	echo "jstack -l  $tpid  start .."
	$java_home/bin/jstack -l $tpid &> /data/dump/$(date "+%Y-%m-%d")/jstack_l_$tpid.txt
	echo -e "Path:/data/dump/$(date "+%Y-%m-%d")/jstack_l_$tpid.txt\njstack -l  $tpid  end.. \n"
        echo "jmap -dump:format=b  $tpid  start .."
        $java_home/bin/jmap -F -dump:format=b,file=/data/dump/$(date "+%Y-%m-%d")/jmap_dump_$tpid.dump $tpid
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
tomcat_status;echo
read -p "Show Jvm ps_old,please input pid:" tpid
tomcat_status | grep $tpid  > /dev/null
if [ $? -ne 0 ]
then
    echo "input error.. no pid.."
    continue
fi

tomcat_path=$(ps -ef| grep $tpid | grep -v grep |grep -v DocumentService-1.2.jar | awk '{print $(NF-3)}' |sed 's/-Dcatalina.home=//g')
java_home=$(grep -E  '^JAVA_HOME|^export JAVA_HOME' $tomcat_path/bin/catalina.sh | cut -d"=" -f 2| sed 's/"//g' |sed 's#/$##')
if [ -z $java_home ]
then
    java_home=$(grep -E  '^JAVA_HOME|^export JAVA_HOME' $tomcat_path/bin/startup.sh | cut -d"=" -f 2| sed 's/"//g' |sed 's#/$##')
    if [ -z $java_home ]
    then
        java_home=$(grep -E '^JAVA_HOME|^export JAVA_HOME' /etc/profile | cut -d"=" -f 2| sed 's/"//g' |sed 's#/$##' )
    fi
fi

$java_home/bin/jmap -heap $tpid
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

docker_menu(){
which  docker &> /dev/null
if [ $? -ne 0 ]
then
    echo "not install docker.. exit docker menu.."
    break
fi

echo -e "
==========================
\033[32mDocker Menu:\033[0m
==========================
     \033[32m-- 1. Show    Runing Dokcer container   
     -- 2. Show    All Dokcer container  
     -- 3. Enter   the Dokcer container
     -- 4. Start   Dokcer container
     -- 5. Stop    Dokcer container
     -- 6. Restart Dokcer container
     -- 7. Tail    Dokcer logs  
     -- 8. Show    Dokcer Images  
     -- q. exit\033[0m
==========================
"
}

docker_job(){
while true 
do
    docker_menu
    read -p "Please input docker option: "  dkObj;echo
    case $dkObj in
	1)
	docker ps;;
        2)
        docker ps -a;;
	3)
	docker ps
        echo;read -p "36mPlease input CONTAINER ID: " id;echo
	if [ $id == q ];then
	    echo -e "\033[36mcontinue...\033[0m";continue
	fi
	docker exec -it $id /bin/bash;;
	4)
	docker ps -a
	echo;read -p "36mPlease input CONTAINER ID: " id;echo
        if [ $id == q ];then
            echo -e "\033[36mcontinue...\033[0m";continue
        fi
	echo -e "\033[36mStart id $(docker start $id)  [ok]...\n\nRuning Docker...\033[0m"
        docker ps;;
	5)
        docker ps
        echo;read -p "Please input CONTAINER ID: " id;echo
        if [ $id == q ];then
            echo -e "\033[36mcontinue...\033[0m";continue
        fi
        echo -e "\033[36mStop id $(docker stop $id)  [ok]...\n\nRuning Docker...\033[0m"
        docker ps;;
	6)
        docker ps 
        echo;read -p "Please input CONTAINER ID: " id;echo
        if [ $id == q ];then
            echo -e "\033[36mcontinue...\033[0m";continue
        fi
        echo -e "\033[36mRestar id $(docker restart $id)  [ok]...\n\nRuning Docker...\033[0m"
        docker ps;;
	7)
        docker ps
        echo;read -p "Please input CONTAINER ID: " id;echo
        if [ $id == q ];then
            echo -e "\033[36mcontinue...\033[0m";continue
        fi
        docker logs -tf $id;;
	8)
	docker images;;
	q)
	break;;
	*)
	echo -e "\033[31mPlease input [1-9|q]...\033[0m"
    esac
done
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
	k)
	tomcat_status;echo
	read -p "input kill pid:" killpid
	kill -9 $killpid;;
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
	dk)
	docker_job;;
        q)
        exit;;
        *)
        echo "inpit error..please input it again..[j|tc|p|jv|d|tr|tf|ngx|o|oo|c|l|q]";;
    esac
done
