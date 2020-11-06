#!/bin/bash

SERVER_CONF_FILE=/etc/mysql/mariadb.conf.d/50-server.cnf
echo "port = ${SERVER_PORT}" >>/etc/mysql/mariadb.conf.d/50-mysqld_safe.cnf

mkdir -p ${BACKUP_SQL_DIR}

#handle replication.
#replication enabled.
if [[ (! -z "${REPLICATION_SERVER_ID}") && (${REPLICATION_SERVER_ID} != "0") ]]; then
    databases=()
    for line in $(env | grep -e '^REPLICATION_DB_'); do
        data=${line#REPLICATION_DB_}
        db_name=${data%=*}
        if [[ "${data#*=}" == "0" ]]; then
            sed -i 's/#\(binlog_ignore_db *=\)\(.*\)/\1 '${db_name}'\n#\1\2/' ${SERVER_CONF_FILE}
        else
            sed -i 's/#\(binlog_do_db *=\)\(.*\)/\1 '${db_name}'\n#\1\2/' ${SERVER_CONF_FILE}
        fi
        databases+=($db_name)
    done
    # set replication server id;
    sed -i 's/#*\(server-id *=\).*$/\1 '${REPLICATION_SERVER_ID}'/' ${SERVER_CONF_FILE}
    sed -i 's%#*\(log_bin *=\).*$%\1 "'"${REPLICATION_BIN_LOG_FILE}"'"%' ${SERVER_CONF_FILE}
    
    if [[ "${REPLICATION_SERVER_ID}" == "1" ]]; then
        # Master

        /etc/init.d/mysql start

        startup=$(echo "SELECT EXISTS(SELECT 1 FROM mysql.user WHERE user = '${REPLICATION_USER}')" | mysql | tail -1)
        # If replication user do not exits. this is assumed to be first run of replication server
        if [[ "${startup}" == 0 ]]; then
            # Create replication user and grant previlages
            echo "GRANT REPLICATION SLAVE ON *.* TO '${REPLICATION_USER}'@'%' IDENTIFIED BY '${REPLICATION_PASSWORD}'" | mysql;
            echo "FLUSH PRIVILEGES" | mysql
            # Prepare for database backup, add read lock to tables so that
            # the binary log file do not change
            for db in "${databases[@]}"; do
                echo "CREATE DATABASE IF NOT EXISTS ${db}" | mysql
            done

            function make_backup() {
                echo "FLUSH TABLES WITH READ LOCK;"
                mysqldump --master-data --databases "${databases[@]}" >${BACKUP_SQL_DIR}/master.sql
                # Store server status so clients can use them.
                echo "SHOW MASTER STATUS\G" | mysql >/dev/shm/master_status.txt
                lines=$(cat /dev/shm/master_status.txt | wc -l)
                (( lines-- ))
                tail -n $lines /dev/shm/master_status.txt | sed 's/^ *//' >${BACKUP_SQL_DIR}/master_status;
                rm /dev/shm/master_status.txt
            
                echo "UNLOCK TABLES;"
            }
            make_backup | mysql
            
        fi

        /etc/init.d/mysql stop

        # mysql database replication server setup complete
        # to setup clients use the sqldump files from ${BACKUP_SQL_DIR}
    else
        # Slave
        sed -i 's@\(log_bin\)\( *=\)\(.*$\)@\1\2\3\nrelay-log\2 ${RELAY_LOG_FILE}@' ${SERVER_CONF_FILE}
        /etc/init.d/mysql start
        
        startup=$(echo "SHOW SLAVE STATUS" | mysql | wc -l)
        if [[ "${startup}" == 0 ]]; then
            mysql < ${BACKUP_SQL_DIR}/master.sql
            while read -r line; do
                name=${line%:*}
                value=${line#*: }
                case ${name} in
                    File)
                        binFile=${value}
                        ;;
                    Position)
                        logPosition=${value}
                        ;;
                esac
            done <${BACKUP_SQL_DIR}/master_status
            echo "CHANGE MASTER TO MASTER_HOST='${MASTER_SERVER}', MASTER_PORT='${MASTER_PORT}'" \
                 "MASTER_USER='${REPLICATION_USER}', MASTER_PASSWORD='${REPLICATION_PASSWORD}', " \
                 "MASTER_LOG_FILE='${binFile}', MASTER_LOG_POS=${logPosition}" \
                | mysql
            echo "START SLAVE" | mysql
        fi
        
        /etc/init.d/mysql stop
    fi
fi

exec "$@"
