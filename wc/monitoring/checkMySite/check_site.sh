#!/bin/bash


scriptpath=`pwd`
mysite=$scriptpath/http_site
check_status=$scriptpath/temp_status
historyfile=$scriptpath/history/`date  +%Y-%m-%d`/`date +%T`
failurefile=$scriptpath/history/`date  +%Y-%m-%d`/`date +%T`_failure
mkdir -p $scriptpath/history/`date  +%Y-%m-%d` &>/dev/null
for  site in $(grep -v  -E "^#|^$" $mysite | awk '{print $1}')
do
       curl -s  -I  --connect-timeout 10 -m 10  $site  | grep  "HTTP/1.1"  | awk '{print $2}'  >  $check_status
       status=`cat $check_status`
       if [[ $status -eq 200 ]] || [[ $status -eq 302 ]]
       then
               echo  "$(grep $site $mysite)  +++Access Successful"      >>$historyfile
       else
               echo  "$(grep $site $mysite)  ---Access Failure"         >>$historyfile
       fi
done
grep "Access Failure" $historyfile  &>/dev/null
if      [ $? -eq 0 ]
then
       echo -e "\n\nThe following tomcat is Access Failure !!!\n"  >> $failurefile
       echo -e "#############################################"  >> $failurefile
       grep "Access Failure" $historyfile  >> $failurefile
       echo -e "#############################################" >> $failurefile
       echo -e "\n\nThe following tomcat is Accessible.\n"   >> $failurefile
       echo -e "#############################################" >> $failurefile
       grep "Access Successful" $historyfile  >> $failurefile 
       echo -e "#############################################\n"   >> $failurefile
       mail -s "SFA_cofcoko_Tomcat_Check !!!"  baiyongjie@winchannel.net   <  $failurefile
fi
