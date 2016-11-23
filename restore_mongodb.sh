#!/bin/bash

# Команда запуска: ./setupdb.sh -d DB_NAME -h HOST -p PORT -b BACKUP_FOLDER

# Решил сделать скрипт с поддержкой ключей, так как задаю значения по умолчанию при отсутствии значения.
# Кроме, того скрипт проверяет работает ли сервер MongoDB. Любой из аргументов можно опустить, тогда автоматически
# будет подставлено значение по умолчанию (см. ниже). Также, для того чтобы добавить новую коллекцию достаточно сбросить 
# ее json в папку с нужным Вам backup-ом, скрипт создаст ее автоматически.

# Значения по умолчанию:

# DB_NAME - test;
# HOST - localhost;
# PORT - 27017;
# BACKUP_FOLDER - последний backup в текущей папке.

while getopts ":d:h:p:b:" opt; do
  case $opt in
    d) dbName="$OPTARG"
    ;;
    h) host="$OPTARG"
    ;;
    p) port="$OPTARG"
    ;;
    b) backup_name="$OPTARG"
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

if [ -z "$backup_name" ]
then
	backup_name=`ls -d */ | grep -e '^[0-9]' | sort | sed 's/.$//' | tail -n 1`
fi

netstat -tunlp 2>/dev/null | grep $port >/dev/null;

if [ $? -eq 0 ]
then
	files=(`cd ./${backup_name}; ls -f *.json | sort`)
	filesCount=${#files[*]};

	if [ $filesCount -gt 0 ]
	then
		printf '=%.0s' {1..50}
		printf "\nDatabase: %s\nBackup folder: %s\n" "$dbName" "$backup_name"
		printf '=%.0s' {1..50}
		printf "\n%s\n" "Restore started. Please, wait..."
		printf '=%.0s' {1..50}
		printf "\n%s"

		for file in "${files[@]}";
		do 
			collection=`echo ${file} | cut -d'.' -f1`;
			mongoimport --host=$host --port=$port --db $dbName  --collection $collection --file ./${backup_name}/${file}  > /dev/null
			printf "File: %s OK \n" "$file"  
		done

		printf '=%.0s' {1..50}
		printf "\n%s\n" "Restore finished successfully!"
		printf '=%.0s' {1..50}
		printf "\n%s"
	else
		printf '=%.0s' {1..50}
		printf "\n%s\n" "Sorry this backup is empty! Check your backup name!"
		printf '=%.0s' {1..50}
		printf "\n%s"
	fi
else
	printf '=%.0s' {1..50}
	printf "\n%s %s\n" "MongoDB is not running on" "$host:$port!"
	printf '=%.0s' {1..50}
	printf "\n%s"
fi