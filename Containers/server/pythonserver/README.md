# python daphne uvicorn or hypercorn application

**Building image locally**
```
# From the root of repository
./Scripts/load server:pythonserver build_image
# From any other path
/path/to/Scripts/load server:pthonserver build_image
# for options
./Scripts/load server:pthonserver build_image --help
```

**Usage**
Mount filesystem to any path in container and expose that directory with -w option
```
docker run --rm --mount type=bind,source=/path/to/python/source,destination=/path/to/working/dir \
    -w /path/to/working/dir
    server:pythonserver
```
if there is a requirements.txt file in working dir, `pip install -r requirements.txt` will be executed.
to avoid downloading depency each time the container started,
mount a directory to /root or /root/.cache (.cache should be owned by root)
```
sudo mkdir /path/to/cache/dir
sudo chown root:root /path/to/cache/dir
docker run --rm --mount type=bind,source=/path/to/python/source,destination=/path/to/working/dir \
    -w /path/to/working/dir \
    --mount type=bind,source=/path/to/cache/dir,destination=/root/.cache \
    server:pythonserver
```

By default daphne server is run on port 80
