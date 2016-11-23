#!/bin/bash

# Description:
# 	This shell script is used for full backuping of all collections in current database.
# Usage:
# 	./backup_mongodb.sh -d DB_NAME -h HOST -p PORT (for example, ./backup_mongodb.sh -d core -h localhost -p 3001)
# Default values: 
# 	DB_NAME - test;
# 	HOST - localhost;
# 	PORT - 27017.

while getopts ":d:h:p:" opt; do
  case $opt in
    d) dbName="$OPTARG"
    ;;
    h) host="$OPTARG"
    ;;
    p) port="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

if [ -z "$dbName" ]
then
	dbName="test"
fi

if [ -z "$host" ]
then
	host="localhost"
fi

if [ -z "$port" ]
then
	port="27017"
fi

netstat -tunlp 2>/dev/null | grep $port >/dev/null;

if [ $? -eq 0 ]
then

	folder_name=`date +"%d-%m-%y-%s"`
	collections=(`echo "show collections" | mongo $dbName --host=$host --port=$port --quiet`)
	colsLength=${#collections[*]};

	if [ $colsLength -gt 0 ]
	then
		mkdir $folder_name
		
		printf '=%.0s' {1..50}
		printf "\nDatabase: %s\nCollections: %s\n" "$dbName" "$colsLength"
		printf '=%.0s' {1..50}
		printf "\n%s\n" "Backup started. Please, wait..."
		printf '=%.0s' {1..50}
		printf "\n%s"

	   	for collection in "${collections[@]}";
		do 
			mongoexport --host=$host --port=$port --db $dbName  --collection $collection --out ./${folder_name}/${collection}.json  > /dev/null
			printf "Collection: %s OK \n" "$collection"  
		done

		printf '=%.0s' {1..50}
		printf "\n%s\n" "Backup finished successfully!"
		printf '=%.0s' {1..50}
		printf "\n%s"
	else
	  	echo "Sorry this database is empty! Check your connection or database name!";
	fi

else
	printf '=%.0s' {1..50}
	printf "\n%s %s\n" "MongoDB is not running on" "$host:$port!"
	printf '=%.0s' {1..50}
	printf "\n%s"
fi