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
  * oh, and we already mentioned their versioned, too
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



#### swaddle_rpm

This namespace is intended to be used in `swaddling/swaddle/rpm/rpm.conf`. Its settings allow the use of GitHub Releases. 

|Key|Default|Purpose|
|---|-------|-------|
|`changelog`|*None* or derived from repository git data|Changelog history for RPM|









eg swaddle_apt translations _swaddle_repository_apt_createDistsComponentsTranslations_callback "$(configure_getValue swaddle_apt language)"
	- ordering is important, eg en before en_GB, to overcome a bug in Debiam 6 / Ubuntu 10.04
	- This logic creates these extra files, but will fail if they are explicitly called out (ie do not specify en_GB in the list)





[fpm]: https://github.com/jordansissel/fpm "FPM GitHub page"
[swaddle]: https://github.com/raphaelcohn/swaddle "Swaddle homepage"
[shellfire]: https://github.com/shellfire-dev "shellfire homepage"
[fatten]: https://github.com/shellfire-dev/fatten "fatten homepage"
