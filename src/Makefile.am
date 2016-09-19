
include $(top_srcdir)/Common.am

export O=$(LINUX_BUILDDIR)
AM_MAKEFLAGS = -j$(MAKE_PROCESS)


MODULES = \
          axidma_example0 \
          axidma_example1 \
          axidma_example2 \
          axidma_example3 \
          axidma_example4 \
          axidma_example5 \
          axidma_example6 \
          base_example_list

TEST_EXAMPLES = \
          test_example2 \
          test_example3 \
          test_example4 \
          test_example5 \
          test_example6
          
MOSTLYCLEANFILES = $(TEST_EXAMPLES)


.PHONY: modules
modules: $(MODULES:=.c) Kbuild
	@ echo " --- building modules ---"; \
	  $(MAKE) $(AM_MAKEFLAGS) -C ${LINUX_DIR} \
	  CFLAGS="$(LINUX_CFLAGS)" M=`pwd` O=$$O \
	  srcdir=$(srcdir) builddir=$(builddir) modules

clean-local:
	@ echo " --- cleaning modules ---"; \
	$(MAKE) $(AM_MAKEFLAGS) -C ${LINUX_DIR} \
	     CFLAGS="$(LINUX_CFLAGS)" M=`pwd` O=$$O \
	     srcdir=$(srcdir) builddir=$(builddir) clean

.PHONY: test_examples
test_examples: $(TEST_EXAMPLES)

$(TEST_EXAMPLES):
	@ echo " --- building $@ ---"; \
	${CROSS_COMPILE}${CC} $(LINUX_CFLAGS) $(srcdir)/$@.c -o $@ -lpthread


.PHONY: deploy
deploy: modules test_example2 test_example3 test_example4
if WITH_DEVICE_SSHKEY
	@ echo " --- deploying modules to target device: ${DEVICE_NAME} using key ---"; \
	scp -i $(DEVICE_SSHKEY) $(MODULES:=.ko) $(TEST_EXAMPLES) \
	  $(DEVICE_USER)@$(DEVICE_IP):$(DEVICE_MODULES_DIR);
else
if WITH_DEVICE_SSHPASSWD
	@ echo " --- deploying modules to target device: ${DEVICE_NAME} using passwd ---"; \
	sshpass -p ${DEVICE_PASSWD} scp $(MODULES:=.ko) $(TEST_EXAMPLES) \
	  $(DEVICE_USER)@$(DEVICE_IP):$(DEVICE_MODULES_DIR);
endif
endif




all: modules test_examples



	

