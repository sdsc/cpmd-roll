#
# $Id$
#
# @Copyright@
#
#                               Rocks(r)
#                        www.rocksclusters.org
#                        version 7.0 (Manzanita)
#
# Copyright (c) 2000 - 2017 The Regents of the University of California.
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
#       "This product includes software developed by the Rocks(r)
#       Cluster Group at the San Diego Supercomputer Center at the
#       University of California, San Diego and its contributors."
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
#

REDHAT.ROOT = $(CURDIR)/../../

-include $(ROCKSROOT)/etc/Rules.mk
include Rules.mk
include $(SDSCDEVEL)/Pull.mk
include $(SDSCDEVEL)/Rules.mk

CPMDTYPE=LINUX-X86_64-GFORTRAN-MPI
ifeq ("$(COMPILERNAME)", "intel")
  CPMDTYPE=LINUX-X86_64-INTEL-MPI-FFTW
else ifeq ("$(COMPILERNAME)", "pgi")
  CPMDTYPE=LINUX-PGI-MPI
endif

ifneq ("$(MPINAME)", "$(subst mx,,$(MPINAME))")
  CPPFLAGS += -DMYRINET
endif

$(NAME).spec: DESCRIPTION LICENSE

DESCRIPTION:
	$(MODULE_LOAD_FC); \
	( \
	  $(DESCRIBE_PKG); \
	  $(DESCRIBE_FC); \
	  $(DESCRIBE_MKL); \
	  $(DESCRIBE_MPI); \
	  $(DESCRIBE_FFTW); \
          if test "$(CUDABUILD)" = "yes"; then \
	     $(DESCRIBE_CUDA); \
          fi \
	) > $@

LICENSE: $(SRC_DIRS)
	cp license-files/CPMD_LICENSE $(SOURCE_DIR)/
	$(CHECK_LICENSE_FILES)
	echo IBM > $@

CUDABUILD = no
ifneq ("$(ROLLOPTS)", "$(subst cuda,,$(ROLLOPTS))")
  CUDABUILD = yes
endif

build: $(SRC_DIRS)
	patch $(SOURCE_DIR)/configure/$(CPMDTYPE)  patch-files/$(CPMDTYPE).patch
	patch $(SOURCE_DIR)/src/cpmd.F90 patch-files/cpmd.F90.patch
	( \
	  $(MODULE_LOAD_FC); \
	  $(MODULE_LOAD_MKL); \
	  export MKLLIB=$${MKLHOME}/lib/intel64; \
          perl -pi -e "s!MKLROOT!$${MKLLIB}!g" $(SOURCE_DIR)/configure/$(CPMDTYPE); \
	  $(MODULE_LOAD_MPI); \
	  $(MODULE_LOAD_FFTW); \
	  cd $(SOURCE_DIR); \
	  ./configure.sh $(CPMDTYPE); \
          $(MAKE) -j 16; \
          mkdir -p $(PWD)/cache/bin; \
          cp bin/cpmd.x $(PWD)/cache/bin; \
	  if test "$(CUDABUILD)" = "yes"; then \
	       patch configure/$(CPMDTYPE)-CUDA  ../patch-files/$(CPMDTYPE)-CUDA.patch; \
               $(MODULE_LOAD_CUDA); \
               make clean; \
               cp $(PWD)/$(CPMDTYPE)-CUDA configure; \
	       perl -pi -e "s!CUDAPATH!$${CUDAHOME}!g" configure/$(CPMDTYPE)-CUDA; \
	       ./configure.sh $(CPMDTYPE)-CUDA; \
               $(MAKE) -j 16; \
               cp bin/cpmd.x $(PWD)/cache/bin/cpmd_cuda.x; \
          fi \
	)
	@echo "::: Package $(NAME) build complete :::"
	
install::
	mkdir -p -m 755 $(ROOT)/$(PKGROOT)/bin
	cp $(SOURCE_DIR)/bin/* $(ROOT)/$(PKGROOT)/bin
	cp -r lib $(ROOT)/$(PKGROOT)
	$(INSTALL_LICENSE_FILES)
	@echo "::: Package $(NAME) install complete :::"

clean::
	rm -rf $(SOURCE_DIR) DESCRIPTION LICENSE cache
