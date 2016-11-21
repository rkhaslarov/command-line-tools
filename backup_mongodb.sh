#!/bin/bash

# Скрипт backup-a БД для разработчиков портала готов. Скрипт лежит в папке collections-backup, называется backup_db.sh.
# Команда запуска: ./backup_db.sh -d DB_NAME -h HOST -p PORT (например, ./backup_db.sh -d core -h localhost -p 3001).
# Значения по умолчанию:
# DB_NAME - test;
# HOST - localhost;
# PORT - 27017;

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

folder_name=`date +"%d-%m-%y-%s"`
collections=(`echo "show collections" | mongo $dbName --host=$host --port=$port > /dev/null`)
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
