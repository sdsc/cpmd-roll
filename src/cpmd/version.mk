ifndef ROLLCOMPILER
  ROLLCOMPILER = gnu
endif
COMPILERNAME := $(firstword $(subst /, ,$(ROLLCOMPILER)))

ifndef ROLLNETWORK
  ROLLNETWORK = eth
endif

ifndef ROLLMPI
  ROLLMPI = openmpi
endif

NAME               = cpmd_$(COMPILERNAME)_$(ROLLMPI)_$(ROLLNETWORK)
VERSION            = 3.15.3
RELEASE            = 1
RPM.EXTRAS         = AutoReq:No

SRC_SUBDIR         = cpmd

SOURCE_NAME        = cpmd
SOURCE_VERSION     = $(VERSION)
SOURCE_SUFFIX      = tgz
SOURCE_PKG         = $(SOURCE_NAME).$(SOURCE_VERSION).$(SOURCE_SUFFIX)
SOURCE_DIR         = $(SOURCE_PKG:%.$(SOURCE_SUFFIX)=%)

TGZ_PKGS           = $(SOURCE_PKG)
