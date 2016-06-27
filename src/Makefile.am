
include ../Common.am

# Main GCC executable (used for compiling and linking)

.PHONY: modules
modules: axidma_example0.c axidma_example1.c axidma_example2.c axidma_example3.c Kbuild
	@ echo " --- building modules ---"; \
	  export PATH="$${PATH}:${TOOLCHAIN_PATH}"; \
	  $(MAKE) $(AM_MAKEFLAGS) -C ${LINUX_DIR} \
	       ARCH=arm CFLAGS="$(LINUX_CFLAGS)" \
	       -j $(MAKE_PROCESS) CROSS_COMPILE=${CROSS_COMPILE} \
	       M=`pwd` O=$(abs_top_builddir)/linux-xlnx \
	       srcdir=$(srcdir) builddir=$(builddir) modules

clean-local:
	@ echo " --- building modules ---"; \
	export PATH="$${PATH}:${TOOLCHAIN_PATH}"; \
	$(MAKE) $(AM_MAKEFLAGS) -C ${LINUX_DIR} \
	     ARCH=arm CFLAGS="$(LINUX_CFLAGS)" \
	     -j $(MAKE_PROCESS) CROSS_COMPILE=${CROSS_COMPILE} \
	     M=`pwd` O=$(abs_top_builddir)/linux-xlnx \
	     srcdir=$(srcdir) builddir=$(builddir) clean


test_example2: test_example2.c
	@ echo " --- building example2 ---"; \
	export PATH="$${PATH}:${TOOLCHAIN_PATH}"; \
	${CROSS_COMPILE}${CC} $(LINUX_CFLAGS) $^ -o $@
	

test_example3: test_example3.c
	@ echo " --- building example3 ---"; \
	export PATH="$${PATH}:${TOOLCHAIN_PATH}"; \
	${CROSS_COMPILE}${CC} $(LINUX_CFLAGS) $^ -o $@


.PHONY: deploy
deploy: modules test_example2 test_example3
	@ echo " --- deploying modules to target device: ${DEVICE_NAME} ---"; \
	  scp axidma_example0.ko axidma_example1.ko axidma_example2.ko \
	   axidma_example3.ko  test_example2 test_example3 \
	   $(DEVICE_USER)@$(DEVICE_IP):$(DEVICE_MODULES_DIR);


all: modules



	

