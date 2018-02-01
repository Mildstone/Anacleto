include $(top_srcdir)/Common.mk
# include $(top_srcdir)/conf/kscripts/ext_ccStickers.mk
# include $(top_srcdir)/conf/kscripts/ext_libjit.mk
# include $(top_srcdir)/conf/kscripts/ext_llvm.mk


define _ext_bootstrap
$(eval
$1/configure: $1
	@ cd $1; ./bootstrap
)
endef

define _ext_configure
$(eval
$1/config.log: $1/configure
	@ cd $1; ./configure $($1_CFGARGS)
$1/Makefile: $1/config.log
	@ $(MAKE) $(AM_MAKEFLAGS) -C $1 Makefile
)
endef


ext-: ##@ext enter ext module with $TARGET
ext-%: %/Makefile
	@ $(MAKE) $(AM_MAKEFLAGS) -C $(subst ext-,,$@) $(TARGET)

all: TARGET = all
all: ext-libjit

clean: TARGET = clean
clean: ext-libjit



# /////////////////////////////////////////////////////////////////////////// //
# //  EXT MODULES  ////////////////////////////////////////////////////////// //
# /////////////////////////////////////////////////////////////////////////// //

DOWNLOADS  = $(EXT_MODULES)

ccStickers: ##@ext download ccStickers sources
ccStickers_URL = $(ccStickers_URL)
$(call _ext_bootstrap,ccStickers)
$(call _ext_configure,ccStickers)

libjit: ##@ext download libjit sources
libjit_URL = $(LIBJIT_URL)
$(call _ext_bootstrap,libjit)
$(call _ext_configure,libjit)

llvm:   ##@ext download llvm sources
llvm_URL   = $(LLVM_URL)




