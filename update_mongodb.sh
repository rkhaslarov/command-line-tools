#!/bin/bash

# Description:
# 	This shell script is used for watching and executing mongo shell scripts to update mongodb database.
# 	You must copy your scripts into tmp folder, then daemon sort and execute them and move into _old folder.
# 	Script's extension must be .js and it's name should not contain any spaces.
# 	Example of script,
# 		db.foo.insert({name : "bar", position : "baz"}); 
# Usage:
# 	./update_mongodb.sh -d DB_NAME -h HOST -p PORT (as daemon, nohup $(./update_db.sh -d core >> /var/log/update_db.log) &)
# Default values: 
# 	DB_NAME - test;
# 	HOST - localhost;
# 	PORT - 27017;

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

if [ ! -d ./tmp ]; then
   mkdir tmp;
fi

if [ ! -d ./tmp/_old ]; then
   mkdir ./tmp/_old;
fi

today=`date +"%H:%M:%S %d-%m-%y"`

printf '=%.0s' {1..50}
printf "\n%s\n%s\n%s\n" "[${today}]" "MongoDB update daemon is started!" "MongoDB ($dbName) on $host:$port!"
printf '=%.0s' {1..50}
printf "\n%s"

while true 
do
	current_date=`date +"%H:%M:%S %d-%m-%y"`
	netstat -tunlp 2>/dev/null | grep $port >/dev/null;

	if [ $? -eq 0 ]
	then
		files=(`cd ./tmp; ls -f *.js 2>/dev/null | sort`)
		filesCount=${#files[*]};

		if [ $filesCount -gt 0 ]
		then
			for file in "${files[@]}";
			do 
				result=`mongo $host:$port/$dbName ./tmp/${file} --quiet --eval 'print(true)'`
				if [ "$result" == "true" ]
				then
					mv ./tmp/${file} ./tmp/_old/${file}
					printf "[${current_date}] File: %s OK \n" "$file"  
				fi
			done
		fi
	else
		printf "%s %s\n" "[${current_date}] MongoDB is not running on" "$host:$port!"
	fi
	sleep 5
done  