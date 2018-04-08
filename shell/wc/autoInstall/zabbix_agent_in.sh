#!/bin/bash
path=$(pwd)
Vsersion="3.0.4"
ServerIP="10.139.49.70"
DownloadIP="http://10.139.49.70:8088"

groupadd zabbix
useradd zabbix -g zabbix

wget $DownloadIP/zabbix-$Vsersion.tar.gz   &> /dev/null
tar zxvf zabbix-$Vsersion.tar.gz 	 &> /dev/null
cd zabbix-$Vsersion
./configure --prefix=/usr/local/zabbix_agent  --enable-agent   --enable-snmp	 &> /dev/null
make	 &> /dev/null
make install	 &> /dev/null

if [ $? -eq 0 ]
then
	echo -e  "\n\n#######################  install  successful  #########################\n"
else
        echo -e  "\n\n#######################  install  filad  #########################\n" && exit 20
fi


cd /usr/local/zabbix_agent/etc/
sed -i "s/^Server=127.0.0.1/Server=$ServerIP/g"  zabbix_agentd.conf 
sed -i "s/^ServerActive=127.0.0.1/ServerActive=$ServerIP/g"  zabbix_agentd.conf 
grep $ServerIP  zabbix_agentd.conf  &> /dev/null
if [ $? -eq 0 ]
then
	echo -e  "\n\n#######################  updata  successful  #########################\n"
else
	echo -e  "\n\n#######################  updata  filad  #########################\n" && exit 19
fi

cp $path/zabbix-$Vsersion/misc/init.d/fedora/core/zabbix_agentd /etc/init.d/
chmod a+x /etc/init.d/zabbix_*
ln -s /usr/local/zabbix_agent/sbin/*  /usr/local/sbin/
ln -s /usr/local/zabbix_agent/bin/*   /usr/local/bin/ 
/etc/init.d/zabbix_agentd  start  

chkconfig --add /etc/init.d/zabbix_agentd
chkconfig zabbix_agentd on


cd  $path
mv  zabbix-$Vsersion.tar.gz  zabbix-$Vsersion zabbix_agent_autoinstall.sh  /data/soft
