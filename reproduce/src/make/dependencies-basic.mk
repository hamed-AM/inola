# Build the VERY BASIC reproduction pipeline dependencies before everything
# else using minimum Make and Shell.
#
# ------------------------------------------------------------------------
#                      !!!!! IMPORTANT NOTES !!!!!
#
# This Makefile will be run by the initial `./configure' script. It is not
# included into the reproduction pipe after that.
#
# This Makefile builds very low-level and basic tools like GNU Tar, and
# various compression programs, GNU Bash, and GNU Make. Therefore this is
# the only Makefile in the reproduction pipeline where you MUST NOT assume
# that modern GNU Bash or GNU Make are used. After this Makefile, other
# Makefiles can safely assume the fixed version of all these software.
#
# This Makefile is a very simplified version of `dependencies.mk' in the
# same directory. See there for more comments.
#
# ------------------------------------------------------------------------
#
# Original author:
#     Mohammad Akhlaghi <mohammad@akhlaghi.org>
# Contributing author(s):
#     Your name <your@email.address>
# Copyright (C) 2018, Your Name.
#
# This Makefile is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the
# Free Software Foundation, either version 3 of the License, or (at your
# option) any later version.
#
# This Makefile is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
# Public License for more details.
#
# A copy of the GNU General Public License is available at
# <http://www.gnu.org/licenses/>.


# Top level environment
include reproduce/config/pipeline/LOCAL.mk
include reproduce/src/make/dependencies-build-rules.mk
include reproduce/config/pipeline/dependency-versions.mk

ddir  = $(BDIR)/dependencies
tdir  = $(BDIR)/dependencies/tarballs
idir  = $(BDIR)/dependencies/installed
ibdir = $(BDIR)/dependencies/installed/bin
ildir = $(BDIR)/dependencies/installed/lib

# We'll need the system's PATH for making links to low-level programs we
# won't be building ourselves.
syspath         := $(PATH)

# As we build more programs, we want to use our own pipeline's built
# programs and libraries, not the host's.
export PATH              := $(ibdir):$(PATH)
export PKG_CONFIG_PATH   := $(ildir)/pkgconfig
export PKG_CONFIG_LIBDIR := $(ildir)/pkgconfig
export LDFLAGS           := -L$(ildir) $(LDFLAGS)
export CPPFLAGS          := -I$(idir)/include $(CPPFLAGS)
export LD_LIBRARY_PATH   := $(ildir):$(LD_LIBRARY_PATH)

top-level-programs = bash which ls sed gawk grep diff find pkg-config
all: $(foreach p, $(top-level-programs), $(ibdir)/$(p))





# Tarballs
# --------
#
# Prepare tarballs. Difference with that in `dependencies.mk': `.ONESHELL'
# is not recognized by some versions of Make (even older GNU Makes). So
# we'll have to make sure the recipe doesn't break into multiple shell
# calls (so we can preserve the variables).
#
# Software hosted at akhlaghi.org/src: As of our latest check (November
# 2018) their major release tarballs either crash or don't build on some
# systems (for example Make or Gzip), or they don't exist (for example
# Bzip2).
#
# In the first case, we used their Git repo and bootstrapped them (just
# like Gnuastro) and built the most recent tarball off of that. In the case
# of Bzip2: its webpage has expired and doesn't host the data any more. It
# is available on the link below (archive.org):
#
# https://web.archive.org/web/20180624184806/http://www.bzip.org/1.0.6/bzip2-1.0.6.tar.gz
#
# However, downloading from this link is slow (because its just a link). So
# its easier to just keep a with the others.
tarballs = $(foreach t, bash-$(bash-version).tar.gz                         \
                        bzip2-$(bzip2-version).tar.gz                       \
                        coreutils-$(coreutils-version).tar.xz               \
                        diffutils-$(diffutils-version).tar.xz               \
                        findutils-$(findutils-version).tar.lz               \
                        gawk-$(gawk-version).tar.lz                         \
                        grep-$(grep-version).tar.xz                         \
                        gzip-$(gzip-version).tar.gz                         \
                        lzip-$(lzip-version).tar.gz                         \
                        make-$(make-version).tar.lz                         \
                        pkg-config-$(pkgconfig-version).tar.gz              \
                        sed-$(sed-version).tar.xz                           \
	                tar-$(tar-version).tar.gz                           \
                        which-$(which-version).tar.gz                       \
                        xz-$(xz-version).tar.gz                             \
                      , $(tdir)/$(t) )
