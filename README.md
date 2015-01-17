# swaddle

[swaddle] wraps up your newly built programs (with 'swaddling') as ready-to-go signed releases: packages, package repositories and even websites, using simple data files stored in source control _laid out as you would have them in a package_. It is designed to be the final step after build and test:-

* it creates a GitHub release
  * with all files attached
  * with lots of sensible default copy
  * with links to standalone websites and versioned, signed package repositories
* it creates a standalone website for your packages on GitHub, referenced in the release notes
* it pushes and tags, using a signature, a _versioned_ set of repositories to GitHub pages
  * so you can _always_ rollback
  * and never deletes older released files
  * with automatic installation scripts included in your release notes
* It creates debian repositories with
  * complete file contents for `apt-file`
  * translations
  * package pools
  * components
  * priorities
  * InRelease and Release.gpg for maximal compatibility
  * and can even import packages from other sources, so you need never use `reprepro` or anything else again
    * you could even use it just for that alone
  * oh, and we already mentioned they're versioned, too
* it tags, using a signature, your source and binaries
* it creates whatever packages you want, with the best possible settings
  * Deb
  * RPM
  * tarball
  * zip
  * 7z
  * etc
* It can use maximal compression (eg lrzip or xz), best-practice gzip (eg with pigz to turn it up to 11) or even none at all
* Works with gpg-agent for silent signing
  * Except for rpm signing, which is so badly coded that it _can't_ use gpg-agent
* Automtically uploads your GPG key after releasing, so everyone can check it's your release

All this seems complex. It isn't. Take a look at the [swaddling](https://github.com/raphaelcohn/swaddle/tree/master/swaddling) for [swaddle] itself. Not much to see, is there?

## Differences with everything else

In many ways, we see this as the logically conclusion of [fpm]. It is to [fpm] what [fpm] was to RPM. Now, if only yum would die…

* it completely separates build from packaging (unlike, say, `dh-*`)
* source control is king: package files are just stored in source control wherever possible
* it is data-driven rather than script-driven
* all configuration data is just shell-like text files
* and, unlike everything else, it doesn't need C, Python, Perl or Ruby. It's pure shell script, built using [shellfire]\*

\* Yep, that's right. No need to have the `dpkg-*` or `yum-utils` tools installed. It'll even run on the Mac with Homebrew. The only downside is you'll need `rpmbuild`, because, RPM, being ~~a brilliant format~~ is ~~unusable~~ unimplementable with anything else. At least you won't have to write any more spec files, though.


## How to use it

For example, image you have the [shellfire] application 'overdrive'. You have a git repository 'overdrive' (perhaps at GitHub), containing the following structure:-

```bash
overdrive\
	.git\
	README.md
	COPYRIGHT
	overdrive           # your shellfire application script
	swaddling\
```

Inside swaddling, you'll create a configuration. For example, to create a tarball, debian package and RPM, with apt and yum repositories, we might do:-

```bash
    swaddling\
	    swaddling.conf       # Essential configuration
		swaddling.conf.d\    # Any files .conf are loaded after swaddling.conf, a la Debian run-parts.
		                     # This is true for any .conf file (eg package.conf, deb.conf, etc, below) in swaddle
							 # Use it to have localized bits of sensitive configuration external to source control
        overdrive\           # name of your 'swaddle'. Usually the same as your GitHub repo name.
                             # You can have many of these (eg for multiple packages, etc) but most people need just one.
	        package.conf     # Configuration settings for all package kinds (tarball, debian, etc) built for this swaddle
			skeleton\        # Put files that never change and aren't built in here
			    any\           # For any architecture
				    etc\
					    overdrive.conf
					          
				all\           # For packages without an architecture (Debian's 'all', RPM's 'noarch')
				amd64\         # For amd64 (and other architectures, as appropriate) - we use the Debian names (as these are highly consistent), and convert as necessary for RPM
			body\            # Identical structure to skeleton\, but intended for files that are build outputs (so you can `.gitignore` it; often symlinked to your build folder).
			    …
            deb\             # Create this, and you're making debian packages
			    deb.conf     # Debian specific settings, if any; entirely optional
			    skeleton\    # As above. Merged using rsync. Allows per-package-kind, per-architecture-variant file differences
			    body\        # As above. Merged using rsync.
			        …
            rpm\             # Create this, and you're making RPMs
			    rpm.conf     # RPM specific settings, if any; entirely optional
				skeleton\    # As above.
			    …
            tar\
			    tar.conf     # Same again
			    …
```

