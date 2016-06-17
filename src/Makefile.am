
include ../Common.am

# Main GCC executable (used for compiling and linking)

obj = $(builddir)
src = $(srcdir)


modules: axidma_example1.c Kbuild
#	- cp $^ .; \
	  export PATH="$${PATH}:${TOOLCHAIN_PATH}"; \
	  make $(AM_MAKEFLAGS) -C ${LINUX_DIR} ARCH=arm CFLAGS=$(LINUX_CFLAGS) \
	       -j $(MAKE_PROCESS) CROSS_COMPILE=${CROSS_COMPILE} \
	       M=$(srcdir) O=`pwd` VPATH=$(abs_srcdir) modules

all: modules

# FIX !
clean:
	rm  -f  \
	Kbuild  \
	axidma_example1.mod.c  axidma_example1.o  Module.symvers \
	axidma_example1.ko  axidma_example1.mod.o modules.order
	

	 
