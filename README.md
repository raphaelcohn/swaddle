swaddle
=======

swaddle creates RPM, Deb and tarball packages using shell script

## Configuration

### Namespace `swaddle`

|Key|Kind|Validation|Default|Explanation|
|---|----|----------|-------|-----------|
|`architecture`|Value|Architecture|`all`|Use `all` or `noarch` for no architecture (converted as appropriate). Use `x86_64` or `amd64` for 64-bit AMD. Use others as appropriate. We do not currently allow use of multiple architectures|
|`vendor`|Value|NotEmpty|*none*|Usually either a company or an individual (eg an email address). Freeform.|


	configure_register Value Architecture swaddle architecture  'all'
	configure_register Value NotEmpty swaddle epoch '0'
	configure_register Value NotEmpty swaddle version '0'
	# iteration is bumped by one for RPMs
	configure_register Value NotEmpty swaddle iteration '1'
	
	configure_register Value NotEmpty swaddle vendor
	configure_register Value Licence swaddle licence
	configure_register Value NotEmpty swaddle maintainer
	configure_register Value NotEmpty swaddle description
	configure_register Value NotEmpty swaddle url
	
	configure_register Value NotEmpty swaddle timestamp 0
	
	# Passed body / skeleton / rpm.body / rpm.skeleton etc path
	# Could be git-cache-meta, etc
	# Is run under fakeroot
	# Can be on path, absolute or even a bash function (if sourced in configuration itself)
	# Can also be used to create a body or its contents
	# Can be used to fix up mtimes. Default implementation sets mtime to mtime setting, 0 / 1970-01-01 00:00.00
	configure_register Value NotEmpty swaddle fix_permissions 'swaddle_build_package_defaultFixPermissions'
	