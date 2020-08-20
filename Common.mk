## ////////////////////////////////////////////////////////////////////////// //
##
## This file is part of the autoconf-bootstrap project.
## Copyright 2018 Andrea Rigoni Garola <andrea.rigoni@igi.cnr.it>.
##
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.
##
## ////////////////////////////////////////////////////////////////////////// //

include $(top_srcdir)/conf/kscripts/build_common.mk
include $(top_srcdir)/conf/kscripts/toolchain.mk
include $(top_srcdir)/conf/kscripts/docker.mk


## ////////////////////////////////////////////////////////////////////////// ##
## /// ACTIVATE HELP TARGET ///////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

@TARGET_SELFHELP@

help: print_banner
print_banner:
	@ cat $(top_srcdir)/doc/logo.txt

## /////////////////////////////////////////////////////////////////////////////
## // DIRECTORIES //////////////////////////////////////////////////////////////
## /////////////////////////////////////////////////////////////////////////////

DL   ?= $(DOWNLOAD_DIR)
TMP  ?= $(abs_top_builddir)

${DL} ${TMP}:
	@$(MKDIR_P) $@

## /////////////////////////////////////////////////////////////////////////////
## // DOCKER  //////////////////////////////////////////////////////////////////
## /////////////////////////////////////////////////////////////////////////////

locale-gen: USER = root
locale-gen: ##@@docker set locale in the docker container instance
	@ locale-gen $${LANG}

ip-address: NIC    = eth0
ip-address: HOSTID = 02:42:ac:11:00:aa
ip-address: USER   = root
ip-address: ##@@docker set MAC address in the docker container instance
	@ ip link set $(NIC) address $(HOSTID)


NODOCKERBUILD += edit-code
NODOCKERBUILD += edit-code-server

## /////////////////////////////////////////////////////////////////////////////
## // RECONFIGURE  /////////////////////////////////////////////////////////////
## /////////////////////////////////////////////////////////////////////////////

.PHONY: reconfigure
reconfigure: ##@miscellaneous re-run configure with last passed arguments
	@ \
	echo " -- Reconfiguring build with following parameters: -----------"; \
	echo $(shell $(abs_top_builddir)/config.status --config);              \
	echo " -------------------------------------------------------------"; \
	echo ; \
	cd '$(abs_top_builddir)' && \
	$(abs_top_srcdir)/configure $(shell $(abs_top_builddir)/config.status --config);


NODOCKERBUILD += am__configure_deps \
		 edit-code



