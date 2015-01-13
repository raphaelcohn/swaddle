# swaddle

swaddle creates RPM, Deb and tarball packages using shell script


## Configuration

### Namespace `swaddle`

|Key|Kind|Validation|Default|Explanation|
|---|----|----------|-------|-----------|


eg swaddle_apt translations _swaddle_repository_apt_createDistsComponentsTranslations_callback "$(configure_getValue swaddle_apt language)"
	- ordering is important, eg en before en_GB, to overcome a bug in Debiam 6 / Ubuntu 10.04
	- This logic creates these extra files, but will fail if they are explicitly called out (ie do not specify en_GB in the list)




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


https://ask.fedoraproject.org/en/question/56107/can-gpg-agent-be-used-when-signing-rpm-packages/
