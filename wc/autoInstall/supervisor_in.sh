#!/bin/bash

## supervisor aotu install
## --baiyongjie 2017/07/04

SERVERIP= address

OSVERSION=`sed -r "s/.*[ ]([0-9])(.*)/\1/"  /etc/redhat-release`
if [ $OSVERSION -eq 6 ]
then
	LOCALIP=`ifconfig  | grep "inet addr:" | grep -v '127.0.0.1' | sed 's/^.*addr:\(.*\)  Bc.*$/\1/g' | tail -1`
elif [ $OSVERSION -eq 7 ]
then
	LOCALIP=`ifconfig | grep inet | grep -Ev "inet6|127.0.0.1" | sed 's/^.*inet \(.*\)  ne.*$/\1/g' | tail -1`
fi


netstat -nplt | grep 9001  &> /dev/null
if [ $? -eq 0 ]
then
        echo -e "\nSupervisord  has Start !!\nThe install script has quit\n"
        exit 10
fi


yum list | grep python-setuptools  > /dev/null
if [ $? -eq 0 ]
then
	yum -y install python-setuptools  > /dev/null
else
	echo "please check your yum..."
fi

rpm -qa |grep python-setuptools  > /dev/null
if [ $? -eq 0 ]
then
        easy_install supervisor  > /dev/null
	if [ $? -ne 0 ]
	then
	        wget http://$SERVERIP/download/meld3-1.0.2.tar.gz  > /dev/null
	        echo  "Download meld3..."
        	tar zxf meld3-1.0.2.tar.gz
	        cd meld3-1.0.2
	        python setup.py install  > /dev/null
	        wget http://$SERVERIP/download/supervisor-3.3.2.tar.gz     > /dev/null
	        echo  "Download supervisor..."
	        tar zxf supervisor-3.3.2.tar.gz
	        cd supervisor-3.3.2
	        python setup.py install > /dev/null
	fi
else
        echo "please check rpm 'python-setuptools...'"
fi

echo_supervisord_conf  > /dev/null
if [ $? -eq 0 ]
then
	mkdir -m 755 -p /etc/supervisor/  &> /dev/null
	echo_supervisord_conf > /etc/supervisor/supervisord.conf
	mkdir -m 755 /etc/supervisor/conf.d   &> /dev/null
        sed -i 147,148d   /etc/supervisor/supervisord.conf
        sed -i 22,25d   /etc/supervisor/supervisord.conf
	echo '[include]
files = /etc/supervisor/conf.d/*.conf'  >>  /etc/supervisor/supervisord.conf

	echo -e "\n[inet_http_server]         
port=$LOCALIP:9001   
username=admin           
password=baiyongjie"  >>  /etc/supervisor/supervisord.conf
else
	echo "please check supervisord_conf..."
fi


if [ $OSVERSION -eq 6 ]
then
echo '#!/bin/bash
#
# supervisord   This scripts turns supervisord on
#
# description:  supervisor is a process control utility.  It has a web based
#               xmlrpc interface as well as a few other nifty features.
# processname:  supervisord
# config: /etc/supervisor/supervisord.conf
# pidfile: /var/run/supervisord.pid


# source function library
. /etc/rc.d/init.d/functions

RETVAL=0

start() {
    echo -n $"Starting supervisord: "
    daemon "supervisord -c /etc/supervisor/supervisord.conf "
    RETVAL=$?
    echo
    [ $RETVAL -eq 0 ] && touch /var/lock/subsys/supervisord
}

stop() {
    echo -n $"Stopping supervisord: "
    killproc supervisord
    echo
    [ $RETVAL -eq 0 ] && rm -f /var/lock/subsys/supervisord
}

restart() {
    stop
    start
}

case "$1" in
  start)
    start
    ;;
  stop) 
    stop
    ;;
  restart|force-reload|reload)
    restart
    ;;
  condrestart)
    [ -f /var/lock/subsys/supervisord ] && restart
    ;;
  status)
    status supervisord
    RETVAL=$?
    ;;
  *)
    echo $"Usage: $0 {start|stop|status|restart|reload|force-reload|condrestart}"
    exit 1
esac

exit $RETVAL' > /etc/init.d/supervisord  
fi
 
if [ $OSVERSION -eq 6 ]
then
	echo -e "\n"
	chmod 755 /etc/init.d/supervisord
	/etc/init.d/supervisord start
	chkconfig --level  35 supervisord on  &> /dev/null
	chkconfig --list | grep supervisord   &> /dev/null
elif [ $OSVERSION -eq 7 ]
then
	supervisord -c /etc/supervisor/supervisord.conf   &> /dev/null
fi

netstat -nplt | grep 9001  &> /dev/null
if [ $? -eq 0 ]
then 
	echo -e "\nSupervisord  Start  successful !!\n"
else
	echo -e "\nSupervisord  Start  Failure... please check\n"
fi

