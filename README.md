# Simple bash-backup(BB) script

Basic option - script takes all files with specified extension in the folder and puts them in the ZIP archive which will be in a special directory. 

If you don't specify any options, the script will execute his basic option (he makes one backup).

For successful using, you need to specify the path to the files for the backup, the file's extension, and the path to save the backup (archive).
	
Additional options: script can work with a certain period, you can specify a limit on the number of backups(the default limit is 54) and you can also check  the archive data integrity (with sum).
