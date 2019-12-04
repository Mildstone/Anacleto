include $(top_srcdir)/Common.mk
if ENABLE_DOXYGEN
include $(top_srcdir)/conf/autoconf-doxygen/doxygen.mk

DX_TITLE  ?= Autoconf bootstrap
DX_BRIEF  ?= project code documentation reference

DX_PACKAGE_NAME = bootstrap
DX_INPUT = main_page.md

all: html pdf
else
HELP_DESCRIPTION = WARNING! doxygen targets not enabled by config, targets may be missing
endif
