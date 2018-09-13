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

## /////////////////////////////////////////////////////////////////////////////
## // DIRECTORIES //////////////////////////////////////////////////////////////
## /////////////////////////////////////////////////////////////////////////////

DL   ?= $(DOWNLOAD_DIR)
TMP  ?= $(abs_top_builddir)

${DL} ${TMP}:
	@$(MKDIR_P) $@


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




