# Apache Http server

**Building image locally**
```
# From the root of repository
./Scripts/load server:apache build_image
# From any other path
/path/to/Scripts/load server:apache build_image
# for options
./Scripts/load server:apache build_image --help
```

**With letsencrypt**
```
docker run --rm -e SITE_NAME=example.com \
    -e SITE_ALIAS=www.example.com \
    -e SSL_ON=1 \
    -e ACME_PROVIDER=letsencrypt \
    server:apache 
```

**Node balancer**
```
docker run --name balancer --rm -e SITE_NAME=example.com \
    -e CONFIG_TYPE=balancer \
    server:apache
```
To add nodes
`docker exec balancer childBalancer.sh add {ip}:{port}`


**static file server infront of php-fpm.**
```
docker run --name staticserver --rm \
    -e CONFIG_TYEP=phpapp \
    --mount type=bind,source=/path/to/host/documentroot,destination=/home/www \
    -e DOCUMENT_ROOT=/home/www \
    server:apache
```
To route to php fpm server `docker exec staticserver appBalancer.sh add {php-fpm-server-ip}:{port}`

**static file server in front of django/python app**
```
docker run --name djangostatic --rm \
    -e CONFIG_TYPE=pythonapp \
    --mount type=bind,source=/path/to/static/file,destination=/home/static \
    --PATH_ALIASES /static=/home/static
    server:apache

docker exec -ti djangostatic appBalancer.sh add {django-server-ip}:{port}
```

**custom vhosts file.**
```
docker run --name apacheserver --rm \
    --mount type=bind,source=/path/to/vhosts,destination=/etc/apache2/sites-enabled/vhost.conf \
    server:apache

```