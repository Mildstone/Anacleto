
include ../Common.am

# Main GCC executable (used for compiling and linking)

MODULES = \
          axidma_example0 \
          axidma_example1 \
          axidma_example2 \
          axidma_example3 \
          axidma_example4 \
          axidma_example5 \
          base_example_list

TEST_EXAMPLES = \
          test_example2 \
          test_example3 \
          test_example4 \
          test_example5
          
MOSTLYCLEANFILES = $(TEST_EXAMPLES)



.PHONY: modules
modules: $(MODULES:=.c) Kbuild
	@ echo " --- building modules ---"; \
	  echo " -> $^"; \
	  export PATH="$${PATH}:${TOOLCHAIN_PATH}"; \
	  $(MAKE) $(AM_MAKEFLAGS) -C ${LINUX_DIR} \
	       ARCH=arm CFLAGS="$(LINUX_CFLAGS)" \
	       -j $(MAKE_PROCESS) CROSS_COMPILE=${CROSS_COMPILE} \
	       M=`pwd` O=$(abs_top_builddir)/linux-xlnx \
	       srcdir=$(srcdir) builddir=$(builddir) modules

clean-local:
	@ echo " --- cleaning modules ---"; \
	export PATH="$${PATH}:${TOOLCHAIN_PATH}"; \
	$(MAKE) $(AM_MAKEFLAGS) -C ${LINUX_DIR} \
	     ARCH=arm CFLAGS="$(LINUX_CFLAGS)" \
	     -j $(MAKE_PROCESS) CROSS_COMPILE=${CROSS_COMPILE} \
	     M=`pwd` O=$(abs_top_builddir)/linux-xlnx \
	     srcdir=$(srcdir) builddir=$(builddir) clean



.PHONY: test_examples
test_examples: $(TEST_EXAMPLES)

$(TEST_EXAMPLES):
	@ echo " --- building $@ ---"; \
	export PATH="$${PATH}:${TOOLCHAIN_PATH}"; \
	${CROSS_COMPILE}${CC} $(LINUX_CFLAGS) $(srcdir)/$@.c -o $@




.PHONY: deploy
deploy: modules test_example2 test_example3 test_example4
	@ echo " --- deploying modules to target device: ${DEVICE_NAME} ---"; \
	  scp $(MODULES:=.ko) $(TEST_EXAMPLES) \
	      $(DEVICE_USER)@$(DEVICE_IP):$(DEVICE_MODULES_DIR);


all: modules test_examples



	

