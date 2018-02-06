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




# AX_DOWNLOAD_TAR([URL],[DEST_DIR],[DL_TMP])
# ----------------
AC_DEFUN([AX_DOWNLOAD_TAR],[
  m4_pushdef([_tmp],[m4_default($3,tmp})])
  m4_pushdef([_url],$1)
  AC_PROG_MKDIR_P
  AC_PROG_SED
  AC_CHECK_PROGS([CURL],[curl])
  AC_CHECK_PROGS([TAR],[gtar tar])
  AC_CHECK_PROGS([UNIQ],[uniq])
  AC_CHECK_PROGS([WC],[wc])
  $MKDIR_P _tmp
  $MKDIR_P $2
  AS_VAR_SET([_tar],_tmp[]/$(echo _url | sed -e "s|.*/||"))
  AS_ECHO("Downloading $_tar from $1")
  AS_IF([test -f $_tar],,[$CURL -SL _url > $_tar])
  AS_IF([test $($TAR -tzf $_tar | $SED -e "s|/.*||" | $UNIQ | $WC -l) = 1],
	[$TAR -xzf $_tar -C $2 --strip 1],
	[$TAR -xzf $_tar -C $2])
  m4_popdef([_url])
  m4_popdef([_tmp])
])
