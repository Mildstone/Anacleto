
include $(top_srcdir)/Common.am

AM_MAKEFLAGS = -j$(MAKE_PROCESS)
AM_CPPFLAGS  = -lpthread


MODULES =

TEST_EXAMPLES =
          
MOSTLYCLEANFILES = $(TEST_EXAMPLES)


.PHONY: modules
modules: $(MODULES:=.c) Kbuild
	@ echo " --- building modules ---"; \
	$(_set_export); \
	  $(MAKE) $(AM_MAKEFLAGS) -C ${LINUX_SRCDIR} \
	  CFLAGS="$(LINUX_CFLAGS)" M=`pwd` O=$$O \
	  srcdir=$(srcdir) builddir=$(builddir) modules

clean-local:
	@ echo " --- cleaning modules ---"; \
	$(_set_export); \
	$(MAKE) $(AM_MAKEFLAGS) -C ${LINUX_SRCDIR} \
	     CFLAGS="$(LINUX_CFLAGS)" M=`pwd` O=$$O \
	     srcdir=$(srcdir) builddir=$(builddir) clean

.PHONY: test_examples
test_examples: $(TEST_EXAMPLES)

$(TEST_EXAMPLES):
	echo " --- building $@ ---"; \
	$(_set_export); \
	${CROSS_COMPILE}${CC} $(LINUX_CFLAGS) $(srcdir)/$@.c -o $@ -lpthread


rp-base:
	$(_set_export); \
	$(MAKE) -C rpbase CC=${CROSS_COMPILE}${CC}


.PHONY: deploy
deploy: $(MODULES:=.ko) $(TEST_EXAMPLES)
if WITH_DEVICE_SSHKEY
	@ echo " --- deploying modules to target device: ${DEVICE_NAME} using key ---";
	scp -i $(DEVICE_SSHKEY) $^ \
	  $(DEVICE_USER)@$(DEVICE_IP):$(DEVICE_MODULES_DIR);
else
if WITH_DEVICE_SSHPASSWD
	@ echo " --- deploying modules to target device: ${DEVICE_NAME} using passwd ---";
	sshpass -p ${DEVICE_PASSWD} scp $^ \
	  $(DEVICE_USER)@$(DEVICE_IP):$(DEVICE_MODULES_DIR);
endif
endif


all: modules test_examples



	

