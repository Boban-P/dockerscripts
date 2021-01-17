FROM debian:stable

MAINTAINER Boban Pulinchery <boban@ecodiver.in>

ARG SERVER_VERSION=10.3

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
                   mariadb-server-${SERVER_VERSION} \
                   procps \
    && rm -rf /var/lib/apt/lists/* \
    && sed -i 's/^\(bind-address[ ]*\).*/\1= 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf 



# when extending update these values.
# see startup.sh

    # LISTEN_PORT=3306 \
    # DATA_DIR                  Database directory where the data is stored.
    # REPLICATION_SERVER_ID     0 disables replication, 1 is server anything else is a slave.
    # REPLICATION_BIN_LOG_FILE  replication binary log file required if replication enabled.
    # REPLICATION_DB_xxx        xxx is the db name, 0 to disable replication, 1 to enable replication.
    # REPLICATION_USER          username used by slaves to connect to replication master.
    # REPLICATION_PASSWORD      password used by slaves to connect to replication master.
    # BACKUP_SQL_DIR            the backup directory where replication server stores sql and state files.
    # RELAY_LOG_FILE            required for replication slaves,
    # MASTER_SERVER             required for replication slaves, the ip and port of replication master.

ENV LISTEN_PORT=3306 \
    DATA_DIR=/var/lib/mysql \
    REPLICATION_SERVER_ID=0 \
    REPLICATION_BIN_LOG_FILE=/var/log/mysql/mysql-bin.log \
#    REPLICATION_DB_xxx=1 \
    REPLICATION_USER=slave_user \
    REPLICATION_PASSWORD=slave_password \
    BACKUP_SQL_DIR=/home/sql \
    RELAY_LOG_FILE=/var/log/mysql/mysql-relay-bin.log \
    MASTER_SERVER=127.0.0.1 \
    MASTER_PORT=3306

COPY startup.sh createUser createdb execute /

ENTRYPOINT ["/startup.sh"]

CMD ["mysqld"]
