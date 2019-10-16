#!/bin/bash

#AstraLinux SE 1.6, AstraLinux CE 2.12 update uninstaller.
#Author: Alexey Kovin 4l3xk3@gmail.com
#All rights reserved
#Russia, Electrostal, 2019

export LANG=C
UPLIST="/tmp/up.list"
VER_LIST="/tmp/ver.list"
find /var/lib/dpkg/info/ -name \*.list -mtime -3 | sed 's#.list$##;s#.*/##' | sed 's/:.*//' > $UPLIST
for debfile in `cat $UPLIST` ; do
	echo "processing $debfile .."
apt-cache policy $debfile 
	inst_ver=`apt-cache policy $debfile | grep Installed | awk -F" " '{print $2}'`
	echo "installed = $debfile $inst_ver"
#check
	apt-cache show $debfile | grep Version > $VER_LIST
	numlines=`wc -l $VER_LIST | cut -f1 -d" "`
	echo "numlines = $numlines"
	if [ $numlines -lt 2 ] ;then
	    echo "error: too few sources"
	    continue
	fi
	if [ $numlines -gt 2 ] ;then
	    echo "error: too many sources"
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

#reinstall
	echo "reinstall packet $debfile from $inst_ver to $dest_ver"
	echo "apt install $debfile=$dest_ver"
	apt install -y $debfile=$dest_ver
done
apt -f -y install
