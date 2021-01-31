# MARIADB database server

**Building image locally**
```sh
# if installed the script || see: Scripts/completion/install
cloudscript server/mariadb build_image

# From the root of repository
./Scripts/load Packages/server/mariadb build_image

# From any other path
/path/to/Scripts/load /path/to/Packages/server/mariadb build_image
```

## Standalone database server (default)

To run standalone server:
```sh
docker run bb526/mariadb:10.3

# to have database stored to local harddisk
# to run server.
docker run -d --rm \
    --mount type=bind,source=/path/to/mysql/db/directory,destination=/var/lib/mysql \
    bb526/mariadb:10.3
```

## Replication server setup

**Replication master**
- **Required environment variables**
    - REPLICATION_SERVER_ID=1
    - REPLICATION_USER      username of slave agent
    - REPLICATION_PASSWORD  password of slave agent
Replication server when created, will generate a database dump, and status file and write it to /home/sql<br>
The directory can be modified by setting environment variable `BACKUP_SQL_DIR`.
This data is required to start a slave machine.
To capture the data, a local directory can be mounted to `BACKUP_SQL_DIR`
```sh
docker run --rm \
    -e REPLICATION_SERVER_ID=1 \
    -e REPLICATION_USER={username} \
    -e REPLICATION_PASSWORD={password} \
    --mount type=bind,source=/path/to/master/backupdir,destination=/home/sql \
    -p 3306:3306 \
    bb526/mariadb:10.3
```

**Replication slave**
- **Required environment varialbe**
    - REPLICATION_SERVER_ID this values should be greater than 1 for a slave.
    - REPLICATION_USER      username of slave agent, must be same as used in master server.
    - REPLICATION_PASSWORD  password of slave agent, must be same as used in master server.
    - MASTER_SERVER         ip address or hostname of master server
-  **Notes on slave**
    - While restarting slave tmporary files is required, which by default stored in /tmp, this can be modified
    - SLAVE_TMP_DIR env variable set temporary files path.
    - mount local directory to SLAVE_TMP_DIR so that slave can be terminated and started safely.
```sh
docker run -d --rm \
    -e REPLICATION_SERVER_ID=2 \
    -e REPLICATION_USER={username} \
    -e REPLICATION_PASSWORD={password} \
    -e MASTER_SERVER={master server ip address} \
    --mount type=bind,source=/path/to/master/backupdir,destination=/home/sql \
    bb526/mariadb:10.3
```
With local directory as database directory
```sh
docker run -d --rm \
    -e REPLICATION_SERVER_ID=2 \
    -e REPLICATION_USER={username} \
    -e REPLICATION_PASSWORD={password} \
    -e MASTER_SERVER={master server ip address} \
    --mount type=bind,source=/path/to/master/backupdir,destination=/home/sql \
    --mount type=bind,source=/path/to/mysql/db/directory,destination=/var/lib/mysql \
    -e SLAVE_TMP_DIR=/tmp \
    --mount type=bind,source=/path/to/tmp/dir,destination=/tmp \
    bb526/mariadb:10.3
```

##### Securing mariadb server.
SSL can be enabled by mounting ca.pem, cert.pem and key.pem files to /certificates
```sh
# Either mount files to /certificates directory.
--mount type=bind,soruce=/host/path/to/ca.pem,destination=/certificates/ca.pem \
--mount type=bind,soruce=/host/path/to/cert.pem,destination=/certificates/cert.pem \
--mount type=bind,soruce=/host/path/to/key.pem,destination=/certificates/key.pem
# or export env variables to certificate files path.
--mount type=bind,source=/host/path/to/certificates/dir/,destination=/etc/mysql/certificates/ \
-e SSL_CA_FILE=/etc/mysql/certificates/ca_file_name.pem \
-e SSL_CERT_FILE=/etc/mysql/certificates/certificate_file_name.pem \
-e SSL_KEY_FILE=/etc/mysql/certificates/key_file_name.pem
```
[Referenc](https://dba.stackexchange.com/a/201771) use `openssl rsa -in server.key -out key_file_name.pem` to convert easyrsa generated keyfile.