$(tarballs): $(tdir)/%:
	if [ -f $(DEPENDENCIES-DIR)/$* ]; then                              \
	  cp $(DEPENDENCIES-DIR)/$* $@;                                     \
	else                                                                \
	  n=$$(echo $* | sed -e's/[0-9\-]/ /g'                              \
	                     -e's/\./ /g'                                   \
	               | awk '{print $$1}' );                               \
	                                                                    \
	  mergenames=1;                                                     \
	  if   [ $$n = bash      ]; then w=http://ftp.gnu.org/gnu/bash;     \
	  elif [ $$n = bzip      ]; then w=http://akhlaghi.org/src;         \
	  elif [ $$n = coreutils ]; then w=http://ftp.gnu.org/gnu/coreutils;\
	  elif [ $$n = diffutils ]; then w=http://ftp.gnu.org/gnu/diffutils;\
	  elif [ $$n = findutils ]; then w=http://akhlaghi.org/src;         \
	  elif [ $$n = gawk      ]; then w=http://ftp.gnu.org/gnu/gawk;     \
	  elif [ $$n = grep      ]; then w=http://ftp.gnu.org/gnu/grep;     \
	  elif [ $$n = gzip      ]; then w=http://akhlaghi.org/src;         \
	  elif [ $$n = lzip      ]; then w=http://download.savannah.gnu.org/releases/lzip; \
	  elif [ $$n = make      ]; then w=http://akhlaghi.org/src;         \
	  elif [ $$n = pkg       ]; then w=https://pkg-config.freedesktop.org/releases; \
	  elif [ $$n = sed       ]; then w=http://ftp.gnu.org/gnu/sed;      \
	  elif [ $$n = tar       ]; then w=http://ftp.gnu.org/gnu/tar;      \
	  elif [ $$n = which     ]; then w=http://ftp.gnu.org/gnu/which;    \
	  elif [ $$n = xz        ]; then w=http://tukaani.org/xz;           \
	  else                                                              \
	    echo; echo; echo;                                               \
	    echo "'$$n' not a basic dependency name (for downloading)."     \
	    echo; echo; echo;                                               \
	    exit 1;                                                         \
	  fi;                                                               \
	                                                                    \
	  if [ $$mergenames = 1 ]; then  tarballurl=$$w/"$*";               \
	  else                           tarballurl=$$w;                    \
	  fi;                                                               \
	  echo "Downloading $$tarballurl";                                  \
	  $(DOWNLOADER) $@ $$tarballurl;                                    \
	fi

# C compiler and linker
# ---------------------
#
# --disable-multilib: ignore 32-bit installation for 64-bit systems.





# Low-level (not built) programs
# ------------------------------
#
# For the time being, we aren't building a local C compiler, but we'll use
# any C compiler that the system already has and just make a symbolic link
# to it.
makelink = a=$$(which $(1) 2> /dev/null); \
	   if [ x$$a != x ]; then ln -s $$a $(ibdir)/$(1); fi
$(ibdir):; mkdir $@
$(ibdir)/low-level: | $(ibdir)
        # We aren't building these low-levels tools yet ourselves. We'll
        # thus just use what the host operating system has available.
	PATH=$(syspath)

        # The Assembler
	$(call makelink,as)

        # The compiler
	$(call makelink,clang)
	$(call makelink,gcc)
	$(call makelink,g++)
	$(call makelink,cc)

        # The linker
	$(call makelink,ar)
	$(call makelink,ld)
	$(call makelink,nm)
	$(call makelink,ps)

        # On Mac OS, libtool is different compared to GNU Libtool. The
        # libtool we'll build in the high-level dependencies has the
        # executable name `glibtool'.
	$(call makelink,libtool)

        # GNU Gettext (translate messages)
	$(call makelink,msgfmt)

        # GNU M4 (for managing building macros)
	$(call makelink,m4)

        # Needed by TeXLive specifically
	$(call makelink,perl)
	$(call makelink,wget)

	echo "Low-level program links are setup" > $@





# Compression programs
# --------------------
#
# The first set of programs to be built are those that we need to unpack
# the source code tarballs of each program. First, we'll build the
# necessary programs, then we'll build GNU Tar.
$(ibdir)/gzip: $(tdir)/gzip-$(gzip-version).tar.gz \
	       $(ibdir)/low-level
	$(call gbuild, $<, gzip-$(gzip-version), static)

# GNU Lzip: For a static build, the `-static' flag should be given to
# LDFLAGS on the command-line (not from the environment).
$(ibdir)/lzip: $(tdir)/lzip-$(lzip-version).tar.gz \
               $(ibdir)/low-level
