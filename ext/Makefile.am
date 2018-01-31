include $(top_srcdir)/Common.mk
include $(top_srcdir)/conf/kscripts/ext_libjit.mk

DOWNLOADS  = $(EXT_MODULES)

libjit: ##@ext download libjit sources
libjit_URL = $(LIBJIT_URL)

llvm:   ##@ext download llvm sources
llvm_URL   = $(LLVM_URL)

libjit/config.log: libjit
	@ cd libjit; ./bootstrap && ./configure $(LIBJIT_CFGARGS)

libjit/Makefile: libjit/config.log
	@ $(MAKE) $(AM_MAKEFLAGS) -C libjit Makefile

ext-: ##@ext enter ext module with $TARGET
ext-%: %/Makefile
	@ $(MAKE) $(AM_MAKEFLAGS) -C $(subst ext-,,$@) $(TARGET)


all: TARGET = all
all: ext-libjit

clean: TARGET = clean
clean: ext-libjit



