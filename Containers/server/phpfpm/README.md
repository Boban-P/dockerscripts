# php-fpm 7.3 server

**Building image locally**
```
# From the root of repository
./Scripts/load server:phpfpm build_image
# From any other path
/path/to/Scripts/load server:phpfpm build_image
# for options
./Scripts/load server:phpfpm build_image --help
```

**Usage**
Mount filesystem to required path, usually DOCUMENT_ROOT of apache server.
```
docker run --rm --mount type=bind,source=/path/to/python/source,destination=/path/to/dest/dir \
    server:phpfpm
```
environment variables
```
# Default values
    FILE_UPLOAD=On
    URL_FOPEN=On
    MEMMORY_LIMIT=512M
    MAX_EXECUTION_TIME=240
    MAX_FILE_UPLOAD_SIZE=200M
    MAX_POST_SIZE=400M
    MAX_INPUT_VARS=1500
    LISTEN_PORT=80
# Other 
    MAIL_FORWARD_HOST
    MAIL_PASSWORD
    MAIL_USER
    FROM_MAIL_ADDRESS
    DNS_SERVER           # set this value in /etc/resolve.conf
```
php fpm configuration is modified according to the environment variales.

**Adding entry to hosts file**
```
docker exec -ti {container-name} host.sh add ${domain} ${ip}
```
