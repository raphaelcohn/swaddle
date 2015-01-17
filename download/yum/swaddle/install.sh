#!/usr/bin/env sh
set -e
set -u

repoFilePath='/etc/yum.repos.d/swaddle.repo'
repoFileContent='[swaddle]
name=swaddle
#baseurl=https://raphaelcohn.github.io/swaddle/download/yum/swaddle
mirrorlist=https://raphaelcohn.github.io/swaddle/download/yum/swaddle/mirrorlist
gpgkey=https://raphaelcohn.github.io/swaddle/download/yum/swaddle/RPM-GPG-KEY-swaddle
gpgcheck=1
enabled=1
protect=0'

if [ -t 1 ]; then
	printf '%s\n' "This script will install the yum repository 'swaddle'" "It will create or replace '$repoFilePath', update yum and display all packages in 'swaddle'." 'Press the [Enter] key to continue.'
	read -r garbage
fi

printf '%s' "$repoFileContent" | sudo -p "Password for %p is required to allow root to install '$repoFilePath': " tee "$repoFilePath" >/dev/null
sudo -p "Password for %p is required to allow root to update yum cache: " yum --quiet makecache
yum --quiet info swaddle 2>/dev/null
