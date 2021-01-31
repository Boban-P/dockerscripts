# php-fpm 7.3 server

**Building image locally**
```
# if installed the script || see: Scripts/completion/install
cloudscript server/phpfpm build_image

# From the root of repository
./Scripts/load Packages/server/phpfpm build_image

# From any other path
/path/to/Scripts/load /path/to/Packages/server/phpfpm build_image
```

**Usage**
Mount filesystem to required path, usually DOCUMENT_ROOT of apache server.
```
docker run --rm \
    --mount type=bind,source=/path/to/php/source,destination=/path/to/dest/dir \
    bb526/phpfpm:7.3
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
# eg: - docker exec {container-name} host.sh add dbhost {database-serverip}
```

##### Adding CA certificate
Mount ca certifacte to /ca/ directory. the ca will be added on container startup.
ca certificates can be created with [easyrsa container](../../utilities/easyrsa)
