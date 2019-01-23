ifndef ROLLCOMPILER
  ROLLCOMPILER = gnu
endif
COMPILERNAME := $(firstword $(subst /, ,$(ROLLCOMPILER)))

ifndef ROLLMPI
  ROLLMPI = rocks-openmpi
endif
MPINAME := $(firstword $(subst /, ,$(ROLLMPI)))

CUDAVERSION=cuda
ifneq ("$(ROLLOPTS)", "$(subst cuda=,,$(ROLLOPTS))")
  CUDAVERSION = $(subst cuda=,,$(filter cuda=%,$(ROLLOPTS)))
endif

NAME           = sdsc-cpmd
VERSION        = 4.3
RELEASE        = 0
PKGROOT        = /opt/cpmd

SRC_SUBDIR     = cpmd

SOURCE_NAME    = cpmd
SOURCE_SUFFIX  = tar.gz
SOURCE_VERSION = v$(VERSION)
SOURCE_PKG     = $(SOURCE_NAME)-$(SOURCE_VERSION).$(SOURCE_SUFFIX)
SOURCE_DIR     = CPMD

TAR_GZ_PKGS    = $(SOURCE_PKG)

RPM.EXTRAS     = AutoReq:No\nAutoProv:No
RPM.PREFIX     = $(PKGROOT)
