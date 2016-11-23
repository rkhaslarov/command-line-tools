#!/bin/bash
# Команда для локального использования: ./update_db.sh -d DB_NAME -h HOST -p PORT
# Команда для использования на сервере: $(./update_db.sh -d core >> /var/log/update_db.log) &

# Демон по обновлению БД. 

# Использование: 
# В папке со скриптом есть папка /tmp, в ней разработчик создает/вставляет скрипт с расширением .js для MongoDB.
# Название скрипта должно иметь следующий формат yyyymmdd-nn-name.js (20161123-02-addrecords.js) 
# и не должно содержать символов пробела.

# Внутри должен содержаться код Mongo Shell. Например,
# 	db.foo.insert({name : "wade", position : "guard"});
# 	db.foo.insert({name : "wade2", position : "guard2"}); 

# Учтите, скрипты запускаются демоном в сортированном порядке (сначало 20161123-01-createfoocollection.js, 
# затем 20161123-02-addrecords.js и т.д.).

# Резервное копирование: после обработки и запуска скрипта, он перемещается в папку _old.
# Логирование: все операции пишутся в update_db.log.

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