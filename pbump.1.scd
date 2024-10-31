pbump(1)

# NAME

*pbump* - bump pkgver in an PS4BUILD file

# SYNOPSIS

*pbump* [-s _CVE-1_,...] [-f _ISSUE_] [-k|--keep] _PKGNAME-1.2.3_

# DESCRIPTION

*pbump* updates the *pkgver* in an PS4BUILD file, updates its checksums,
rebuilds it, and finally creates a new commit commit with the changes resulting.

*pbump* operates looks for the specified package in nested directories inside
the current working, assuming a layout like that of the aports repository.

# OPTIONS

*-s, --security CVE1,...*
	Include CVE in the *secfixes* comment section.

*-f, --fixes ISSUE*
	Include *Fixes #ISSUE* in the commit message. This will close the upstream
	issue when the commit is merged into the aports master branch.

*-k, --keep*
	Keep existing packages.

*-h, --help*
	Print help information and exit.

# ENVIRONMENT

PPORTSDIR
	Force operating on an alternate directory.

# EXAMPLES

```
pbump mml-1.0.0
pbump glibmm2.68-2.78.0
pbump telegram-desktop-4.11.8
```

# SEE ALSO

pbuild(1), ps4grel(1), newps4build(1), PS4BUILD(5), ps4(8).

# AUTHORS

Natanael Copa <_ncopa@alpinelinux.org_> and open source contributors.
