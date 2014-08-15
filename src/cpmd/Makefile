# $Id$
#
# @Copyright@
# 
# 				Rocks(r)
# 		         www.rocksclusters.org
# 		         version 5.6 (Emerald Boa)
# 		         version 6.1 (Emerald Boa)
# 
# Copyright (c) 2000 - 2013 The Regents of the University of California.
# All rights reserved.	
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
# 
# 1. Redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer.
# 
# 2. Redistributions in binary form must reproduce the above copyright
# notice unmodified and in its entirety, this list of conditions and the
# following disclaimer in the documentation and/or other materials provided 
# with the distribution.
# 
# 3. All advertising and press materials, printed or electronic, mentioning
# features or use of this software must display the following acknowledgement: 
# 
# 	"This product includes software developed by the Rocks(r)
# 	Cluster Group at the San Diego Supercomputer Center at the
# 	University of California, San Diego and its contributors."
# 
# 4. Except as permitted for the purposes of acknowledgment in paragraph 3,
# neither the name or logo of this software nor the names of its
# authors may be used to endorse or promote products derived from this
# software without specific prior written permission.  The name of the
# software includes the following terms, and any derivatives thereof:
# "Rocks", "Rocks Clusters", and "Avalanche Installer".  For licensing of 
# the associated name, interested parties should contact Technology 
# Transfer & Intellectual Property Services, University of California, 
# San Diego, 9500 Gilman Drive, Mail Code 0910, La Jolla, CA 92093-0910, 
# Ph: (858) 534-5815, FAX: (858) 534-7345, E-MAIL:invent@ucsd.edu
# 
# THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS''
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS
# BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
# BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
# IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# 
# @Copyright@
#
# $Log$

REDHAT.ROOT = $(CURDIR)/../../
PKGROOT = /opt/cpmd

-include $(ROCKSROOT)/etc/Rules.mk
include Rules.mk
include pull.mk

CPPFLAGS := -D__Linux -DFFT_FFTW -DPARALLEL -DPOINTER8 -DINTEL_MKL 
ifeq ("$(ROLLCOMPILER)", "intel")
  F90COMP = ifort
  FFLAGS = -c -xHost
else ifeq ("$(ROLLCOMPILER)", "pgi")
  CPPFLAGS += -D__PGI -D__pgf90
  F90COMP = pgf90
  FFLAGS = -c -r8 -pc=64 -Msignextend
  LFLAGS = -Bstatic
else
  CPPFLAGS += -D__GNU
  F90COMP = gfortran
  FFLAGS = -c -O2 -fcray-pointer -fno-whole-file
endif

ifeq ("$(ROLLNETWORK)", "mx")
  CPPFLAGS += -DMYRINET
endif

COMPILERSETUP = \
  if test -e /etc/profile.d/modules.sh; then \
    . /etc/profile.d/modules.sh; \
    module load $(ROLLCOMPILER) || true; \
  fi; \
  echo === Compiler and version ===; \
  $(F90COMP) --version; \
  if test -n "$${MKL_ROOT}"; then \
    export MKLLIB=`find $${MKL_ROOT}/lib/* -maxdepth 0 | head -1`; \
  fi

ifeq ("$(ROLLNETWORK)", "eth")
  MPIMODULE = $(ROLLMPI)
else
  MPIMODULE = $(ROLLMPI)_$(ROLLNETWORK)
endif

MPISETUP = \
  if test -e /etc/profile.d/modules.sh; then \
    . /etc/profile.d/modules.sh; \
    module load $(MPIMODULE); \
  fi; \
  export MPI_HOME=`which mpicxx | perl -pe 's!/bin/.*!!'`; \
  if test -z "$${MPI_HOME}"; then \
    export MPI_HOME=/opt/$(ROLLMPI); \
  fi; \
  echo === MPI_HOME ===; \
  echo $${MPI_HOME}; \
  export PATH=$${PATH}:$${MPI_HOME}/bin; \
  export LD_LIBRARY_PATH=$${LD_LIBRARY_PATH}:$${MPI_HOME}/lib

FFTWSETUP = \
  if test -e /etc/profile.d/modules.sh; then \
    . /etc/profile.d/modules.sh; \
    module load fftw/2.1.5; \
  fi; \
  echo === FFTWHOME ===; \
  echo $${FFTWHOME}

build: $(SRC_DIRS)
	( \
	  $(COMPILERSETUP); \
	  $(MPISETUP); \
	  $(FFTWSETUP); \
	  cd $(SOURCE_DIR); \
	  ./mkconfig.sh LINUX-x86_64-FEDORA-MPI > Makefile; \
	  export LFLAGS="-L. -L$${MKLLIB} -lmkl_rt -lm -lpthread -L$${FFTWHOME}/lib -lfftw $(LFLAGS)"; \
	  $(MAKE) CPPFLAGS="$(CPPFLAGS)" FFLAGS="$(FFLAGS)" LFLAGS="$${LFLAGS}"; \
	  $(MAKE) CPPFLAGS="$(CPPFLAGS)" FFLAGS="$(FFLAGS)" LFLAGS="$${LFLAGS}" plotband.x \
	)
	@echo "::: Package $(NAME) build complete :::"
	
install::
	mkdir -p -m 755 $(ROOT)/$(PKGROOT)
	mkdir -p -m 755 $(ROOT)/$(PKGROOT)/bin
	mkdir -p -m 755 $(ROOT)/$(PKGROOT)/lib
	cp `ls patch-files/lib/*|grep -v '\(CVS\|Root\|Repository\|Entries\)'` $(ROOT)/$(PKGROOT)/lib
	( \
	  cd $(SOURCE_DIR); \
	  cp cpmd.x plotband.x $(ROOT)/$(PKGROOT)/bin; \
	)
	@echo "::: Package $(NAME) install complete :::"

clean::
	rm -rf $(SOURCE_DIR)
