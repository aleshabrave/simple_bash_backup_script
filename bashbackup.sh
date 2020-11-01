#!/bin/bash

if [[ "-h" = "$1" || "-help" = "$1" ]]
then
echo "Usage: .../backup.sh [OPTION] ... bash backup...
	Basic option - script takes all files with specified extention in the folder
	and puts them in ZIP archive which shoud be in a special directory.
	
	Additional options: script can work with certain period, you can specify
	a limit on the number of backups(the default limit is 54) and you can also check the integrity of the
	reserve amount.

	Mandatory arguments [1]:
	-o,                make one backup, you must to specify three arguments:
	-one 			1) path to directory where you want to get files for backup [2];
				2) needed extention of files [3];
				3) path to directory where you want to save your ZIP archive [4].

	-oq,  		   leaves the maximum-1 number of archives and adds a new one, if the 
	-one-quantity	   limit has excedeed, and if not, then simply add a new one, like -o
			   but you must to add one more argument — a limit on the number of 
			   backups [5].
	
	-a,		   like -o but you must to add(specify period) one more argument —
	-auto			a period of backups [5].

	-aq,		   like -o + -oq + -a, so you must to scpecify six arguments:
	-auto-quantity		1) path to folder where you want to get files for backup [2];
				2) needed extention of files [3];
				3) path to folder where you want to save your ZIP archive [4];
				4) a period of backups [5];
				5) a limit on the number of backups [6].
	
	-c,		   checks the integrity of the data in the archive, you must to specify 
	-check		   three arguments: 
				1) full path to your ZIP archive [2];
				2) needed extention of files [3];
				3) path to directory where your files to backup are located [4].

	*[?] - argument number"
exit 0
fi
if [[ "-c" = "$1" || "-check" = "$1" ]]
then
cd "$4" || exit
if [ -r forsum ]; then rm -r forsum; fi
mkdir forsum
cd forsum || exit
unzip "$2" > /dev/null
for i in $(cat -- *$3 | md5sum)
do
zipSum=$i
break
done
cd .. || exit
for i in $(cat -- *$3 | md5sum)
do
origSum=$i
break
done
if [ "$origSum" = "$zipSum" ]; then echo "Control of amounts was passed"; else echo "Control of amounts was not passed"; fi
rm -r forsum
exit
fi
flag=false
period=0
quantity=54
indir=$2
exp=$3
outdir=$4
if [[ "-o" = "$1" || "-one" = "$1" ]]
then
sleep 0.1;
elif [[ "-a" = "$1" || "-auto" = "$1" ]]
then
flag=true
if [ -n "$5" ]
then
period=$5
else
echo you need to specify the period \(use -help or -h\); exit; fi
elif [[ "-aq" = "$1" || "-auto-quantity" = "$1" ]]
then
flag=true
if [ -n "$5" ]
then
period=$5
else
echo you need to specify the period \(use -help or -h\); exit; fi
if [ -n "$6" ]
then
quantity=$6
else
echo you need to specify the max quantity of zips \(use -help or -h\); exit; fi
elif [[ "-oq" = "$1" || "-one-quantity" = "$1" ]]
then
if [ -n "$5" ]
then
quantity=$5
else
echo you need to specify the max quantity of zips \(use -help or -h\); exit; fi
fi
for(( i = 0; i > -1; i++ ))
do
# $(date +"%T:%d:%m:%y")
cd "$outdir" || exit
x=1
for j in $(ls -t backup*)
do
if (( x < quantity )); then ((x++)); continue; fi
rm "$j"
done
cd "$indir" || exit
n=$RANDOM
if [ -f ""$outdir"backup$n.zip" ]; then n=$((RANDOM*i*i*i+RANDOM)); fi
zip -r ""$outdir"backup$n.zip" $(find . -name \*$exp) > /dev/null
echo "Archive was created"
if [ $flag = false ]; then exit; else sleep "$period"; fi
done
