ifndef ROLLCOMPILER
  ROLLCOMPILER = gnu
endif
COMPILERNAME := $(firstword $(subst /, ,$(ROLLCOMPILER)))

ifndef ROLLMPI
  ROLLMPI = rocks-openmpi
endif
MPINAME := $(firstword $(subst /, ,$(ROLLMPI)))

NAME           = sdsc-cpmd
VERSION        = 3.17.1
RELEASE        = 5
PKGROOT        = /opt/cpmd

SRC_SUBDIR     = cpmd

SOURCE_NAME    = cpmd
SOURCE_SUFFIX  = tar.gz
SOURCE_VERSION = v3_17_1
SOURCE_PKG     = $(SOURCE_NAME)-$(SOURCE_VERSION).$(SOURCE_SUFFIX)
SOURCE_DIR     = CPMD

TAR_GZ_PKGS    = $(SOURCE_PKG)

RPM.EXTRAS     = AutoReq:No
RPM.PREFIX     = $(PKGROOT)
