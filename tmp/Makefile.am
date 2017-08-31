include $(top_srcdir)/Common.mk

##
##  __   ___       ___       __   __         ___      ___           __   __
## |  \ |__  \  / |__  |    /  \ |__)  |\/| |__  |\ |  |      |\/| /  \ /  ` |__/
## |__/ |___  \/  |___ |___ \__/ |     |  | |___ | \|  |      |  | \__/ \__, |  \
##
##

mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))
project_DEFAULT := $(lastword $(patsubst _, ,$(current_dir)))

@PROJECT_VARIABLES@




project_LISTS = vivado_CORES \
				vivado_PROJECTS

project_VARIABLES = SOURCES \
					IP_SOURCES

FULL_NAME = $(if $(VENDOR),$(VENDOR)_)$(NAME)_$(VERSION)

vivado_CORES    = c1 c2_2.2 rfx_c3 rfx_c4_4.4
vivado_PROJECTS = p1 p2_2.2 rfx_p3 rfx_p4_4.4

vivado_CORES_TARGETS  = test_core
vivado_PROJECTS_TARGETS = test_project prova

p_SOURCES = ciao.c

VENDOR = rfx

prova:
	@ echo $(NAME)

test_core test_project:
	@ echo "name=|$(NAME)| ven=|$(VENDOR)| ver=|$(VERSION)| ful=$(FULL_NAME) sources=$(SOURCES)"



## /// IMPREMENTATION IN M4 ///
#
#
# NAME := $(or $(foreach x,$(project_LISTS),\
#					   $(if $(filter $($x_TARGETS),\
#									 $(MAKECMDGOALS)),\
#									 $(lastword $(value $x)),)),\
#			 $(project_DEFAULT))
#
#
# _flt = $(subst ' ',_,$(subst .,_,$1))
#
# _ven = $(or ${VENDOR},\
#			${$(call _flt,$1)_VENDOR})
#
# _ver = $(or $(filter-out ${PACKAGE_VERSION},${VERSION}),\
#			${$(call _ven,$1)_$(call _flt,$1)_VERSION},\
#			${$(call _flt,$1)_VERSION},\
#			${$(subst $(call _ven,$1)_,,$1)_VERSION},\
#			$(shell echo $(lastword $(subst _, ,$1)) | \
#			  $(SED) 's/[^0-9.]*\([0-9.]*\).*/\1/'),\
#			${VERSION})
#
# _nam = $(subst $(call _ven,$1)_,,$(subst _$(call _ver,$1),,$1))
# _var = $(or $($(call _flt,$(VENDOR)_$(NAME)_$(VERSION)_$1)),\
#			$($(call _flt,$(NAME)_$(VERSION)_$1)),\
#			$($(call _flt,$(VENDOR)_$(NAME)_$1)),\
#			$($(call _flt,$(NAME)_$1)))
#
# $(eval override VERSION :=$(strip $(call _ver,$(NAME))))
# $(eval override VENDOR  :=$(strip $(call _ven,$(NAME))))
# $(eval override NAME    :=$(strip $(call _nam,$(NAME))))
# $(foreach x,$(project_VARIABLES),$(eval override $x:=$(call _var,$x)))
