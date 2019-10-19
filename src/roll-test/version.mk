NAME       = sdsc-cpmd-roll-test
VERSION    = 1
RELEASE    = 4
PKGROOT    = /root/rolltests

CUDAVER=
ifneq ("$(ROLLOPTS)", "$(subst cuda=,,$(ROLLOPTS))")
  CUDAVER = $(subst cuda=,,$(filter cuda=%,$(ROLLOPTS)))
endif


RPM.EXTRAS = AutoReq:No\nAutoProv:No
RPM.FILES  = $(PKGROOT)/cpmd.t
