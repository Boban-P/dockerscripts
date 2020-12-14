# php-fpm 7.3 server

**Building image locally**<br>
see: [Scripts/completion/install](Scripts/completion/)
```
# if installed the script
cloudscript server/phpfpm/debug build_image

```
This is a debug build of [phpfpm](../), xdebug connects to debug application on provided port
```
docker run --rm --name=debugphp \
    --mount type=bind,source=/path/to/php/source,destination=/path/to/dest/dir \
    bb526/phpfpm:debug
# To debug.
docker exec debugphp debughost debuggerIp [debuggerPort]
```
debughost command will restart the phpfpm process with modified xdebug remote_host and remote_port(if provided)<br>
Whenever a connection to server is made, it will then connects to debugger application.
- debuggerIp is the ip address of debugger application or container.
- debuggerPort is the port debugger application listen on.
