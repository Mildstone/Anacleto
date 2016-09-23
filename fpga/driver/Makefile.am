# Main GCC executable (used for compiling and linking)

include $(top_srcdir)/Common.am
# include ${abs_top_srcdir}/fpga/driver/Kbuild

obj = $(builddir)
src = $(srcdir)

#KBUILD_MAKEFILE = ${srcdir}/Kbuild

modules: axidmatest_core.c axidma_golden.c rfx-axidma.c Kbuild
	-cp $^ $(srcdir)/rfx-axidma.h .
	make $(AM_MAKEFLAGS) -C ${LINUX_DIR} ARCH=arm CFLAGS=$(LINUX_CFLAGS) -j $(MAKE_PROCESS) \
	PATH="$${PATH}:${TOOLCHAIN_DIR}" CROSS_COMPILE=${CROSS_COMPILE} \
	M=`pwd` VPATH=$(abs_srcdir) modules
#	$(MAKE) -f ${KBUILD_MAKEFILE} KERNELDIR=${LINUX_DIR} \
#	EXTRA_CFLAGS="$(EXTRA_CFLAGS) $(DEFS) $(DEFAULT_INCLUDES)" RT=${RT} \
#	ARCH=arm CFLAGS=$(LINUX_CFLAGS) \
#	PATH="$${PATH}:${TOOLCHAIN_DIR}" CROSS_COMPILE=${CROSS_COMPILE} \
#	M=`pwd` VPATH=$(abs_srcdir) modules

all: modules

clean:
	rm  -f Kbuild          axidma_golden.c      axidma_golden.mod.o  \
	    axidmatest.mod.c  axidmatest_core.c  dtbtrybind.mod.c  \
	    dtbtrybind_core.c  modules.order rfx-axidma.c rfx-axidma.h \
	 axidma_golden.ko     axidma_golden.o      axidmatest.mod.o  \
	 axidmatest_core.o  dtbtrybind.mod.o  dtbtrybind_core.o \
	 Module.symvers  axidma_golden.mod.c  axidmatest.ko        \
	 axidmatest.o      dtbtrybind.ko      dtbtrybind.o \
	 prova  prova.o  rfx-axidma.ko  rfx-axidma.mod.c  rfx-axidma.mod.o  rfx-axidma.o
	 
