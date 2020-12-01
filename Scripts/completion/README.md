# Installing script
To install globally run
```
sudo install.sh
```

# Installing for your own use #
**Creating bash completion script**
```
sed 's/%%cloudscript%%/cloudscript/g' cloudscript.sh >~/.local/cloudscript.completion
echo ". ~/.local/cloudscript.completion" >>~.barshrc
```
**creating link to Script/load in executable path**
```
# cd /some/directory/in/${PATH}
cd ~/bin
ln -s /Path/to/repo/Script/load cloudscript
```
**Adding default Packages path**
```
echo "include_dir=/path/to/repo/Packages" >~/.cloudscript
# optionally
echo "include_dir=/path/to/your/private/Packages" >>~/.cloudscritp
```
