# dockerscripts
containers for personal use <br />
debian Builds of docker containers  for server and editor applications.

**There are 3 directories**
- **Scripts**: main scripts
- **Containers**: contains docker container build scripts
- **Packages**: contain helper scripts and configuration for containers to use.

**Usage**<br>
`Script/load {group}:{item} {command}`
- {group}:{item} resolve to directory group/item in either **Containers** or **Packages**
- {command} is one of executable scripts in **Scripts/functions** or **{group}:{item}/bin**
