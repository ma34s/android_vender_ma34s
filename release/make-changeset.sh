#!/bin/bash


hash_list=hashlist.txt
changeset=changeset.txt

txtfile=$2/$hash_list
cur=`pwd| sed -e "s|$2/||g"`

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

	sta=`grep $cur: $txtfile | cut -d':' -f2`

	if [ "$sta" = "" ]; then
		echo =======================================================
		echo "$cur"
		echo " ($REPO_PROJECT)"
		echo =======================================================
		echo "  this is first release"
		echo;
	else
		log=`git log --oneline --no-merges $sta..HEAD`
		if [ ! -z "$log" ]; then
			echo =======================================================
			echo "$cur"
			echo " ($REPO_PROJECT)"
			echo =======================================================
			echo "$log"
			echo;
		fi
	fi

}

func_sub_hash_list() {
	func_check_target
	echo "$cur:`git log -1 --pretty=format:"%H"`"
}

func_changeset()
{
	cur=`pwd`
	repo forall -c sh $cur/$0 --sub-changeset $cur | tee $changeset
}

func_hash_list() {
	cur=`pwd`
	repo forall -c sh $cur/$0 --sub-hashlist $cur 2>&1 | tee $hash_list
}

func_usege() {
	echo "usage is below:"
	echo "  `basename $0` [-c|-l]"
}

case "$1" in
  "-l" ) func_hash_list ;;
  "-c" ) func_changeset ;;
  "--sub-changeset"  ) func_sub_changeset ;;
  "--sub-hashlist"  ) func_sub_hash_list ;;
  * ) func_usege ;;
esac





