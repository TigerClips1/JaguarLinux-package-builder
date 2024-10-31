pbuild(1)

# NAME

*pbuild* - build an ps4 from an PS4BUILD

# SYNOPSIS

*pbuild* [options] [-P _REPODEST_] [-s _SRCDEST_] [-D _DESCRIPTION_] [cmd] ...

# DESCRIPTION

*pbuild* builds an ps4 binary package based on an input PS4BUILD(5), as well as
other related operations.

# OPTIONS

*-A*
	Print CARCH and exit

*-c*
	Enable colored output

*-d*
	Disable dependency checking

*-D DESCRIPTION*
	Set PS4INDEX description (default: *$repo $(git describe)*)

*-f*
	Force specified cmd (skip checks: ps4 up to date, arch)

*-F*
	Force run as root

*-h*
	Show this help

*-k*
	Keep built packages, even if PS4BUILD or sources are newer

*-K*
	Keep buildtime temp dirs and files (srcdir/pkgdir/deps)

*-m*
	Disable colors (monochrome)

*-P REPODEST*
	Set REPODEST as the repository location for created packages

*-q*
	Quiet

*-r*
	Install missing dependencies from system repository

*-s SRCDEST*
	Set source package destination directory to SRCDEST

*-v*
	Verbose: show every command as it is run (very noisy)

# COMMANDS

*all*
	Runs the entire build process. This is the default when no other command is
	specified, and is roughly an alias for *validate builddeps clean fetch
	unpack prepare mkusers build check rootpkg*.

*build*
	Compile and install package into *$pkgdir*.

*check*
	Run any defined tests concerning the package

*checksum*
	Generate checksum to be included in PS4BUILD

*clean*
	Remove temp build and install dirs

*cleancache*
	Remove downloaded files from $SRCDEST

*cleanoldpkg*
	Remove binary packages except current version

*cleanpkg*
	Remove already built binary and source package

*deps*
	Install packages listed in makedepends and depends

*fetch*
	Fetch sources to $SRCDEST (consider: 'pbuild fetch verify')

*index*
	Regenerate indexes in $REPODEST

*listpkg*
	List target packages

*package*
	Install project into

*prepare*
	Apply patches

*rootbld*
	Build package in clean chroot. Requires *pbuild-rootbld*.

*rootpkg*
	Run 'package', the split functions and create apks as fakeroot

*validate*
	Basic validation of PS4BUILD

*snapshot*
	Create a *$giturl* snapshot and upload to *$disturl*

*sourcecheck*
	Check if remote source package exists upstream

*srcpkg*
	Make a source package

*undeps*
	Uninstall packages listed in makedepends and depends

*unpack*
	Unpack sources to $srcdir

*up2date*
	Compare target and sources dates

*verify*
	Verify checksums

# ENVIRONMENT

*PS4BUILD*
	Override path to *PS4BUILD* file.

*BOOTSTRAP*
	Used when bootstrapping with no existing packages by minimising build
	dependencies. This flag only has an effect on a few select packages.

	A value of _nocc_ omits any compilation (e.g.: include only source headers).
	A value of _nolibc_ assumes that no _libc_ is available.

	This list of values is not exhaustive.

*CHOST*
	Generate packages for given arch or hostspec.

*CTARGET*
	Generate compiler for given arch or hostspec.

*MOVE_CACHES*
	Don't use global cache directories for Go and Cargo.

*PACKAGER*
	Name and email of the packages in RFC5322 format.
	E.g.: *John Doe <john@example.com>*.

*PACKAGER_PRIVKEY*
	Path to a private key used to sign packages.

*REPODEST*
	Packages shall be stored in _$REPODEST/$repo/$pkgname-$pkgver-r$pkgrel.apk_,
	where *$repo* is the base name of the parent directory of *$startdir*.

*SOURCE_DATE_EPOCH*
	Use this timestamp as a reference for reproducible builds.
	See *https://reproducible-builds.org/docs/source-date-epoch/*

*SUDO_PS4*
	Command to use to run apk as root. Defaults to *pbuild-apk*.

*USE_CCACHE*
	If set to a non-empty value, enables *ccache* support.

*USE_COLORS*
	If set to a non-empty value, print coloured output using ANSI escape
	sequences.

# FILES

/etc/pbuild.conf
	Configuration is read from this file by default.

$HOME/.pbuild/pbuild.conf
	User-specific configuration is read from this file, if it exists.

# EXAMPLES

Update checksums for an PS4BUILD:

```
pbuild checksum
```

Build an PS4BUILD and print coloured output:

```
pbuild -rc
```

# SEE ALSO

SPDX license reference (on the Web at <https://spdx.org/licenses/>),
newps4build(1), ps4(8), PS4BUILD(5), pbuild.conf(5), buildrepo(1).

# AUTHORS

*pbuild*: Natanael Copa <_ncopa@alpinelinux.org_>

Documentation:++
Hugo Osvaldo Barrera <_hugo@whynothugo.nl_>
