# Command Line Tools (Linux)

# MongoDB Backup

Description:
	This shell script is used for full backuping of all collections in current database.
Usage:
	./backup_mongodb.sh -d DB_NAME -h HOST -p PORT (for example, ./backup_mongodb.sh -d core -h localhost -p 3001)
Default values: 
	DB_NAME - test;
	HOST - localhost;
	PORT - 27017.

# MongoDB Restore

Description:

	This shell script is used for restoring collections from backup to current database.

Usage:

	./restore_mongodb.sh -d DB_NAME -h HOST -p PORT -b BACKUP_FOLDER 

	(for example, ./restore_mongodb.sh -d core -h localhost -p 3001 -b 22-11-16-1479840325)

Default values: 

	DB_NAME - test;

	HOST - localhost;

	PORT - 27017;
	
	BACKUP_FOLDER - the latest backup.

# MongoDB Update (with scripts)

Description:
	This shell script is used for watching and executing mongo shell scripts to update mongodb database.
	You must copy your scripts into tmp folder, then daemon sort and execute them and move into _old folder.
	Script's extension must be .js and it's name should not contain any spaces.
	Example of script,
		db.foo.insert({name : "bar", position : "baz"}); 
Usage:
	./update_mongodb.sh -d DB_NAME -h HOST -p PORT (as daemon, nohup $(./update_db.sh -d core >> /var/log/update_db.log) &)
Default values: 
	DB_NAME - test;
	HOST - localhost;
	PORT - 27017;