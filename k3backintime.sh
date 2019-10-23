#!/bin/bash

# RU
# Программа для отката установленных обновлений для AstraLinux, Debian, Ubuntu
# в /etc/apt/sources.list должны быть подключены 2 источника: 
# репозиторий который использовался до обновлений и репозиторий с которого были установлены обновления 
# (например stable и testing, или stable и sid)
# для Смоленска:
# это диск из поставки и диск с обновлениями
# (если использовался диск со средствами разработки то + еще 2 диска со средствами разработки,
# оригинальный диск со средствами разработки и диск со средствами разработки для апдейта)

# EN
# Program for uninstall unsuccesfull upgrades for Astra, Debian and Ubuntu based systems
# in /etc/apt/sources.list must be connected 2 sources:
# repository used before updates and repository used for updates
# for example stable and testing repository, or stable and sid
# Minsk SE Edition:
# if devel disk used on system, you must connect 2 devel disks too
# original devel disk and devel disk from update

# Author: Alexey Kovin <4l3xk3@gmail.com>
# All rights reserved
# Russia, Electrostal, 2019

# Localization
# ------------
function echo_en () {
    if [ x"$LANG" != "xru_RU.UTF-8" ]; then
        echo "$1"
    fi
}

function echo_ru () {
    if [ x"$LANG" = "xru_RU.UTF-8" ]; then
        echo "$1"
    fi
}

#if [ x"$1" != "x" ] ;then
#	NUM_DAYS=$1
#fi

UPLIST="/tmp/time_up.list"
VER_LIST="/tmp/time_ver.list"
INST_CMD="/tmp/time_install.cmd"
ACT_LOG="/tmp/time_actions.log"
date > $ACT_LOG 
echo "apt install --allow-downgrades \\" > $INST_CMD

src_num=`cat /etc/apt/sources.list | grep "^deb" | wc -l`

if [ $src_num -ne 2 ] ;then
	echo "error: You must set 2 repositories in sources list: original and update"
	echo "for example stable and tesing"
	echo "repositories in sources.list now = $src_num"
	exit 1
fi

#apt update
#if [ $? ] ;then
#	"error: Can't connect to repositoties"
#	exit 1
#fi 

#if [ x"$1" != "x" ] ;then
#find /var/lib/dpkg/info/ -name \*.list -mtime -${NUM_DAYS} | sed 's#.list$##;s#.*/##' > $UPLIST
#else
find /var/lib/dpkg/info/ -name \*.list | sed 's#.list$##;s#.*/##' > $UPLIST
#fi

for debfile in `cat $UPLIST` ; do
	echo "processing $debfile .." 
	echo "processing $debfile .." >> $ACT_LOG
	LANG=C apt-cache policy $debfile >> $ACT_LOG
	inst_ver=`LANG=C apt-cache policy $debfile | grep Installed | awk -F" " '{print $2}'`
	echo "installed = $debfile $inst_ver" >> $ACT_LOG
#check
	LANG=C apt-cache show $debfile | grep "^Version" > $VER_LIST
	numlines=`wc -l $VER_LIST | cut -f1 -d" "`
	echo "numlines = $numlines" >> $ACT_LOG
	if [ $numlines -lt 2 ] ;then
	    echo "------------" >> $ACT_LOG
	    echo "deb=$debfile" >> $ACT_LOG
	    echo "error: too few sources" >> $ACT_LOG
	    cat $VER_LIST >> $ACT_LOG
	    echo "-----" >> $ACT_LOG
	    LANG=C apt-cache policy $debfile >> $ACT_LOG
	    echo "-----" >> $ACT_LOG
	    echo "------------" >> $ACT_LOG
	    continue
	fi
	if [ $numlines -gt 2 ] ;then
	    echo "------------" >> $ACT_LOG
	    echo "deb=$debfile" >> $ACT_LOG
	    echo "error: too many sources" >> $ACT_LOG
	    cat $VER_LIST >> $ACT_LOG
	    echo "-----" >> $ACT_LOG
	    LANG=C apt-cache policy $debfile >> $ACT_LOG
	    echo "-----" >> $ACT_LOG
	    echo "------------" >> $ACT_LOG
	    continue
	fi

#find
	ver1=`LANG=C cat $VER_LIST | head -n 1 | sed  s'/Version:\ //'`
	ver2=`LANG=C cat $VER_LIST | tail -n 1 | sed  s'/Version:\ //'`
	echo "ver1=$ver1"; echo "ver2=$ver2" >> $ACT_LOG
	if [ `dpkg --compare-versions $ver1 eq $ver2` ] ;then
	    echo "versions are the same" >> $ACT_LOG
	    continue
	fi
	
	if [ `dpkg --compare-versions $ver1 lt $ver2` ] ;then
	    echo "destination old version: $ver1" >> $ACT_LOG
	    dest_ver=$ver1
	else
	    echo "destination old version: $ver2" >> $ACT_LOG
	    dest_ver=$ver2
	fi

#create reinstall command with list 
	echo "********* reinstall packet $debfile from $inst_ver to $dest_ver"
	echo "********* reinstall packet $debfile from $inst_ver to $dest_ver" >> $ACT_LOG
	echo "$debfile=$dest_ver \\" >> $INST_CMD

done
echo "" >> $INST_CMD
echo "apt install --reinstall libgost-astra" >> $INST_CMD
echo "apt -f install" >> $INST_CMD
chmod 755 $INST_CMD
echo_en "To rollback packages now run: $INST_CMD"
echo_en "Check actions before run !"
echo_ru "Чтобы откатить обновление запустите команду : $INST_CMD"
echo_ru "Проверьте предлагаемые действия перед запуском !"
