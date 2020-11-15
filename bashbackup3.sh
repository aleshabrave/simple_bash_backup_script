#!/bin/bash

dpkg -s zip >/dev/null
if (( $? != 0 ));then
	echo "You need to install zip \"(sudo apt-get install zip)\""
	exit 1
fi
dpkg -s unzip >/dev/null
if (( $? != 0 ));then 
	echo "You need to install unzip \"(sudo apt-get install unzip)\""
	exit 1
fi
if (( $# == 0 ));then 
	echo -e "\e[41mNo arguments\e[0m"
	echo "Use --help for help"
	exit 1
fi
if [[ $1 == "--help" ]];then
	echo "Usage: .../backup.sh [OPTION] ... PATH EXTENSION PATH
	Main information: you need to have zip and unzip utils. 
	Basic option - script takes all files with specified extension in the folder
	and puts them in the ZIP archive which should be in a special directory. 
	If you do not specify any options, then the script will execute his basic option
	\(he makes one backup\).
	For successful use, you need to specify the path to the files for the backup, 
	the file's extension, and the path to save the backup(archive).
	
	Additional options: script can work with a certain period, you can specify
	a limit on the number of backups(the default limit is 54) and you can also check 
	the archive data integrity\(with sum\).
	
	Options:
	
	-c                  use to check the archive data integrity, you must specify 
						three arguments:
							1) the path to the directory with the source files;
							2) the file's extension;
							3) the full path to the archive;
	-p                  use to set a period of making backups:
							1) you must specify period after -p;
						then arguments for basic option.
	-l                  use to set a max quantity of archives \(the last archives by date
						of creation are deleted until the number of backups does't equal 
						limit - 1, and then a new backup is made\):
							1) you must specify limit after -l; 
						then arguments for basic option.
	"
	exit 1
fi
function check_argument(){
	if [[ $2 == -* ]];then 
		echo "Option $1 requires an argument" >&2 
		exit 1
	fi
	re='^[0-9]+$'
	if ! [[ $2 =~ $re ]]; then
		echo "Option $1 requires a one number" >&2 
		exit 1
	fi
}
period=-1
limit=54
index=0
while getopts "l:p:c" opt;do
	case $opt in
	l)
		check_argument "-l" "$OPTARG"
		limit=$OPTARG
		index=$OPTIND
	;;
	p)
		check_argument "-p" "$OPTARG"
		period=$OPTARG
		index=$OPTIND
	;;
	c)
		shift
		if [ -z $1 ];then
			echo "Specify the path to the directory with the source files" >&2
		fi
		if [ -z $2 ];then 
			echo "Specify the file's extension" >&2 
		fi
		if [ -z $3 ];then
			echo "Specify the full path to the archive" >&2
			exit 1 
		fi
		if (( $# > 3 ));then
			echo "Too much arguments" >&2
			exit 1
		fi
		indir=$1
		ext=$2
		outdir=$3
		if [ -r $indir/forsum ];then 
			rm -r $indir/forsum
		fi
		mkdir $indir/forsum 2>/dev/null
		if (( $? != 0 ));then
			echo "Paths are wrong(maybe one of)" >&2
			exit 1
		fi
		unzip $outdir -d $indir/forsum >/dev/null
		if (( $? != 0 )); then
			echo "Not such archive" >&2
			exit 1
		fi
		cd $indir/forsum || exit 1
		cd "$(ls)" || exit 1
		for i in $(cat -- *$ext | md5sum);do
			origSum=$i
			break
		done
		cd ../..
		for i in $(cat -- *$ext | md5sum);do
			zipSum=$i
			break
		done
		if [ "$origSum" = "$zipSum" ];then 
			echo -e "\e[42mControl of amounts was passed\e[0m" >&2
		else 
			echo -e "\e[41mControl of amounts was not passed\e[0m" >&2
		fi
		rm -r forsum || exit 1
		exit 1
	;;
	\?)
		echo "No such option" >&2
		echo "Use --help for help"
		exit 1
	;;
	*) 
		echo "No such option" >&2
		echo "Use --help for help"
		exit 1
	;;
	esac
done
for (( i = 0; i < index - 1; i++ ));do
	shift
done
if [ -z $1 ];then
	echo "Specify the path to the directory with the source files" >&2
fi
if [ -z $2 ];then 
	echo "Specify the file extension" >&2 
fi
if [ -z $3 ];then
	echo "Specify the path to the folder where the archive will be located" >&2
	exit 1 
fi
indir=$1
ext=$2
outdir=$3
for(( i = 0; i > -1; i++ ))
do
	x=1
	for j in $(ls -t ${outdir}/backup*zip 2>/dev/null);do
		if (( x < limit ));then 
			((x++))
			continue
		fi
		rm "$j"
	done
	n=$RANDOM
	if [ -f "${outdir}backup$n.zip" ];then
		n=$((RANDOM*i*i*i+RANDOM))
	fi
	zip "${outdir}/backup$n.zip" $(ls $indir/*$ext 2>/dev/null) >/dev/null
	if (( $? == 0 ));then 
		echo -e "\e[42mThe archive was created successfully\e[0m" 
	else 
		echo "The archive wasn't created. 
Maybe there are no files with the required extension
or one of the paths was specified incorrectly." >&2
	fi  
	if (( period >= 0 ));then
		sleep $period
	else 
		exit 1
	fi
done
