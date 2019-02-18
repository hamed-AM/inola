# Build the reproduction pipeline Python dependencies.
#
# ------------------------------------------------------------------------
#                      !!!!! IMPORTANT NOTES !!!!!
#
# This Makefile will be run by the initial `./configure' script. It is not
# included into the reproduction pipe after that.
#
# ------------------------------------------------------------------------
#
# Original author:
#     Raul Infante-Sainz <infantesainz@gmail.com>
# Contributing author(s):
#     Mohammad Akhlaghi <mohammad@akhlaghi.org>
# Copyright (C) 2019, Your Name.
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

ddir   = $(BDIR)/dependencies
tdir   = $(BDIR)/dependencies/tarballs
idir   = $(BDIR)/dependencies/installed
ibdir  = $(BDIR)/dependencies/installed/bin
ildir  = $(BDIR)/dependencies/installed/lib
ilidir = $(BDIR)/dependencies/installed/lib/built
ipydir = $(BDIR)/dependencies/installed/lib/built/python

# Define the top-level programs to build (installed in `.local/bin').
top-level-python   = astroquery
all: $(foreach p, $(top-level-python), $(ipydir)/$(p))

# Other basic environment settings: We are only including the host
# operating system's PATH environment variable (after our own!) for the
# compiler and linker. For the library binaries and headers, we are only
# using our internally built libraries.
#
# To investigate:
#
#    1) Set SHELL to `$(ibdir)/env - NAME=VALUE $(ibdir)/bash' and set all
#       the parameters defined bellow as `NAME=VALUE' statements before
#       calling Bash. This will enable us to completely ignore the user's
#       native environment.
#
#    2) Add `--noprofile --norc' to `.SHELLFLAGS' so doesn't load the
#       user's environment.
.ONESHELL:
.SHELLFLAGS              := --noprofile --norc -ec
export CCACHE_DISABLE    := 1
export PATH              := $(ibdir)
export LD_RUN_PATH       := $(ildir)
export LD_LIBRARY_PATH   := $(ildir)
export SHELL             := $(ibdir)/bash
export CPPFLAGS          := -I$(idir)/include
export PKG_CONFIG_PATH   := $(ildir)/pkgconfig
export PKG_CONFIG_LIBDIR := $(ildir)/pkgconfig
export LDFLAGS           := $(rpath_command) -L$(ildir)





# Tarballs
# --------
#
# All the necessary tarballs are defined and prepared with this rule.
#
# Note that we want the tarballs to follow the convention of NAME-VERSION
# before the `tar.XX' prefix. For those programs that don't follow this
# convention, but include the name/version in their tarball names with
# another format, we'll do the modification before the download so the
# downloaded file has our desired format.
tarballs = $(foreach t, astroquery-$(astroquery-version).tar.gz           \
                        astropy-$(astropy-version).tar.gz                 \
                        beautifulsoup4-$(beautifulsoup4-version).tar.gz   \
                        certifi-$(certifi-version).tar.gz                 \
                        chardet-$(chardet-version).tar.gz                 \
                        entrypoints-$(entrypoints-version).tar.gz         \
                        html5lib-$(html5lib-version).tar.gz               \
                        idna-$(idna-version).tar.gz                       \
                        keyring-$(keyring-version).tar.gz                 \
                        numpy-$(numpy-version).zip                        \
                        pip-$(pip-version).tar.gz                         \
                        python-$(python-version).tar.gz                   \
                        requests-$(requests-version).tar.gz               \
                        setuptools-$(setuptools-version).zip              \
                        setuptools_scm-$(setuptools_scm-version).tar.gz   \
                        six-$(six-version).tar.gz                         \
                        soupsieve-$(soupsieve-version).tar.gz             \
                        urllib3-$(urllib3-version).tar.gz                 \
                        webencodings-$(webencodings-version).tar.gz       \
                        virtualenv-$(virtualenv-version).tar.gz           \
                      , $(tdir)/$(t) )
