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



dnl Process this file with autoconf to produce a configure script.

dnl AUTOCONF ///////////////////////////////////////////////////////////////////
AC_PREREQ([2.69])
AC_INIT([autoconf-bootstrap], [0.1], [andrea.rgn@gmail.com])
AC_CONFIG_MACRO_DIRS([conf/m4])
AC_CONFIG_AUX_DIR([conf])
dnl AC_CONFIG_SRCDIR([...])
AC_CANONICAL_TARGET

dnl AUTOMAKE ///////////////////////////////////////////////////////////////////
AM_INIT_AUTOMAKE([1.14 foreign subdir-objects])


dnl update submodules at first ... (must be cleaned out)
AS_IF([${srcdir}/conf/update_submodules.sh],
      [AS_ECHO(["Submodules succesfully updated"])],
      [AS_ECHO(["Error updating submodules"])])


dnl AX_KCONFIG /////////////////////////////////////////////////////////////////
dnl see: m4/ax_enable_kconfig.m4
AS_VAR_SET([srcdir],[${srcdir}])
AS_VAR_SET([builddir],[$(pwd)])
AX_KCONFIG([conf/kconfig])

dnl AX_TARGET_SELFHELP /////////////////////////////////////////////////////////
AX_TARGET_SELFHELP

# //////////////////////////////////////////////////////////////////////////// #
# //  DOCKER BUILD /////////////////////////////////////////////////////////// #
# //////////////////////////////////////////////////////////////////////////// #

AS_VAR_IF([CONFIG_ENABLE_DOCKER_BUILD],[y],[
           AS_VAR_SET_IF([CONFIG_DOCKER_CONTAINER], 
              [AS_VAR_SET([DOCKER_CONTAINER],[${CONFIG_DOCKER_CONTAINER}])] )
           AS_VAR_SET_IF([CONFIG_DOCKER_IMAGE], 
              [AS_VAR_SET([DOCKER_IMAGE],[${CONFIG_DOCKER_IMAGE}])] )
           AS_VAR_SET_IF([CONFIG_DOCKER_URL], 
              [AS_VAR_SET([DOCKER_URL],[${CONFIG_DOCKER_URL}])])
          ])

AX_KCONFIG_VAR([DOCKER_SHARES])
AC_SUBST([DOCKER_SHARES])
AX_DOCKER_BUILD

# //////////////////////////////////////////////////////////////////////////// #

AC_CONFIG_HEADERS([config.h])

dnl RELEASE
AX_IS_RELEASE([always])
AX_CHECK_ENABLE_DEBUG([no],,,,[-g -O2])

# Checks for programs.
AC_PROG_AWK
AC_PROG_MKDIR_P
AC_PROG_LN_S
AC_PROG_SED
AC_PROG_CC
AC_PROG_CXX

AC_CHECK_PROGS([CURL],[curl])
AC_CHECK_PROGS([TAR],[gtar tar])
AC_CHECK_PROGS([UNIQ],[uniq])
AC_CHECK_PROGS([WC],[wc])

AC_PROG_LEX
AC_PROG_YACC


# needed for sh_envsubst
AC_CHECK_PROGS([PERL],[perl])

## LIBTOOL
LT_INIT()

## /////////////////////////////////////////////////////////////////////////////
## //  KSCRIPTS  ///////////////////////////////////////////////////////////////
## /////////////////////////////////////////////////////////////////////////////

## BUILD_COMMON ##
m4_sinclude(conf/kscripts/build_common.ac)

## TOOLCHAIN ##
m4_sinclude(conf/kscripts/toolchain.ac)

## CODAC ##
# m4_sinclude(conf/kscripts/iter_codac.ac)

## QT ##
m4_sinclude(conf/kscripts/qtdesktop.ac)

## NODEJS ##
m4_sinclude(conf/kscripts/nodejs.ac)

## DOXYGEN ##
m4_sinclude(conf/autoconf-doxygen/doxygen.ac)

## EXT_LIBJIT ##
m4_sinclude(conf/kscripts/ext_libjit.ac)

## EXT_LLVM ##
m4_sinclude(conf/kscripts/ext_llvm.ac)

