#!/bin/sh
set -u
set -e

# Variable Declaration

DATE=`date +"%d%b%Y"`
TIME=`date +"%H-%M-%S"`
DB_BACKUP_PATH='/data/mysqlbackup/.'
MYSQL_HOST='localhost'
MYSQL_PORT=3306
REMOTE_SERVER='cloud-user@<ip>:/data/mysqlbackup175/.'
MYSQL_USER=<username>
MYSQL_PASSWORD=<password>
DATABASE_NAME='--all-databases'
BACKUP_RETAIN_DAYS=7   ## Number of days to keep local backup copy
PEMKEY='/home/cloud-user/.secret_keys/sql_backup.pem'
#################################################################

usage()
{
        echo "usage: $(basename $0) [option]"
        echo "option=full : Perform Full Backup"
        echo "option=incremental : Perform Incremental Backup"
        echo "option=help: show this help"
}

function fullBackup() {
  mkdir -p ${DB_BACKUP_PATH}/${DATE}/full
  echo "Backup started for database - ${DATABASE_NAME}"

  mysqldump -v -h ${MYSQL_HOST} -P ${MYSQL_PORT} -u ${MYSQL_USER} -p${MYSQL_PASSWORD} --flush-logs ${DATABASE_NAME}  > ${DB_BACKUP_PATH}/${DATE}/full/${DATE}.sql

  if [ $? -eq 0 ]; then
    echo "Database backup successfully completed"
  else
    echo "Error found during backup"
    exit 1
  fi

  ######################################################################

  DBDELDATE=$(date +"%d%b%Y" --date="${BACKUP_RETAIN_DAYS} days ago")

  if [ ! -z ${DB_BACKUP_PATH} ]; then
    cd ${DB_BACKUP_PATH}
    if [ ! -z ${DBDELDATE} ] && [ -d ${DBDELDATE} ]; then
      rm -rf ${DBDELDATE}
    fi
  fi
  REMOTE_DBDELDATE=$(ssh -i ${PEMKEY} cloud-user@10.144.185.176 "ls -d /data/mysqlbackup175/${DBDELDATE}.sql")
#  echo ${REMOTE_DBDELDATE}
#  if [ -d ${REMOTE_DB_BACKUP_PATH} ]; then
  if [ ! -z ${DBDELDATE} ] && [ ! -z ${REMOTE_DBDELDATE} ]; then
	  ssh -i ${PEMKEY} cloud-user@10.144.185.176 rm -rf ${REMOTE_DBDELDATE}
  fi
#  fi

  # Transfer backup to remote server using scp
  scp -i ${PEMKEY} -p ${DB_BACKUP_PATH}/${DATE}/full/${DATE}.sql ${REMOTE_SERVER}

  if [ $? -eq 0 ]; then
    echo "Backup transferred to remote server successfully"
  else
    echo "Error found during transfer"
    exit 1
  fi
}

function incrementalBackup()
{

logfile=$(ssh -i ${KEY}  jioapp@${MYSQL_HOST} "mysqladmin -u ${MYSQL_USER} -p${MYSQL_PASSWORD} flush-logs ; sudo ls -tr /data/mysql/mysql-bin.0* | tail -2 | head -n 1")
echo $logfile > /var/tmp/mysql_inc
mkdir -p ${DB_BACKUP_PATH}/${DATE}/inc${COUNT}
scp -i ${KEY} jioapp@${MYSQL_HOST}:$logfile ${DB_BACKUP_PATH}/${DATE}/inc${COUNT}

}

if [ $# -eq 0 ]
then
usage
exit 1
fi

    case $1 in
        "full")
            fullBackup
            ;;
        "incremental")
        incrementalBackup
            ;;
        "help")
            usage
            break
            ;;
        *) echo "invalid option";;
    esac
