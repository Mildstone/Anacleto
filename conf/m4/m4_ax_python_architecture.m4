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



AC_DEFUN([AX_PYTHON_ARCH], [
    AX_PYTHON_MODULE([platform], [required], [${PYTHON}])
    AC_MSG_CHECKING([for python architecture])
    AS_VAR_SET([_python_arch],
               [`${PYTHON} -c "import sys, platform; sys.stdout.write(platform.architecture()[[0]])"`])
    
    AS_VAR_IF([_python_arch],[64bit],[
               ${PYTHON} -c "import sys; sys.exit(sys.maxsize <= 2**32)"
               AS_IF([test $? -eq 0],[],[
               AS_VAR_SET([_python_arch],[32bit])])
              ])
     
    AC_MSG_RESULT([${_python_arch}])
    AS_VAR_SET([$1],[${_python_arch}])
])