If an architecture folder exists, say `amd64`, then a `amd64` variant of a package is made. If it only exists, at, say, the level of `deb`, then it won't be made for a RPM or tarball. It is not allowed to have both `all` and another architecture (indeed, it makes no sense at all for Deb and RPM packages). So in the above example, we shouldn't have either `all` or `amd64`.

Surprisingly, there's actually very little to put in our `conf` files at this time. For example, the most complex is probably `swaddling.conf`. We might have:-

```bash
configure swaddle host_base_url 'https://raphaelcohn.github.io/swaddle/download'
configure swaddle maintainer_name 'Raphael Cohn'
configure swaddle maintainer_comment 'Package Signing Key'
configure swaddle maintainer_email 'raphael.cohn@stormmq.com'
configure swaddle vendor stormmq
```

Now it's possible we might not want those values to be used the same for every package. That's quite possible. A `conf` file _deeper_ in the hierarchy, overrides one above it for that part. For example, we could change the `vendor` above for Deb overdrive packages by putting this into `overdrive/deb.conf`:-

```bash
configure swaddle vendor 'someone else'
```

Of course, using this couldn't be easier:-

```bash
swaddle --swaddling-path /path/to/swaddling /path/to/output -- overdrive
```

And off we go!

## ~~Education, Education, Education~~ Configuration, Configuration, Congfiguration

The key to [swaddle] is configuration. In [swaddle], there are configuration _namespaces_. Each namespace is useful at a different level in the hierarchy above. Some are global; some are only useful, for, say, a deb. Configuration uses the file system layout, as well, to be useful. All are designed to be source control friendly. Indeed, [swaddle] works best when used with git and especially GitHub.

### Jargon Guide
We've tried to keep this as simple as possible.

