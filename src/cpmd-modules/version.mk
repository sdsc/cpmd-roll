NAME        = cpmd-modules
RELEASE     = 2
PKGROOT     = /opt/modulefiles/applications/cpmd

VERSION_SRC = $(REDHAT.ROOT)/src/cpmd/version.mk
VERSION_INC = version.inc
include $(VERSION_INC)

RPM.EXTRAS  = AutoReq:No
