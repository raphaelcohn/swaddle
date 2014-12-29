swaddle
=======

swaddle creates RPM, Deb and tarball packages using shell script

## Todo
* Add DMG support, eg <https://stackoverflow.com/questions/286419/how-to-build-a-dmg-mac-os-x-file-on-a-non-mac-platform>
* Add ISO support (especially hybrid / bootable)
* Add CPIO support

## Configuration

### Namespace `swaddle`

|Key|Kind|Validation|Default|Explanation|
|---|----|----------|-------|-----------|






all arch vs amd64, etc
Also any 'arch' - used with all defined architectures
refer to swaddle_build_package_synchroniseToPackageRoot
permissionsForFolderStructureFilePath="$folderStructurePath".permissions
- we set mtime and atime
- we set all folders and files to be root:root
	- unless fix_permissions is disabled  configure_getValue swaddle fix_permissions
- could work with .etckeeper with minor changes (eg support for .etckeeper files, implement the maybe function)
- could work with metastore (although this uses a binary format, keeps users / groups as names)
- could just be a list of mkdir / chmod / chgrp / mkfifo, etc

gpg vs gpg2 (only latter has cache, passphrase, etc)
Need to create ~/.gnupg
gpg --gen-key
gpg-preset-passphrase