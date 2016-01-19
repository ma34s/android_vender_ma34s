#!/bin/bash

device_name=$2
if [ "$device_name" = "" ]; then
	hash_list=hashlist.txt
	changeset=changeset.txt
else
	hash_list=hashlist_$device_name.txt
	changeset=changeset_$device_name.txt
fi

func_check_target()
{
	kbc=`git remote -v | grep 'kbc-developers/'`
	cm=`git remote -v | grep 'CyanogenMod/'`
	aosp=`git remote -v | grep 'android.googlesource.com/'`
	#echo $kbc$cm$aosp
	if [ "$kbc$cm$aosp" = "" ]; then
		exit
	fi
}

func_sub_changeset() {
	func_check_target	
	cur=`pwd| sed -e "s|$BASE_DIR/||g"`
	_hash_list=$BASE_DIR/$hash_list

	sta=`grep $cur: $_hash_list | cut -d':' -f2`

	if [ "$sta" = "" ]; then
		echo -------------------------------------------------------
		echo "$cur"
		echo " ($REPO_PROJECT)"
		echo -------------------------------------------------------
		echo "  this is first release"
		echo;
	else
		log=`git log --oneline --no-merges $sta..HEAD`
		if [ ! -z "$log" ]; then
			echo -------------------------------------------------------
			echo "$cur"
			echo " ($REPO_PROJECT)"
			echo -------------------------------------------------------
			echo "$log"
			echo;
		fi
	fi

}

func_sub_hash_list() {
	func_check_target
	cur=`pwd| sed -e "s|$BASE_DIR/||g"`
	echo "$cur:`git log -1 --pretty=format:"%H"`"
}

func_changeset()
{
	export BASE_DIR=`pwd`
	if [ -f $hash_list ]; then
		echo ======================================================= |tee $changeset
		if [ "$device_name" = "" ]; then
			echo "changeset" | tee -a $changeset
		else
			echo "changeset for $device_name" | tee -a $changeset
		fi
		echo =======================================================| tee -a $changeset
		repo forall -c sh $BASE_DIR/$0 --sub-changeset $device_name | tee -a $changeset
	else
		echo "$hash_list is not exist"
	fi

	echo output hashlist to $changeset
}

func_hash_list() {
	export BASE_DIR=`pwd`
	repo forall -c sh $BASE_DIR/$0 --sub-hashlist $device_name 2>&1 | tee $hash_list
	echo;
	echo output hashlist to $hash_list
}

func_usege() {
	echo "usage is below:"
	echo "  `basename $0` -c|-l [\"device_name\"]"

	exit 1
}




case "$1" in
  "-l" ) func_hash_list ;;
  "-c" ) func_changeset ;;
  "--sub-changeset"  ) func_sub_changeset ;;
  "--sub-hashlist"  ) func_sub_hash_list ;;
  * ) func_usege ;;
esac





