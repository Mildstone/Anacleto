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

include Common.mk
include $(top_srcdir)/conf/kscripts/yocto.mk


AM_MAKEFLAGS = -j$(MAKE_PROCESS)
ACLOCAL_AMFLAGS = -I conf/m4

SUBDIRS = ext src

all: ##@all all target
all:

clean-local:

MOSTLYCLEANFILES =


hello.log: ##@log write hello.log file
hello.log:
	@ echo "hello bootstrap" > $@


print-hello: EXAMPLE_STRING_VAR = not set
print-hello:
	@ echo "this is the var: $(EXAMPLE_STRING_VAR)"
