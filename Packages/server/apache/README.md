# Apache Http server

**Building image locally**
```
# if installed the script || see: Scripts/completion/install
cloudscript server/apache build_image

# From the root of repository
./Scripts/load Packages/server/apache build_image

# From any other path
/path/to/Scripts/load /path/to/Packages/server/apache build_image
```

#### Log to stdout/stderr
Use `-e LOG_TO_TERMINAL=true` for apache to write log to its stdout & stderr

#### With letsencrypt
```
# example.com needs to be reached from internet.
# this create a node balancer which route traffic to
# configured nodes
# on production use : -e ACME_PROVIDER=letsencrypt

docker run -d --name balancer \
    -e SITE_NAME=example.com \
    -e SITE_ALIAS=www.example.com \
    -e CONFIG_TYPE=balancer \
    -e SSL_ON=1 \
    -e ACME_PROVIDER=letsencrypt-staging \
    -p 80:80 -p 443:443 \
    bb526/apache:2.4
# to add node
docker exec balancer childBalancer.sh add {nodeip:port}
```

#### Node balancer
```
docker run -d --name balancer \
    -e SITE_NAME=example.com \
    -e CONFIG_TYPE=balancer \
    bb526/apache:2.4
```
To add nodes
`docker exec balancer childBalancer.sh add {ip}:{port}`


#### Node balancer with site spacific routing**
```
# by this configuration, sites will be issued single cerificate
# if ssl is enbaled with an acme provider.
docker run -d --name balancer \
    -e SITE_NAME=example.com \
    -e SITE_ALIAS="abc.com other.com www.example.com" \
    -e ALIAS_ROUTES="abc.com other.com" \
    -e CONFIG_TYPE=balancer \
    bb526/apache:2.4
```
To add nodes
`docker exec balancer siteBalancer.sh abc.com add {ip}:{port}`

#### static file server infront of php-fpm.**
```
docker run -d --name staticserver --rm \
    -e CONFIG_TYPE=phpapp \
    --mount type=bind,source=/path/to/host/documentroot,destination=/home/www \
    -e DOCUMENT_ROOT=/home/www \
    bb526/apache:2.4
```
To route to php fpm server `docker exec staticserver appBalancer.sh add {php-fpm-server-ip}:{port}`

#### static file server in front of django/python app**
```
docker run --name djangostatic --rm \
    -e CONFIG_TYPE=pythonapp \
    --mount type=bind,source=/path/to/static/file,destination=/home/static \
    -e PATH_ALIASES=/static=/home/static \
    bb526/apache:2.4

docker exec -ti djangostatic appBalancer.sh add {django-server-ip}:{port}
```

#### custom vhosts file.**
```
docker run --name apacheserver --rm \
    --mount type=bind,source=/path/to/vhosts,destination=/etc/apache2/sites-enabled/vhost.conf \
    bb526/apache:2.4

```
To enable a module add `-e ENABLE_MODE_{module}=1` to docker run arguments. eg:- `-e ENABLE_MODE_rewrite=1`

## TODO ##
- ~~site name/alias based routing in balancer mode.~~
- priority for balancer nodes.
