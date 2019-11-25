#!/bin/bash
# -baiyongjie
# -20180207
# -使用rsync同步本地程序，同步后压缩

today=$(date +%Y-%m-%d)
scriptpath=/data/scripts
bakcupPath=/data/app_backup
d_source=$scriptpath/Local_path.conf 
exclude=$scriptpath/Local_exclude.conf
rsyncLog=$scriptpath/Local_Rsync-$today.log
tar_temp=$scriptpath/temp.file

#判断配置文件和目录是否存在
if [ ! -f $d_source ] || [ ! -f $exclude ]
then
	echo  "No configure file ..."
	exit 
fi

if  [ ! -d $bakcupPath ]
then
	mkdir $bakcupPath
fi

#清空临时文件
>$tar_temp

#rsync同步文件
for i in $(cat $d_source|grep -Ev "^#|^$" )
do
	rsync  -avgz  --exclude-from=$exclude  $i  $bakcupPath  >>  $rsyncLog
	#判断rsync是否同步完成
	if [ $? -eq 0 ]
	then
		echo -e "\n#########################\n$today  $i  backup  Sceesces..\n#########################\n\n\n"   >> $rsyncLog
		#获取备份目录的目录名
		grep "$today  $i  backup  Sceesces.."  $rsyncLog   | awk '{print $2}' | awk -F / '{print $NF}'>> $tar_temp

	else
		echo -e "\n#########################\n$today  $i  backup  Filed..\n#########################\n\n\n"   >> $rsyncLog
		continue
	fi
done

#将rsync同步过来的文件夹进行压缩
cd $bakcupPath
for i in $(cat $tar_temp)
do
	#判断压缩文件是否存在，存在则跳出当次循环
	if [ ! -f $i-$today.tar.gz ]
	then
		#判断rsync是否同步了新的文件，如有新增文件则进行压缩
		r_number=$(grep  $i/  $rsyncLog | wc -l)
		if [ $r_number -ge 1 ] 
		then	
			tar -zcPf  $bakcupPath/$i-$today.tar.gz  $bakcupPath/$i
		fi

	else
		continue
	fi
done

#删除7天以前的备份文件
find $bakcupPath -mtime +7 -type f -name "*.tar.gz" | xargs rm -rf 
