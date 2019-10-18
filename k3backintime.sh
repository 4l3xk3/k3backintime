#!/bin/bash

#Program for uninstall unsuccesfull upgrades for Astra, Debian and Ubuntu based systems
#apt-show-versions
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

#if [ x"$1" == "x" ] ;then
#    echo "Error.."
#    echo "Usage: ./k3backintime <num_of_days>"
#    exit 1
#fi
#NUM_DAYS=$1
#NUM_DAYS=9999

export LANG=C
UPLIST="/tmp/time_up.list"
VER_LIST="/tmp/time_ver.list"
INST_CMD="/tmp/time_install.cmd"
ERR_LOG="/tmp/time_err.log"
date > $ERR_LOG 
echo "apt install -y --allow-downgrades \\" > $INST_CMD

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


#find /var/lib/dpkg/info/ -name \*.list -mtime -${NUM_DAYS} | sed 's#.list$##;s#.*/##' > $UPLIST
#| sed 's/:.*//' > $UPLIST

find /var/lib/dpkg/info/ -name \*.list | sed 's#.list$##;s#.*/##' > $UPLIST

for debfile in `cat $UPLIST` ; do
	echo "processing $debfile .."
apt-cache policy $debfile 
	inst_ver=`apt-cache policy $debfile | grep Installed | awk -F" " '{print $2}'`
	echo "installed = $debfile $inst_ver"
#check
	apt-cache show $debfile | grep "^Version" > $VER_LIST
	numlines=`wc -l $VER_LIST | cut -f1 -d" "`
	echo "numlines = $numlines"
	if [ $numlines -lt 2 ] ;then
	    echo "------------" >> $ERR_LOG
	    echo "deb=$debfile" >> $ERR_LOG
	    echo "error: too few sources" >> $ERR_LOG
	    cat $VER_LIST >> $ERR_LOG
	    echo "-----" >> $ERR_LOG
	    apt-cache policy $debfile >> $ERR_LOG
	    echo "-----" >> $ERR_LOG
	    echo "------------" >> $ERR_LOG
	    continue
	fi
	if [ $numlines -gt 2 ] ;then
	    echo "------------" >> $ERR_LOG
	    echo "deb=$debfile" >> $ERR_LOG
	    echo "error: too many sources" >> $ERR_LOG
	    cat $VER_LIST >> $ERR_LOG
	    echo "-----" >> $ERR_LOG
	    apt-cache policy $debfile >> $ERR_LOG
	    echo "-----" >> $ERR_LOG
	    echo "------------" >> $ERR_LOG
	    continue
	fi

#find
	ver1=`cat $VER_LIST | head -n 1 | sed  s'/Version:\ //'`
	ver2=`cat $VER_LIST | tail -n 1 | sed  s'/Version:\ //'`
	echo "ver1=$ver1"; echo "ver2=$ver2"
	if [ `dpkg --compare-versions $ver1 eq $ver2` ] ;then
	    echo "versions are the same"
	    continue
	fi
	
	if [ `dpkg --compare-versions $ver1 lt $ver2` ] ;then
	    echo "destination old version: $ver1"
	    dest_ver=$ver1
	else
	    echo "destination old version: $ver2"
	    dest_ver=$ver2
	fi

#create reinstall command with list 
	echo "********* reinstall packet $debfile from $inst_ver to $dest_ver"
	echo "$debfile=$dest_ver \\" >> $INST_CMD

done
echo "" >> $INST_CMD
echo "apt install --reinstall libgost-astra" >> $INST_CMD
echo "apt -f install" >> $INST_CMD
chmod 755 $INST_CMD
echo "to rollback packages now run: $INST_CMD" 
#sh $INST_CMD
#apt -f -y install

