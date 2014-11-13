This path should contain the following folders, each of which relates to a RPM scriptlet:-

|Folder|RPM Scriptlet|Value of $1| Value of $2|
|------|-------------|-----------|------------|
|before-install|pre|1 is install, 2 or more is upgrade|N/A|
|after-install|post|1 is install, 2 or more is upgrade|N/A|
|before-remove|preun|1 or more is upgrade, 0 is erase|N/A|
|after-remove|postun|1 or more is upgrade, 0 is erase|N/A|
|verify|verifyscript|0| N/A|
|pre-transaction|pretrans|N/A| N/A|
|post-transaction|posttrans|N/A| N/A|
|trigger-on|triggerin|Trigger Packages|Number of Instances when complete|0 / 1 (if 0, exit 0)|
|trigger-off|triggerun|Trigger Packages|Number of Instances when complete|0 / 1 (if 0, exit 0)|
|trigger-fixerrors|triggerpostun|Trigger Packages|Number of Instances when complete|0 / 1 (if 0, exit 0)|

Each folder is searched in glob-expansion-order for readable, non-empty regular files (or symlinks) ending in `.sh`. These are concatenated together and inserted as a scriptlet into a RPM Spec file. If a folder is missing, no RPM scriptlet is generated. If there are readable, non-empty regular files (or symlinks) ending `.depends`, then these are processed in glob-expansion-order, and each line of each file becomes a scriptlet dependency of the form `Requires(XXXX)`, where `XXXX` is either a package name (`info`) or package name predicated by version (`info > 3.1`). If a line is empty or starts with '#', it is ignored.

We only allow 'sh' for scriptlets, as this is about the only thing one can be sure exists at install time without creating unnecessary dependencies that are user-inconvenient (eg depending on perl just to run an install script). Avoid bashisms.

http://rpm.org/api/4.4.2.2/triggers.html