topurl=https://files.pythonhosted.org/packages
$(tarballs): $(tdir)/%:
	if [ -f $(DEPENDENCIES-DIR)/$* ]; then
	  cp $(DEPENDENCIES-DIR)/$* $@
	else
          # Remove all numbers, `-' and `.' from the tarball name so we can
          # search more easily only with the program name.
	  n=$$(echo $* | sed -e's/[0-9\-]/ /g' -e's/\./ /g'           \
	               | awk '{print $$1}' )

          # Set the top download link of the requested tarball.
	  mergenames=1
	  if [ $$n = python           ]; then
	    mergenames=0
	    w=https://www.python.org/ftp/python/$(python-version)/Python-$(python-version).tgz
	  elif [ $$n = astroquery     ]; then h=61/50/a7a08f9e54d7d9d97e69433cd88231e1ad2901811c9d1ae9ac7ccaef9396
	  elif [ $$n = astropy        ]; then h=eb/f7/1251bf6881861f24239efe0c24cbcfc4191ccdbb69ac3e9bb740d0c23352
	  elif [ $$n = beautifulsoup  ]; then h=80/f2/f6aca7f1b209bb9a7ef069d68813b091c8c3620642b568dac4eb0e507748
	  elif [ $$n = certifi        ]; then h=55/54/3ce77783acba5979ce16674fc98b1920d00b01d337cfaaf5db22543505ed
	  elif [ $$n = chardet        ]; then h=fc/bb/a5768c230f9ddb03acc9ef3f0d4a3cf93462473795d18e9535498c8f929d
	  elif [ $$n = entrypoints    ]; then h=b4/ef/063484f1f9ba3081e920ec9972c96664e2edb9fdc3d8669b0e3b8fc0ad7c
	  elif [ $$n = html           ]; then h=85/3e/cf449cf1b5004e87510b9368e7a5f1acd8831c2d6691edd3c62a0823f98f
	  elif [ $$n = idna           ]; then h=ad/13/eb56951b6f7950cadb579ca166e448ba77f9d24efc03edd7e55fa57d04b7
	  elif [ $$n = keyring        ]; then h=15/88/c6ce9509438bc02d54cf214923cfba814412f90c31c95028af852b19f9b2
	  elif [ $$n = numpy          ]; then h=2b/26/07472b0de91851b6656cbc86e2f0d5d3a3128e7580f23295ef58b6862d6c
	  elif [ $$n = pip            ]; then h=4c/4d/88bc9413da11702cbbace3ccc51350ae099bb351febae8acc85fec34f9af
	  elif [ $$n = requests       ]; then h=52/2c/514e4ac25da2b08ca5a464c50463682126385c4272c18193876e91f4bc38
	  elif [ $$n = setuptools     ]; then h=c2/f7/c7b501b783e5a74cf1768bc174ee4fb0a8a6ee5af6afa92274ff964703e0
	  elif [ $$n = setuptools_scm ]; then h=54/85/514ba3ca2a022bddd68819f187ae826986051d130ec5b972076e4f58a9f3
	  elif [ $$n = six            ]; then h=dd/bf/4138e7bfb757de47d1f4b6994648ec67a51efe58fa907c1e11e350cddfca
	  elif [ $$n = soupsieve      ]; then h=0c/52/e9088bb9b96e2d39fc3b33fcda5b4fde9d71473536ac660a1ca9a0958a2f
	  elif [ $$n = virtualenv     ]; then h=51/aa/c395a6e6eaaedfa5a04723b6446a1df783b16cca6fec66e671cede514688
	  elif [ $$n = webencodings   ]; then h=0b/02/ae6ceac1baeda530866a85075641cec12989bd8d31af6d5ab4a3e8c92f47
	  else
	    echo; echo; echo;
	    echo "'$$n' not recognized as a dependency name to download."
	    echo; echo; echo;
	    exit 1
	  fi

          # Download the requested tarball. Note that some packages may not
          # follow our naming convention (where the package name is merged
          # with its version number). In such cases, `w' will be the full
          # address, not just the top directory address. But since we are
          # storing all the tarballs in one directory, we want it to have
          # the same naming convention, so we'll download it to a temporary
          # name, then rename that.
	  if [ $$mergenames = 1 ]; then  tarballurl=$(topurl)/$$h/"$*"
	  else                           tarballurl=$$h
	  fi

          # If the download fails, Wget will write the error message in the
          # target file, so Make will think that its done! To avoid this
          # problem, we'll rename the output.
	  echo "Downloading $$tarballurl"
	  if ! wget --no-use-server-timestamps -O$@ $$tarballurl; then
	     rm -f $@
	     echo; echo "DOWNLOAD FAILED: $$tarballurl"; echo; exit 1
	  fi
	fi





# Install without pip
# --------------------
#
# To build Python packages with direct access to a `setup.py' (if no direct
# access to `setup.py' is needed, pip can be used)
# Arguments of this function are the numbers
#   1) Unpack command
#   2) Package name
#   3) Unpacked directory name after unpacking the tarball
pybuild = cd $(ddir); rm -rf $(3);                                        \
	 if ! $(1) $(2); then echo; echo "Tar error"; exit 1; fi;             \
	 cd $(3);                                                             \
	 python3 setup.py build &&                                            \
	 python3 setup.py install &&                                          \
	 cd .. && rm -rf $(3) &&                                              \
	 echo "done!" > $@





