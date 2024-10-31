pbuild.conf(5)

# NAME

*pbuild.conf* - configuration file for pbuild

# DESCRIPTION

*pbuild.conf* is the configuration for the *pbuild(1)* program.

# FORMAT

The configuration file is parsed as a shell script; variables are defined as
regular shell variables.

For a list of supported variables, see the ENVIRONMENT section of the
*pbuild(1)* manual page.

# EXAMPLE

```
PACKAGER_PRIVKEY="/home/jane/.abuild/jane@example.com-87ac18ca.rsa"
PACKAGER="Jane Doe <jane@example.com>"
USE_COLORS=1
```

# SEE ALSO

pbuild(1)
