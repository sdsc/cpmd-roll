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

-include $(ROCKSROOT)/etc/Rules.mk
include Rules.mk
include pull.mk

FC = gfortran
ifeq ("$(COMPILERNAME)", "intel")
  FC = ifort
else ifeq ("$(COMPILERNAME)", "pgi")
  FC = pgf90
endif

COMPILERSETUP = \
  module load $(ROLLCOMPILER) || true; \
  echo === Compiler and version ===; \
  $(FC) --version

MKLSETUP = \
  module load mkl || true; \
  echo === MKL_ROOT ===; \
  echo $${MKL_ROOT}; \
  export MKLLIB=`find $${MKL_ROOT}/lib/* -maxdepth 0 | head -1`

MPISETUP = \
  module load $(ROLLMPI) || true; \
  echo === MPIHOME ===; \
  echo $${MPIHOME}

FFTWSETUP = \
  module load fftw/2.1.5; \
  echo === FFTWHOME ===; \
  echo $${FFTWHOME}

CFLAGS := -c -O2
CPPFLAGS := -D__Linux -DFFT_FFTW3 -DPARALLEL -DPOINTER8 -DINTEL_MKL 
ifeq ("$(COMPILERNAME)", "intel")
  CFLAGS += -Wall
  FFLAGS = -c -xHost
else ifeq ("$(COMPILERNAME)", "pgi")
  CFLAGS += -m64
  CPPFLAGS += -D__PGI -D__pgf90 -D__DERF -UFFT_FFTW3 -DFFT_DEFAULT
  FFLAGS = -c -r8 -pc=64 -Msignextend
  LFLAGS = -Bstatic
else
  CFLAGS += -Wall
  CPPFLAGS += -D__GNU
  FFLAGS = -c -O2 -fcray-pointer -fno-whole-file
endif

ifneq ("$(MPINAME)", "$(subst mx,,$(MPINAME))")
  CPPFLAGS += -DMYRINET
endif

build: $(SRC_DIRS)
	patch $(SOURCE_DIR)/plotband.F patch-files/plotband.F.patch
	( \
	  $(COMPILERSETUP); \
	  $(MKLSETUP); \
	  $(MPISETUP); \
	  $(FFTWSETUP); \
	  cd $(SOURCE_DIR); \
	  ./mkconfig.sh LINUX-x86_64-FEDORA-MPI > Makefile; \
	  export LFLAGS="-L. -L$${MKLLIB} -lmkl_rt -lm -lpthread -L$${FFTWHOME}/lib -lfftw $(LFLAGS)"; \
	  export LFLAGS="-L. -L$${MKLLIB} -lmkl_rt -lm -lpthread -L$${FFTWHOME}/lib -lfftw"; \
	  $(MAKE) CC=mpicc CFLAGS="$(CFLAGS)" FC=mpif90 FFLAGS="$(FFLAGS)" LD=mpif90 LFLAGS="$${LFLAGS}" CPPFLAGS="$(CPPFLAGS)"; \
	  $(MAKE) CC=mpicc CFLAGS="$(CFLAGS)" FC=mpif90 FFLAGS="$(FFLAGS)" LD=mpif90 LFLAGS="$${LFLAGS}" CPPFLAGS="$(CPPFLAGS)" plotband.x \
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
