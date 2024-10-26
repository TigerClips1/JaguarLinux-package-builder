PACKAGE		:= ps4build
VERSION		:= 3.14.1

prefix		?= /usr
bindir		?= $(prefix)/bin
sysconfdir	?= /etc
sharedir		?= $(prefix)/share/$(PACKAGE)
mandir		?= $(prefix)/share/man

SCRIPTS		:= ps4build ps4build-keygen ps4build-sign newps4build \
		   abump ps4grel buildlab ps4build-cpan ps4build-pypi checkps4 \
		   ps4build-gem-resolver
USR_BIN_FILES	:= $(SCRIPTS) ps4build-tar ps4build-gzsplit ps4build-sudo ps4build-fetch ps4build-rmtemp
MAN_1_PAGES	:= newps4build.1 ps4build.1 abump.1
MAN_5_PAGES	:= PS4BUILD.5 ps4build.conf.5
SAMPLES		:= sample.PS4BUILD sample.initd sample.confd \
		sample.pre-install sample.post-install
MAN_PAGES	:= $(MAN_1_PAGES) $(MAN_5_PAGES)
AUTOTOOLS_TOOLCHAIN_FILES := config.sub config.guess

SCRIPT_SOURCES	:= $(addsuffix .in,$(SCRIPTS))

GIT_REV		:= $(shell test -d .git && git describe || echo exported)
ifneq ($(GIT_REV), exported)
FULL_VERSION    := $(patsubst $(PACKAGE)-%,%,$(GIT_REV))
FULL_VERSION    := $(patsubst v%,%,$(FULL_VERSION))
else
FULL_VERSION    := $(VERSION)
endif

CHMOD		:= chmod
SED		:= sed
TAR		:= tar
SCDOC		:= scdoc
LINK		= $(CC) $(OBJS-$@) -o $@ $(LDFLAGS) $(LDFLAGS-$@) $(LIBS-$@)

CFLAGS		?= -Wall -Werror -g -pedantic

SED_REPLACE	:= -e 's:@VERSION@:$(FULL_VERSION):g' \
			-e 's:@prefix@:$(prefix):g' \
			-e 's:@sysconfdir@:$(sysconfdir):g' \
			-e 's:@sharedir@:$(sharedir):g' \

SSL_CFLAGS	?= $(shell pkg-config --cflags openssl)
SSL_LDFLAGS	?= $(shell pkg-config --cflags openssl)
SSL_LIBS	?= $(shell pkg-config --libs openssl)
ZLIB_LIBS	?= $(shell pkg-config --libs zlib)

OBJS-ps4build-tar  = ps4build-tar.o
CFLAGS-ps4build-tar.o = $(SSL_CFLAGS)
LDFLAGS-ps4build-tar = $(SSL_LDFLAGS)
LIBS-ps4build-tar = $(SSL_LIBS)
LIBS-ps4build-tar.static = $(LIBS-ps4build-tar)

OBJS-ps4build-gzsplit = ps4build-gzsplit.o
LDFLAGS-ps4build-gzsplit = $(ZLIB_LIBS)

OBJS-ps4build-sudo = ps4build-sudo.o
OBJS-ps4build-fetch = ps4build-fetch.o

TEST_TIMEOUT = 30

.SUFFIXES:	.conf.in .sh.in .in
%.conf: %.conf.in
	${SED} ${SED_REPLACE} ${SED_EXTRA} $< > $@

%.sh: %.sh.in
	${SED} ${SED_REPLACE} ${SED_EXTRA} $< > $@
	${CHMOD} +x $@

%: %.in
	${SED} ${SED_REPLACE} ${SED_EXTRA} $< > $@
	${CHMOD} +x $@

%.1: %.1.scd
	${SCDOC} < $< > $@

%.5: %.5.scd
	${SCDOC} < $< > $@

P=$(PACKAGE)-$(VERSION)

all:	$(USR_BIN_FILES) $(MAN_PAGES) functions.sh ps4build.conf

clean:
	@rm -f $(USR_BIN_FILES) $(MAN_PAGES) *.o functions.sh ps4build.conf Kyuafile \
		tests/Kyuafile tests/testdata/ps4build.key*

%.o: %.c
	$(CC) $(CPPFLAGS) $(CFLAGS) $(CFLAGS-$@) -o $@ -c $<

ps4build-sudo: ps4build-sudo.o
	$(LINK)

ps4build-tar: ps4build-tar.o
	$(LINK)

ps4build-fetch: ps4build-fetch.o
	$(LINK)

ps4build-gzsplit: ps4build-gzsplit.o
	$(LINK)

ps4build-tar.static: ps4build-tar.o
	$(CC) -static $(CPPFLAGS) $(CFLAGS) $(CFLAGS-$@) $^ -o $@ $(LIBS-$@)

help:
	@echo "$(P) makefile"
	@echo "usage: make install [ DESTDIR=<path> ]"

tests/testdata/ps4build.key:
	openssl genrsa -out "$@" 4096

tests/testdata/ps4build.key.pub: tests/testdata/ps4build.key
	openssl rsa -in "$<" -pubout -out "$@"

tests/Kyuafile: $(wildcard tests/*_test)
	echo "syntax(2)" > $@
	echo "test_suite('ps4build')" >> $@
	for i in $(notdir $(wildcard tests/*_test)); do \
		echo "atf_test_program{name='$$i',timeout=$(TEST_TIMEOUT)}" >> $@ ; \
	done

Kyuafile: tests/Kyuafile
	echo "syntax(2)" > $@
	echo "test_suite('ps4build')" >> $@
	echo "include('tests/Kyuafile')" >> $@

check: $(SCRIPTS) $(USR_BIN_FILES) functions.sh tests/Kyuafile Kyuafile tests/testdata/ps4build.key.pub
	kyua --variable parallelism=$(shell nproc) test || (kyua report --verbose && exit 1)

install: $(USR_BIN_FILES) $(SAMPLES) $(MAN_PAGES) $(AUTOTOOLS_TOOLCHAIN_FILES) default.conf ps4build.conf functions.sh
	install -D -m 755 -t $(DESTDIR)/$(bindir)/ $(USR_BIN_FILES);\
	chmod 4555 $(DESTDIR)/$(bindir)/ps4build-sudo
	for i in adduser addgroup ps4; do \
		ln -fs ps4build-sudo $(DESTDIR)/$(bindir)/ps4build-$$i; \
	done
	install -D -m 644 -t $(DESTDIR)/$(mandir)/man1/ $(MAN_1_PAGES);\
	install -D -m 644 -t $(DESTDIR)/$(mandir)/man5/ $(MAN_5_PAGES);\
	if [ -n "$(DESTDIR)" ] || [ ! -f "/$(sysconfdir)"/ps4build.conf ]; then\
		install -D -m 644 -t $(DESTDIR)/$(sysconfdir)/ ps4build.conf; \
	fi

	install -D -t $(DESTDIR)/$(sharedir)/ $(AUTOTOOLS_TOOLCHAIN_FILES)
	install -D -m 644 -t $(DESTDIR)/$(sharedir)/ functions.sh default.conf $(SAMPLES)

depends depend:
	sudo ps4 --no-cache -U --virtual .ps4build-depends add openssl-dev openssl-libs-static zlib-dev

.gitignore: Makefile
	echo "*.tar.bz2" > $@
	for i in $(USR_BIN_FILES); do\
		echo $$i >>$@;\
	done


.PHONY: install
