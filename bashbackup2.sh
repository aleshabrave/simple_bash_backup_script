#!/bin/bash

dpkg -s zip >/dev/null
if (( $? != 0 )); then echo you need to install zip "(sudo apt-get install zip)"; fi
dpkg -s unzip >/dev/null
if (( $? != 0 )); then echo you need to install unzip "(sudo apt-get install unzip)"; fi
if (( $# == 0 )); then echo -e "\e[41mнет аргументов-h\e[0m"; echo используйте -h для справки; exit 1; fi
period=-1; limit=54; flag1=0; flag2=0
while getopts "lphc" opt
do
case $opt in
l) 
limit=$5; flag2=1;;
p) 
if [ -z $5 ]; then echo -e "\e[41mукажите переодичность создания архива\e[0m"; echo используйте -h для справки; exit 1; fi
period=$5; flag1=1;;
h) 
echo "Usage: .../backup.sh [OPTION] ... PATH EXTENSION PATH
	Main information: you need to have zip and unzip utils. 
	Basic option - script takes all files with specified extension in the folder
	and puts them in the ZIP archive which should be in a special directory. 
	If you do not specify any options, then the script will execute his basic option.
	For successful use, you need to specify the path to the files for the backup, 
	the file's extension, and the path to save the backup(archive).
	
	Additional options: script can work with a certain period, you can specify
	a limit on the number of backups(the default limit is 54) and you can also check 
	the archive data integrity.
	
	Options:
	
	-h                  user's manual;
	-c                  use to check the archive data integrity, you must specify 
						three arguments:
							1) the full path to the backup;
	-p                  use to set a period of making backups:
							1) you must specify fifth argument - period;
	-l                  use to set a max quantity of archives \(the last archives by date
						of creation are deleted until the number of backups does't equal limit - 1,
						and then a new backup is made\):
							1) you must specify fifth argument or if you use -p then sixth 
						argument - limit; 
	"; exit 1;;
c) 
if [ -z $2 ]; then echo -e "\e[41mукажите путь к директории с исходными файлами\e[0m"; fi
if [ -z $3 ]; then echo -e "\e[41mукажите расширение файлов\e[0m"; fi
if [ -z $4 ]; then echo -e "\e[41mукажите путь к архиву\e[0m"; echo используйте -h для справки; exit 1; fi
indir=$2; ext=$3; outdir=$4
rm -r $indir/forsum . 2>/dev/null
rm -r $indir/forsum1 . 2>/dev/null
mkdir $indir/forsum
mkdir $indir/forsum1
zip -r "$indir/backup.zip" $(find $indir/ -name \*$ext) >/dev/null
unzip $outdir -d $indir/forsum > /dev/null
unzip $indir/backup.zip -d $indir/forsum1 > /dev/null
diff -qr $indir/forsum $indir/forsum1 > /dev/null
if (( $? == 0 )); then echo -e "\e[42mархив проверку прошёл\e[0m"; 
else echo -e "\e[41mархив проверку не прошёл\e[0m"; fi
rm -r $indir/forsum . 2>/dev/null
rm -r $indir/forsum1 . 2>/dev/null
rm $indir/backup.zip
exit 1;;
*) echo -e "\e[41mтакой опции нет\e[0m"; echo используйте -h для справки; exit 1;;
esac
done

if (( flag1+flag2 == 2 )); then 
if [ -z $6 ]; then echo -e "\e[41mвы забыли ввести значение для максимального количества архивов\e[0m"; exit 1; fi; limit=$6; fi
if [ -z $1 ]; then echo -e "\e[41mукажите путь к директории с исходными файлами\e[0m"; fi
if [ -z $2 ]; then echo -e "\e[41mукажите расширение файлов\e[0m"; fi
if [ -z $3 ]; then echo -e "\e[41mукажите путь к архиву\e[0m"; echo используйте -h для справки; exit 1; fi
if (( flag1+flag2 == 0 )); then indir=$1; ext=$2; outdir=$3; else indir=$2; ext=$3; outdir=$4; fi
for(( i = 0; i > -1; i++ ))
do
x=1
for j in $(ls -t ${outdir}/backup*zip 2>/dev/null); do
if (( x < limit )); then ((x++)); continue; fi; rm "$j"; done
n=$RANDOM
if [ -f "${outdir}backup$n.zip" ]; then n=$((RANDOM*i*i*i+RANDOM)); fi
zip -r "${outdir}/backup$n.zip" $(find $indir/ -name \*$ext 2>/dev/null) >/dev/null
if (( $? == 0 )); then echo -e "\e[42mархив был успешно создан\e[0m"; else echo -e "\e[41mчто-то пошло не так\e[0m"; echo используйте -h для справки; fi  
if (( period >= 0 )); then sleep $period; else exit 1; fi
done