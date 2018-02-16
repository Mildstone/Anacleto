include $(top_srcdir)/Common.mk


DOWNLOADS = XilinxTclStore

XilinxTclStore_URL    ?= https://github.com/Xilinx/XilinxTclStore.git
XilinxTclStore_BRANCH ?= master


XilinxTclStore/tclapp/socdev: socdev XilinxTclStore
	@ $(info socdev dir: $<)
	  mkdir -p $(dir $@) && ln -sr $< $@


all: XilinxTclStore/tclapp/socdev