|Name|Meaning|
|----|-------|
|swaddling|A folder containing 'swaddles'. Typically directly below your top-level directory|
|swaddle|All the stuff needed to make wrap up code into packages. The name of your swaddle will be used as the name of your packages and other outputs. A folder below swaddling|
|README.md|A file in your top-level directory, usually. Used to create man pages and READMEs in your packages if possible|
|COPYRIGHT|A file containing both copyright and licensing details in _Debian_ format. [See ours](https://raw.githubusercontent.com/raphaelcohn/swaddle/master/COPYRIGHT). Used to automatically feed license and copyright details into your packages|

### Configuration files

All `.conf` files are actually shell script running inside our process, so you can (although probably shouldn't) do simple code in them. If you really, really wanted to, you could even replace our logic. Not a great idea, and not one we'd support, but we wouldn't actively try to stop you, either. Handy, nonetheless. This is a dev tool, so don't run it on configuration you don't trust, ok?

For every file like `NAME.conf`, there is an optional folder `NAME.conf.d` which can contain snippets of code. They must end `.conf`. These are sourced after the master `NAME.conf`. This folder doesn't have to exist - nor does `NAME.conf`. One or the other or both is allowed. Exploit this to avoid storing sensitive configuration details in source contol without sacrificing it all together for environmentally immutable config. (At this point, an aside to my fellow developers: monolithic configuration is painful for our admins. It is not source control friendly, it is not devops friendly and its not friendly to friends, period. Don't do it).

To make a configuration setting in a package, the format is:-

```bash
configure NAMESPACE KEY VALUE
```

Some `KEY`s are arrays. These can be configured as:-

```bash
configure NAMESPACE KEY VALUE1
configure NAMESPACE KEY VALUE2
…
```

Most settings have a default; this may be static, or it may be chosen at runtime based on your system configuration, presence of README.md, etc. Any defaults are place before the first configuration file, `swaddling/swaddling.conf`, is loaded.

A quick run down of the various configuration files:-

|File|Purpose|Typical Namespaces|
|----|-------|------------------|
|`swaddling/swaddling.conf`|Settings for anything and everything|`swaddle`|
|`swaddling/swaddle/package.conf`|Settings for a particular swaddle|`swaddle`, `swaddle_package`|
|`swaddling/swaddle/deb/deb.conf`|Settings for deb packages|`swaddle_deb`|
|`swaddling/swaddle/rpm/rpm.conf`|Settings for rpm packages|`swaddle_rpm`|
|`swaddling/swaddle/tar/tar.conf`|Settings for tarballs|`swaddle_tar`|
|`swaddling/swaddle/zip/zip.conf`|Settings for zip archives|`swaddle_zip`|
|`swaddling/swaddle/7z/7z.conf`|Settings for 7z 'archives'|`swaddle_7z`|
|`swaddling/swaddle/file/file.conf`|Settings for standalone files|`swaddle_file`|

### Namespaces

#### swaddle

This namespace is intended to be used in `swaddling/swaddling.conf` and `swaddling/swaddle/package.conf`. That said, you can override a value on a per package-variant basis by putting a setting into, say, `swaddling/swaddle/deb/deb.conf`.

|Key|Default|Purpose|
|---|-------|-------|
|`maintainer_name`|*None*|Name of the package maintainer|
|`maintainer_comment`|*None*|Comment of the package maintainer; may be empty (`''`)|
|`maintainer_email`|*None*|Email of the package maintainer|
|`keyring`|*Maybe*|GPG Home. Defaults to `GNUPGHOME` environment variable, `"$HOME"/gnupg`\* or `~/.gnugpg` if the path is correctly permissioned and `gpg` present|
|`sign`|`yes` or `no`|Boolean value (in the [shellfire] sense). Defaults to `yes` if `gpg` is present and `keyring` has a default|
|`keyserver`|`hkps://hkps.pool.sks-keyservers.net` or, if running gpg < 1.4.10, `hkp://p80.pool.sks-keyservers.net:80` †|Automatically share your key with the world|
|`keyserver_options`|*Empty*|Comma-separated list of options to pass to GPG `--keyserver-options`|
|`timestamp`|detected via git or *0* otherwise|Timestamp to apply to released files. Important if you front your hosting with a CDN, say|
|`version`|detected via git or *0* otherwise|Version derived from last git check in, in the format `YYYY.MMDD.HHSS`‡|
|`epoch`|*0*|Package version epoch, not, as some £1,000/day devs I recently worked with think, *Unix* epoch. Zero almost always. ‡|
|`iteration`|`1`, unless there are pending changes, in which case, it's `2`|Used for package iterations. Not yet used for tag iterations.|
|`readme_file`|Location of `README.md`|Used to generate a manpage and a README. Should be markdown so we can turn it into a manpage.|
|`copyright_file`|Location of `COPYRIGHT` or *None* if not found|Used to discover licensing information and embed in Debian packages. Should be in Debian format.|
|`licence`|[SPDX licence identifier](https://spdx.org/licenses/) for packages; derived from `COPYRIGHT` if possible or *None*|Package licence. Automatically converted to Fedora-format licence code if possible, too.|
|`url`|*None* or derived from repository git data|Package url|
|`bugs_url`|*Empty*|Use this if bugs are reported at a different URL to `url`|
|`host_base_url`|*None*|Used for repository locations|
|`repository_name`|*None* or derived from repository git data|Name of this repository (eg top-level folder's name, typically, if a git clone was done)|
|`vendor`|*None*|The package vendor. Your company or project name, or GitHub user name|
|`fix_permissions`|*yes*|Boolean value (in the [shellfire] sense). Used to force all package files and folders to have root:root permissions and the `timestamp`. Unless you have a post-build step that adjusts file metadata in the `body` and `skeleton` folders (say using sudo or etckeeper or somesuch), leave this as `yes`.|

As well as [SPDX licence identifiers](https://spdx.org/licenses/), we also support the values `public-domain`, `unlicensed` and `licensed` for non-Open Source works.

We try very hard to sign quietly and correctly. That said, getting gpg set up correctly is a beast - you might like to review [Creating the perfect GPG keypair](https://alexcabal.com/creating-the-perfect-gpg-keypair/). We strongly encourage you to persist, for the benefit of us all. [swaddle] does not actively override any settings you put in `gpg.conf` (eg in `~/.gnupg/gpg.conf`). We strongly advise you to prefer SHA512 in it, eg:-

```bash
force-mdc
default-preference-list SHA512 SHA384 SHA256 CAMELLIA256 CAMELLIA128 AES256 AES BZIP2 Uncompressed
s2k-cipher-algo CAMELLIA256
s2k-digest-algo SHA512
personal-cipher-preferences CAMELLIA256 CAMELLIA192 CAMELLIA128 AES256 AES192 AES
personal-digest-preferences SHA512
personal-compress-preferences BZIP2
cert-digest-algo SHA512
```

It'll make you less compatible, but, in today's Post-Snowden world, what's the value in compatible if it isn't very secure? (Aside, a rant: GPG, PGP and gnupg are just far too complex, far too brittle and far too obsessed with compatibility with 1996 to be effective security tooling. What is it with the security folks, that they create standards (PEM, TLS, etc) with incredible numbers of permutations and software tooling to match. One tiny knob of many set wrongly, and the whole is exposed. Great).

\* `$HOME` is not necessarily the same as `~`; it just usually is. Indeed, one can unset `$HOME` and `~` will still work.

† For those that don't know, `hkp` is a simple (but not REST friendly) wrapper around `http`. On a different port. `hkps` is `https`. Oh, and WTF? CentOS 5 is still supported until 2017 but runs a vulnerable gpg? Great one. So what is a 'critical update', then? And gpg, you're not gotting off from this scot free. You only added secure transmission of keys in 2009! I strongly suspect the keyservers are running some pretty exploitable software, but I digress… (anyone fancy writing an open source NGINX plugin to do this robustly)?

‡ Compatible with schemes expecting semantic versioning but not semantically versioned. Personally, I don't have a lot of time for semantic versioning; one man's compatible change is another man's head in his hands. What matters is that version numbers differ and monotonically increase with simple rules for knowing they're different.


#### swaddle_package

This namespace is intended to be used in `swaddling/swaddle/package.conf`. That said, you can override a value on a per package-variant basis by putting a setting into, say, `swaddling/swaddle/deb/deb.conf`.

|Key|Default|Purpose|
|---|-------|-------|
|`description`|*None*|Package description. Line breaks are respected. First line is used as the summary for RPMs.|

#### swaddle_github

This namespace is intended to be used in `swaddling/swaddling.conf` and `swaddling/swaddle/package.conf`. Its settings allow the use of GitHub Releases. 

|Key|Default|Purpose|
|---|-------|-------|
|`owner`|*None* or derived from repository git data|GitHub owner. Used for GitHub Releases|
|`repository`|*None* or derived from repository git data|GitHub repository. Used for GitHub Releases|
|`api_token_file`|`~/.swaddle/github-personal-access-token` if present|Secure, out-of-tree storage\* of GitHub REST API access credentials|

If the file `~/.swaddle/github-personal-access-token` doesn't exist, then GitHub Releases are disabled. This contains a GitHub OAUTH personal access token created from your repository settings. It is one line (no final line feed), 40 bytes in size.

\* We decided not to let you specify the value directly, as even though you could put it in a conf snippet in, say `swaddling/swaddling.conf.d/00-api-token.conf`, and added that file to `.gitignore`, there's always the chance of slip up, isn't there? Been there and done that: in my case, after _not_ copying my hidden files properly once, and then checking in what should have been excluded with a naive git add in a hurry.

#### swaddle_7z

This namespace is intended to be used in `swaddling/swaddle/7z/7z.conf`. If the folder `swaddling/swaddle/7z` is present, you'll get 7z archives created.

|Key|Default|Purpose|
|---|-------|-------|
|`bomb`|*no*|Boolean value (in the [shellfire] sense). Used to create archive 'bombs', ie with no top-level folder to contain them, so, when extracted they defecate in the user's current working directory. Not very civilised, but occasionally required.|

#### swaddle_tar

This namespace is intended to be used in `swaddling/swaddle/tar/tar.conf`. If the folder `swaddling/swaddle/tar` is present, you'll get tarballs created.

|Key|Default|Purpose|
|---|-------|-------|
|`bomb`|*no*|Boolean value (in the [shellfire] sense). Used to create tar 'bombs', ie with no top-level folder to contain them, so, when extracted they defecate in the user's current working directory.|
|`compressions`|*gzip lrzip*|Array of compressions|

The available `compressions`, in rough order of compressive power, are:-

* `none` (`.tar`)
* `lzop` (`.tar.lzo`)
* `gzip` (turned up to 11 if possible)
* `zlib` (`.tar.zz`)
* `bzip2` (`.tar.bz2`)
* `lzma` (`.tar.lzma`)
* `xz` (`.tar.xz`)
* `lzip` (`.tar.lz`)
* `rzip` (`.tar.rz`)
* `lrzip` (`.tar.lrz`)

#### swaddle_file

This namespace is intended to be used in `swaddling/swaddle/file/file.conf`. If the folder `swaddling/swaddle/file` is present, you'll get standalone files created. Obviously, these aren't really a package format, but the idea is to make it easy to create non-binary things (eg lists of dictionary words), combined patches and standalone shell scripts, etc.

|Key|Default|Purpose|
|---|-------|-------|
|`path`|*Empty*|An absolute path, (as it it were inside a `skeleton` or `body`) to compress and release|
|`compressions`|*gzip lrzip*|Array of compressions|

If the path is empty, then the first matching path inside a `skeleton` or `body` is used.

The available `compressions`, in rough order of compressive power, are:-

* `none`
* `lzop` (`.lzo`)
* `gzip` (turned up to 11 if possible)
* `zlib` (`.zz`)
* `bzip2` (`.bz2`)
* `lzma` (`.lzma`)
* `xz` (`.xz`)
* `lzip` (`.lz`)
* `rzip` (`.rz`)
* `lrzip` (`.lrz`)

#### swaddle_zip

This namespace is intended to be used in `swaddling/swaddle/zip/zip.conf`. If the folder `swaddling/swaddle/zip` is present, you'll get ZIP archives created.

|Key|Default|Purpose|
|---|-------|-------|
|`bomb`|*no*|Boolean value (in the [shellfire] sense). Used to create archive 'bombs', ie with no top-level folder to contain them, so, when extracted they defecate in the user's current working directory. Required if creating Java JARs, etc|
|`extension`|*zip*|File extension of zip archive. Required if creating Java JARs (set to `jar`), etc|
|`use_bzip2`|*no*|Boolean value (in the [shellfire] sense). Create bzip2 compressed ZIPs. Despire being in the format since 2003, not widely supported.|


#### swaddle_deb

This namespace is intended to be used in `swaddling/swaddle/deb/deb.conf`. If the folder `swaddling/swaddle/deb` is present, you'll get debian packages created.

|Key|Default|Purpose|
|---|-------|-------|
|`supported`|`9m`|Ubuntu support period (values are usually `9m`, `18m`, `3y` or `5y`)\*|
|`section`|`misc`|Debian apt repository section, see [this list](https://github.com/raphaelcohn/swaddle/blob/master/lib/shellfire/swaddle/validate_deb_section.snippet)\*|
|`priority`|`extra`|Debian priority, see [this list](https://github.com/raphaelcohn/swaddle/blob/master/lib/shellfire/swaddle/validate_deb_priority.snippet)\*|
|`component`|`multiverse`|Debian priority, see [this list](https://github.com/raphaelcohn/swaddle/blob/master/lib/shellfire/swaddle/validate_deb_component.snippet)\*|
|`multiarch`|`no`|Package multiarch setting, see [this list](https://github.com/raphaelcohn/swaddle/blob/master/lib/shellfire/swaddle/validate_deb_multiarch.snippet)\*|
|`compression`|`xz`|Package's `data.tar` compression. One of `xz`, `lzma`, `bzip2`, `gzip` or none. `xz` does not work on Debian 6.|
|`essential`|`no`|Is package essential?\*|
|`build_essential`|`no`|Is package build essential?\*|
|`uploaders`|*Empty*|An *array* of uploaders as `User Name <user.name@company.com>`|
|`depends`|*Empty*|An *array* of package name dependencies (which may include comparison operators)†|
|`pre_depends`|*Empty*|An *array* of package name pre-dependencies (which may include comparison operators)†|
|`recommends`|*Empty*|An *array* of package name recommends†|
|`suggests`|*Empty*|An *array* of package name suggests†|
|`breaks`|*Empty*|An *array* of package name breaks (which may include comparison operators)†|
|`conflicts`|*Empty*|An *array* of package name conflicts (which may include comparison operators†)|
|`provides`|*Empty*|An *array* of virtual package name provides†|
|`replaces`|*Empty*|An *array* of package name replaces (which may include comparison operators)†|
|`enhances`|*Empty*|An *array* of package name enhances (rare)†|
|`built_using`|*Empty*|An *array* of package names (typically used when linking with static libraries†)|
|`extra_control_fields`|*Empty*|An *array* of extra control fields (such as `Original-Maintainer: xyz <xyz@mail.com>`)|
|`shlibs`|*Empty*|An *array*†|
|`config_files`|*Empty*|An *array* of absolute file paths (as if from `/`) to be treated as config files†|
|`triggers_interest`|*Empty*|An *array* of trigger names|
|`triggers_activate_noawait`|*Empty*|An *array* of trigger names|
|`triggers_activate`|*Empty*|An *array* of trigger names|
|`triggers_interest_noawait`|*Empty*|An *array* of trigger names|
|`tasks`|*Empty*|An *array* of task names, typically used by apt-get to install all packages with a particular task name when nothing else connects them. Used by the Ubuntu installer.|
|`tasks`|*Empty*|An *array* of tags used against packages|

\* These values are also used by the apt repository code to supply defaults for any packages that don't have them. This is possible, because the apt repo can include packages not built by [swaddle].
† Refer to [Debian Policy](https://www.debian.org/doc/debian-policy/ch-relationships)

##### Scripts
It is possible to create script for pre and post install actions, etc. To do this create a folder for the particular action, and put a script snippet into it. There is not needed to put a shebang line (we run all scripts as `#!/usr/bin/env sh`). This is about the only thing one can be sure exists at install time without creating unnecessary dependencies that are user-inconvenient (eg depending on perl just to run an install script). Avoid bashisms in your scripts. Unfortunately, at this time, these script snippets can't use [shellfire], but they could if there's demand for it.

It is possible to create script for pre and post install actions, etc. To do this create a folder for the particular action, and put a script snippet into it. There is not needed to put a shebang line (we run all scripts as `#!/usr/bin/env sh`). This is about the only thing one can be sure exists at install time without creating unnecessary dependencies that are user-inconvenient (eg depending on perl just to run an install script). Avoid bashisms in your scripts. Unfortunately, at this time, these script snippets can't use [shellfire], but they could if there's demand for it.

Each folder is searched in glob-expansion-order for readable, non-empty regular files (or symlinks) ending in `.sh`. These are then concatenated together. If your script has a requirement on a particular package or program being in place before execution, use a `pre_depends` (see above). The folders are:-

* preinst
* postinst
* prerm
* postrm


#### swaddle_rpm

This namespace is intended to be used in `swaddling/swaddle/rpm/rpm.conf`. Its settings allow the use of GitHub Releases. 

|Key|Default|Purpose|
|---|-------|-------|
|`changelog`|*None* or derived from repository git data|Changelog history for RPM|
|`depends`|*Empty*|An *array* of dependencies|
|`depends_before_install`|*Empty*|An *array* of dependencies needed before installation|
|`depends_after_install`|*Empty*|An *array* of dependencies needed after installation|
|`depends_before_remove`|*Empty*|An *array* of dependencies needed before removal|
|`depends_after_remove`|*Empty*|An *array* of dependencies needed after removal|
|`depends_pre_transaction`|*Empty*|An *array* of dependencies needed before a transaction|
|`depends_post_transaction`|*Empty*|An *array* of dependencies needed after a transaction|
|`depends_verify`|*Empty*|An *array* of dependencies needed for verification|
|`provides`|*Empty*|An *array* of dependencies provided to other packages|
|`conflicts`|*Empty*|An *array* of other packages (or dependencies they have) we conflict with|
|`replaces`|*Empty*|An *array* of other packages (or dependencies they have) we replace|
|`regex_filter_from_provides`|*Empty*|An *array*: refer to <https://fedoraproject.org/wiki/Packaging:AutoProvidesAndRequiresFiltering>|
|`regex_filter_from_requires`|*Empty*|An *array*: refer to <https://fedoraproject.org/wiki/Packaging:AutoProvidesAndRequiresFiltering> |
|`ghost_files`|*Empty*|An *array* of file paths (absolute, as if installed in `/`) to treat as *ghost* files|
|`doc_files`|*Empty*|An *array* of file paths (absolute, as if installed in `/`) to treat as *doc* files|
|`unreplaceable_config_files`|*Empty*|An *array* of file paths (absolute, as if installed in `/`) to treat as *%config(noreplace)* files|
|`replaceable_config_files`|*Empty*|An *array* of file paths (absolute, as if installed in `/`) to treat as *%config* files|
|`excluded_directories`|*Empty*|An *array* of folder paths (absolute, as if installed in `/`) that are not included in the RPM\*|
|`digest`|`sha512`|RPM digest type|
|`compression`|`xz`|RPM compression type. `xz` won't work on CentOS 5 - use `bzip2`|
|`category`|`Applications/System`|RPM category or group|
|`auto_req_prov`|*yes*|Boolean value (in the [shellfire] sense). Let rpmbuild determine requires and provides dependencies|
|`auto_req`|*yes*|Boolean value (in the [shellfire] sense). Let rpmbuild determine requires dependencies|
|`auto_prov`|*yes*|Boolean value (in the [shellfire] sense). Let rpmbuild determine provides dependencies|

'dependencies' can be:-

* package names
* files
* expressions (such as greater than X, etc)

`digest` is restricted to this list:-

* `sha512`
* `sha384`
* `sha256`
* `sha224`
* `sha1`
* `md5`

RPM supports other digest types, but they're obsolete. Frankly, it's bad enough that we have to allow `sha1` and `md5`.

`compression` is restricted to this list:-

* `xz`
* `lzma`
* `bzip2`
* `gzip`
* `none`

Interestingly, `pigz -11` on a typical small RPM can often shave off another 10K…

`category` is restricted to [this list](https://github.com/raphaelcohn/swaddle/blob/master/lib/shellfire/swaddle/validate_rpm_group.snippet)

\* By default, we also exclude everything in the list equivalent to `rpm -ql filesytem`, so it's unlikely you'll need to put anything in here.

##### Scripts
It is possible to create script for pre and post install actions, etc. To do this create a folder for the particular action, and put a script snippet into it. There is not needed to put a shebang line (we run all scripts as `#!/usr/bin/env sh`). This is about the only thing one can be sure exists at install time without creating unnecessary dependencies that are user-inconvenient (eg depending on perl just to run an install script). Avoid bashisms in your scripts. Unfortunately, at this time, these script snippets can't use [shellfire], but they could if there's demand for it.

Each folder is searched in glob-expansion-order for readable, non-empty regular files (or symlinks) ending in `.sh`. These are concatenated together and inserted as a scriptlet into a RPM Spec file. If a folder is missing, no RPM scriptlet is generated. If there are readable, non-empty regular files (or symlinks) ending `.depends`, then these are processed in glob-expansion-order, and each line of each file becomes a scriptlet dependency of the form `Requires(XXXX)`, where `XXXX` is either a package name (`info`) or package name predicated by version (`info > 3.1`). If a line is empty or starts with '#', it is ignored.

The folders are:-

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

Please note that the `trigger-*` folders are experimental and may change.

#### swaddle_apt

This namespace is intended to be used in `swaddling/swaddling.conf`. Its settings control apt repository creation.

|Key|Default|Purpose|
|---|-------|-------|
|`compressions`|`none` `gzip` `bzip2` `lzma` `xz`|An *array* of compressions to apply to repository files (Index, Release, Translation, etc)|
|`architectures`|`amd64` `i386`|An *array* of Debian architectures to create sub-repositories for. Needed even if you only have `all` packages. Valid [list](https://github.com/raphaelcohn/swaddle/blob/master/lib/shellfire/swaddle/validate_apt_architecture.snippet)|
|`language`|`en`|ISO language code (or subcode, eg `en_GB`) that packages descriptions are *assumed* to be in|
|`translations`|`language`|ISO languages codes for package translations|

##### Package Description Translations
If you want to prepare package description translations, then you can add them as `PACKAGE.translation-CODE` files (at `outputPath/download/apt/COMPONENT/i18n`). This is a semi-documented feature that might change, particularly as it not is not yet source control friendly.

When preparing apt translation files, Debian 6 and Ubuntu 10.04 (but not later versions of these distributions) require _both_ the language code _and_ sub-language code translations to exist. [swaddle] prepares these automatically for `en` (creating `en_AU`, `en_CA`, `en_GB`, `en_US` and `en_ZA`), `fr` (creating `fr_FR`), `no` (creating `no_NB`), pt (creating `pt_BR`) and `zh` (creating `zh_CN`, `zh_HK` and `zh_TW`). The implemented technique unfortunately overwrites any translation files you have prepared for these subcodes.

#### swaddle_yum

This namespace is intended to be used in `swaddling/swaddling.conf`. Its settings control yum repository creation.

|Key|Default|Purpose|
|---|-------|-------|
|`mirrors`|*Empty*|An *array* of URLs (ending in `/`) which will also host your yum repository. The swaddle `url` is used regardless.|

#### swaddle_webs

This namespace is intended to be used in `swaddling/swaddling.conf`. Its settings control website creation.

|Key|Default|Purpose|
|---|-------|-------|
|`digests`|`sha1` `sha256`|An *array* of file digests to be calculated for hosted content and embedded in `index.html` files.|
|`pandoc_options`|Defaults suitable for creating HTML|Options to pass to pandoc to turn pandoc+github-flavoured markdown into whatever you want|
|`index_name`|`index.html`|Name for index files|
|`use_index_name_in_directory_links`|*yes*|Boolean value (in the [shellfire] sense). Do generated URLs include `index_name` in them?|

`digests` may be any of:-

* `md5`
* `sha1`
* `sha256`
* `sha384`
* `sha512`

[fpm]: https://github.com/jordansissel/fpm "FPM GitHub page"
[swaddle]: https://github.com/raphaelcohn/swaddle "Swaddle homepage"
[shellfire]: https://github.com/shellfire-dev "shellfire homepage"
[fatten]: https://github.com/shellfire-dev/fatten "fatten homepage"