## EXT_CCSTICKERS ##
m4_sinclude(conf/kscripts/ext_ccStickers.ac)

## EXT ##
AX_KCONFIG_MODULES([EXT],
		  [libjit],[libjit external sources],
		  [llvm],[llvm external sources],
		  [ccStickers],[ccStickers external sources]
		  )
AC_SUBST([EXT_MODULES])

## YOCTO ##
m4_sinclude(conf/kscripts/yocto.ac)

## // GIT IGNORE // ##
AX_GITIGNORE_ADD_PATH([${builddir}])
AX_GITIGNORE_SUBST


# //////////////////////////////////////////////////////////////////////////// #
# //  EXAMPLES /////////////////////////////////////////////////////////////// #
# //////////////////////////////////////////////////////////////////////////// #

AX_KCONFIG_VAR_ENABLE([EXAMPLE_BOOL_VAR],["Set example bool var"])
AC_SUBST([EXAMPLE_BOOL_VAR])

AX_KCONFIG_VAR_WITH([EXAMPLE_STRING_VAR],["Set example string var"])
AC_SUBST([EXAMPLE_STRING_VAR])

AX_KCONFIG_MODULES([MDS],[java],[])
AX_KCONFIG_MODULES([MDS],[lv],[labview],
			 [ni],[national instruments components])
AC_SUBST(MDS_JAVA)
AC_SUBST(MDS_LV)
AC_SUBST(MDS_NI)
AC_SUBST(MDS_MODULES)


AX_KCONFIG_MODULES([],[mod1],[],
		      [mod2],[],
		      [mod3],[])
AC_SUBST(MOD1)
AC_SUBST(MOD2)
AC_SUBST(MOD3)
AC_SUBST(MODULES)


AS_ECHO()
AS_BOX([// EXAMPLES CONFIG VARIABLES //////], [\/])
AS_ECHO()
AS_ECHO(["EXAMPLE_BOOL_VAR --------> $EXAMPLE_BOOL_VAR"])
AS_ECHO(["EXAMPLE_STRING_VAR ------> $EXAMPLE_STRING_VAR"])
AS_ECHO()
AS_ECHO(["MDS_MODULES_AVAILABLE ---> ${MDS_MODULES_AVAILABLE}"])
AS_ECHO(["MDS_MODULES_ENABLED -----> ${MDS_MODULES_ENABLED}"])
AS_ECHO(["MDS_MODULES_DISABLED ----> ${MDS_MODULES_DISABLED}"])
AS_ECHO(["MDS_MODULES -------------> ${MDS_MODULES}"])
AS_ECHO()
AS_ECHO(["MODULES_AVAILABLE -------> ${MODULES_AVAILABLE}"])
AS_ECHO(["MODULES_ENABLED ---------> ${MODULES_ENABLED}"])
AS_ECHO(["MODULES_DISABLED --------> ${MODULES_DISABLED}"])
AS_ECHO(["MODULES -----------------> ${MODULES}"])
AS_ECHO()
AS_ECHO(["ENABLE_DOXYGEN ------------------> ${ENABLE_DOXYGEN}"])
AS_ECHO(["DOXYGEN_MODULES_AVAILABLE -------> ${DOXYGEN_MODULES_AVAILABLE}"])
AS_ECHO(["DOXYGEN_MODULES_ENABLED ---------> ${DOXYGEN_MODULES_ENABLED}"])
AS_ECHO(["DOXYGEN_MODULES_DISABLED --------> ${DOXYGEN_MODULES_DISABLED}"])
AS_ECHO(["DOXYGEN_MODULES -----------------> ${DOXYGEN_MODULES}"])
AS_ECHO()



AC_CONFIG_FILES( 
                 Makefile
				 .gitignore
				 src/Makefile
				 src/qt_example/Makefile
				 src/sh_template/Makefile
dnl				 src/libjit_examples/Makefile
				 src/parse_examples/Makefile
				 src/nodejs/Makefile
				 doc/Makefile
				 doc/wiki/Makefile
				 ext/Makefile
               )
AC_OUTPUT