# Python installation
# -------------------
#
$(ibdir)/python3: $(tdir)/python-$(python-version).tar.gz
	$(call gbuild, $<, Python-$(python-version))        \
	&& v=$$(echo $(python-version) | awk 'BEGIN{FS="."} \
	    {printf "%d.%d\n", $$1, $$2}')                  \
	&& ln -s $(ildir)/python$$v $(ildir)/python         \
	&& rm -rf $(ipydir) && mkdir $(ipydir)




# Python packages
# ---------------
#
$(ipydir)/astroquery: $(tdir)/astroquery-$(astroquery-version).tar.gz  \
                      $(ipydir)/astropy                                \
                      $(ipydir)/beautifulsoup4                         \
                      $(ipydir)/html5lib                               \
                      $(ipydir)/keyring                                \
                      $(ipydir)/numpy                                  \
                      $(ipydir)/requests
	$(call pybuild, tar xf, $<, astroquery-$(astroquery-version))

$(ipydir)/astropy: $(tdir)/astropy-$(astropy-version).tar.gz \
                   $(ipydir)/numpy
	$(call pybuild, tar xf, $<, astropy-$(astropy-version))

$(ipydir)/beautifulsoup4: $(tdir)/beautifulsoup4-$(beautifulsoup4-version).tar.gz \
                          $(ipydir)/soupsieve
	$(call pybuild, tar xf, $<, beautifulsoup4-$(beautifulsoup4-version))

$(ipydir)/certifi: $(tdir)/certifi-$(certifi-version).tar.gz \
                   $(ibdir)/python3
	$(call pybuild, tar xf, $<, certifi-$(certifi-version))

$(ipydir)/chardet: $(tdir)/chardet-$(chardet-version).tar.gz \
                   $(ibdir)/python3
	$(call pybuild, tar xf, $<, chardet-$(chardet-version))

$(ipydir)/entrypoints: $(tdir)/entrypoints-$(entrypoints-version).tar.gz \
                       $(ibdir)/python3
	$(call pybuild, tar xf, $<, entrypoints-$(entrypoints-version))

$(ipydir)/html5lib: $(tdir)/html5lib-$(html5lib-version).tar.gz  \
                    $(ipydir)/six                                \
                    $(ipydir)/webencodings
	$(call pybuild, tar xf, $<, html5lib-$(html5lib-version))

$(ipydir)/idna: $(tdir)/idna-$(idna-version).tar.gz \
                $(ibdir)/python3
	$(call pybuild, tar xf, $<, idna-$(idna-version))

$(ipydir)/keyring: $(tdir)/keyring-$(keyring-version).tar.gz    \
                   $(ipydir)/entrypoints                        \
                   $(ipydir)/setuptools_scm
	$(call pybuild, tar xf, $<, keyring-$(keyring-version))

$(ipydir)/numpy: $(tdir)/numpy-$(numpy-version).zip \
                 $(ibdir)/python3
	$(call pybuild, unzip, $<, numpy-$(numpy-version))

$(ibdir)/pip3: $(tdir)/pip-$(pip-version).tar.gz \
               $(ibdir)/python3
	$(call pybuild, tar xf, $<, pip-$(pip-version))

$(ipydir)/requests: $(tdir)/requests-$(requests-version).tar.gz   \
                    $(ipydir)/certifi                             \
                    $(ipydir)/chardet                             \
                    $(ipydir)/idna                                \
                    $(ipydir)/numpy                               \
                    $(ipydir)/urllib3
	$(call pybuild, tar xf, $<, requests-$(requests-version))

$(ipydir)/setuptools: $(tdir)/setuptools-$(setuptools-version).zip \
                      $(ibdir)/python3
	$(call pybuild, unzip, $<, setuptools-$(setuptools-version))

$(ipydir)/setuptools_scm: $(tdir)/setuptools_scm-$(setuptools_scm-version).tar.gz \
                          $(ipydir)/setuptools
	$(call pybuild, tar xf, $<, setuptools_scm-$(setuptools_scm-version))

$(ipydir)/six: $(tdir)/six-$(six-version).tar.gz \
               $(ibdir)/python3
	$(call pybuild, tar xf, $<, six-$(six-version))

$(ipydir)/soupsieve: $(tdir)/soupsieve-$(soupsieve-version).tar.gz \
                     $(ibdir)/python3
	$(call pybuild, tar xf, $<, soupsieve-$(soupsieve-version))

$(ipydir)/urllib3: $(tdir)/urllib3-$(urllib3-version).tar.gz \
                   $(ibdir)/python3
	$(call pybuild, tar xf, $<, urllib3-$(urllib3-version))

$(ipydir)/webencodings: $(tdir)/webencodings-$(webencodings-version).tar.gz \
                        $(ibdir)/python3
	$(call pybuild, tar xf, $<, webencodings-$(webencodings-version))