ifeq ($(static_build),yes)
	$(call gbuild, $<, lzip-$(lzip-version), , LDFLAGS="-static")
else
	$(call gbuild, $<, lzip-$(lzip-version))
endif

$(ibdir)/xz: $(tdir)/xz-$(xz-version).tar.gz \
             $(ibdir)/low-level
	$(call gbuild, $<, xz-$(xz-version), static)

$(ibdir)/bzip2: $(tdir)/bzip2-$(bzip2-version).tar.gz \
	        $(ibdir)/low-level
	 tdir=bzip2-$(bzip2-version);                                  \
	 if [ $(static_build) = yes ]; then                            \
	   makecommand="make LDFLAGS=-static";                         \
	 else                                                          \
	   makecommand="make";                                         \
	 fi;                                                           \
	 cd $(ddir) && rm -rf $$tdir && tar xf $< && cd $$tdir &&      \
	 $$makecommand && make install PREFIX=$(idir) &&               \
	 cd .. && rm -rf $$tdir

# GNU Tar: When built statically, tar gives a segmentation fault on
# unpacking Bash. So we'll build it dynamically.
$(ibdir)/tar: $(tdir)/tar-$(tar-version).tar.gz \
	      $(ibdir)/bzip2                    \
	      $(ibdir)/lzip                     \
	      $(ibdir)/gzip                     \
	      $(ibdir)/xz
	$(call gbuild, $<, tar-$(tar-version))





# GNU Make
# --------
#
# GNU Make is the second layer that we'll need to build the basic
# dependencies.
#
# Unfortunately it needs dynamic linking in two instances: when loading
# objects (dynamically linked libraries), or when using the `getpwnam'
# function (for tilde expansion). The first can be disabled with
# `--disable-load', but unfortunately I don't know any way to fix the
# second. So, we'll have to build it dynamically for now.
$(ibdir)/make: $(tdir)/make-$(make-version).tar.lz \
               $(ibdir)/tar
	$(call gbuild, $<, make-$(make-version))





# Basic command-line programs necessary in build process of the
# higher-level dependencies: Note that during the building of those
# programs, there is no access to the system's PATH.
$(ibdir)/diff: $(tdir)/diffutils-$(diffutils-version).tar.xz \
               $(ibdir)/make
	$(call gbuild, $<, diffutils-$(diffutils-version), static)

$(ibdir)/find: $(tdir)/findutils-$(findutils-version).tar.lz \
               $(ibdir)/make
	$(call gbuild, $<, findutils-$(findutils-version), static)

$(ibdir)/gawk: $(tdir)/gawk-$(gawk-version).tar.lz \
               $(ibdir)/make
	$(call gbuild, $<, gawk-$(gawk-version), static)

$(ibdir)/grep: $(tdir)/grep-$(grep-version).tar.xz \
               $(ibdir)/make
	$(call gbuild, $<, grep-$(grep-version), static)

$(ibdir)/ls: $(tdir)/coreutils-$(coreutils-version).tar.xz \
             $(ibdir)/make
	$(call gbuild, $<, coreutils-$(coreutils-version), static)

$(ibdir)/pkg-config: $(tdir)/pkg-config-$(pkgconfig-version).tar.gz \
                     $(ibdir)/make
	$(call gbuild, $<, pkg-config-$(pkgconfig-version), static, \
                       --with-internal-glib)

$(ibdir)/sed: $(tdir)/sed-$(sed-version).tar.xz \
              $(ibdir)/make
	$(call gbuild, $<, sed-$(sed-version), static)

$(ibdir)/which: $(tdir)/which-$(which-version).tar.gz \
	        $(ibdir)/make
	$(call gbuild, $<, which-$(which-version), static)





# GNU Bash
$(ibdir)/bash: $(tdir)/bash-$(bash-version).tar.gz \
	       $(ibdir)/make

        # Delete any possibly existing output
	if [ -f $@ ]; then rm $@; fi;

        # Build Bash.
ifeq ($(static_build),yes)
	$(call gbuild, $<, bash-$(bash-version), , --enable-static-link)
else
	$(call gbuild, $<, bash-$(bash-version))
endif

        # To be generic, some systems use the `sh' command to call the
        # shell. By convention, `sh' is just a symbolic link to the
        # preferred shell executable. So we'll define `$(ibdir)/sh' as a
        # symbolic link to the Bash that we just built and installed.
        #
        # Just to be sure that the installation step above went well,
        # before making the link, we'll see if the file actually exists
        # there.
	if [ -f $@ ]; then ln -s $@ $(ibdir)/sh; fi
