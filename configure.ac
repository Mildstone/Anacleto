dnl // /////////////////////////////////////////////////////////////////////// //
dnl //
dnl // This file is part of the anacleto project.
dnl // Copyright 2018 Andrea Rigoni Garola <andrea.rigoni@igi.cnr.it>.
dnl //
dnl // This program is free software: you can redistribute it and/or modify
dnl // it under the terms of the GNU General Public License as published by
dnl // the Free Software Foundation, either version 3 of the License, or
dnl // (at your option) any later version.
dnl //
dnl // This program is distributed in the hope that it will be useful,
dnl // but WITHOUT ANY WARRANTY; without even the implied warranty of
dnl // MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
dnl // GNU General Public License for more details.
dnl //
dnl // You should have received a copy of the GNU General Public License
dnl // along with this program.  If not, see <http://www.gnu.org/licenses/>.
dnl //
dnl // ////////////////////////////////////////////////////////////////////// //

dnl Process this file with autoconf to produce a configure script.

dnl AUTOCONF ///////////////////////////////////////////////////////////////////
AC_PREREQ([2.69])
AC_INIT([Anacleto], [0.1], [andrea.rgn@gmail.com])
AC_CONFIG_MACRO_DIRS([conf/m4])
AC_CONFIG_AUX_DIR([conf])
dnl AC_CONFIG_SRCDIR([...])
AC_CANONICAL_TARGET

dnl AX_ANACLETO_BANNER

dnl update submodules at first ... (must be cleaned out)
AS_IF([${srcdir}/conf/update_submodules.sh],
	  [AS_ECHO(["Submodules succesfully updated"])],
	  [AS_ECHO(["Error updating submodules"])])


dnl AX_KCONFIG /////////////////////////////////////////////////////////////////
dnl see: m4/ax_enable_kconfig.m4
AS_VAR_SET([srcdir],[$(cd ${srcdir}; pwd)])
AS_VAR_SET([builddir],[$(pwd)])
AX_KCONFIG([conf/kconfig])

dnl AX_TARGET_SELFHELP /////////////////////////////////////////////////////////
AX_TARGET_SELFHELP

# //////////////////////////////////////////////////////////////////////////// #
# //  DOCKER BUILD /////////////////////////////////////////////////////////// #
# //////////////////////////////////////////////////////////////////////////// #

m4_sinclude(conf/kscripts/docker.ac)
AX_DOCKER_BUILD


dnl AUTOMAKE ///////////////////////////////////////////////////////////////////
AM_INIT_AUTOMAKE([no-define foreign subdir-objects])
dnl ([1.14 foreign subdir-objects])


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
# AC_PROG_RANLIB
AC_PROG_LN_S

AC_CHECK_PROGS([CURL],[curl])
AC_CHECK_PROGS([TAR],[gtar tar])
AC_CHECK_PROGS([UNIQ],[uniq])
AC_CHECK_PROGS([WC],[wc])

AC_PROG_LEX
AC_PROG_YACC

# needed for sh_envsubst
AC_CHECK_PROGS([PERL],[perl])

# needed to scan all subdirectories files timestamp for make deps
AC_CHECK_PROGS([FIND],[find])
AC_SUBST([FIND])

## LIBTOOL
dnl LT_INIT()

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

## EXT_NODEJS_NODE ##
m4_sinclude(conf/kscripts/ext_nodejs_node.ac)

## EXT_MDSPLUS ##
m4_sinclude(conf/kscripts/ext_mdsplus.ac)

## EXT ##
AX_KCONFIG_MODULES([EXT],
		  [libjit],[libjit external sources],
		  [llvm],[llvm external sources],
		  [ccStickers],[ccStickers external sources],
		  [mdsplus],[mdsplus external sources]
		  )
AC_SUBST([EXT_MODULES])

## YOCTO ##
m4_sinclude(conf/kscripts/yocto.ac)

## LINUX ##
m4_sinclude(conf/kscripts/linux.ac)


# COMPILER OPTIONS
AX_KCONFIG_VAR([LINUX_CFLAGS])
AX_KCONFIG_VAR([LINUX_PACKAGE])
AX_KCONFIG_VAR([LINUX_DIR])
AC_SUBST([LINUX_CFLAGS])
AC_SUBST([LINUX_PACKAGE])
AC_SUBST([LINUX_DIR])


# //////////////////////////////////////////////////////////////////////////// #
# //  TARGET  //////////////////////////////////////////////////////////////// #
# //////////////////////////////////////////////////////////////////////////// #


# DEVICE
AX_KCONFIG_VAR([DEVICE_NAME])
AC_SUBST([DEVICE_NAME])
AX_KCONFIG_VAR([DEVICE_IP])
AC_SUBST([DEVICE_IP])
AX_KCONFIG_VAR([DEVICE_MODULES_DIR])
AC_SUBST([DEVICE_MODULES_DIR])
AX_KCONFIG_VAR([DEVICE_BOOT_DIR])
AC_SUBST([DEVICE_BOOT_DIR])

# SSH to deploy
AX_KCONFIG_VAR([DEVICE_ACCESS])
AX_KCONFIG_VAR([DEVICE_USER])
AC_CHECK_PROG([SSHPASS],sshpass,sshpass)
AX_KCONFIG_VAR([WITH_DEVICE_SSHPASSWD])
AM_CONDITIONAL([WITH_DEVICE_SSHPASSWD],
		   [test -n "${WITH_DEVICE_SSHPASSWD}" -a -n "${SSHPASS}"] )
AX_KCONFIG_VAR([WITH_DEVICE_SSHKEY])
AM_CONDITIONAL([WITH_DEVICE_SSHKEY], [test -n "${WITH_DEVICE_SSHKEY}"])
AX_KCONFIG_VAR([DEVICE_PASSWD])
AX_KCONFIG_VAR([DEVICE_SSHKEY])
AC_SUBST([DEVICE_ACCESS])
AC_SUBST([DEVICE_USER])
AC_SUBST([DEVICE_PASSWD])
AC_SUBST([DEVICE_SSHKEY])



# //////////////////////////////////////////////////////////////////////////// #
# //  YOCTO  ///////////////////////////////////////////////////////////////// #
# //////////////////////////////////////////////////////////////////////////// #

AX_KCONFIG_CONDITIONAL([ENABLE_YOCTO])
AX_KCONFIG_CONDITIONAL([WITH_YOCTO_GIT])
AX_KCONFIG_CONDITIONAL([WITH_YOCTO_TAR])

AX_KCONFIG_VAR([YOCTO_DIR])
AC_SUBST([YOCTO_DIR])
AS_VAR_IF([ENABLE_YOCTO],[yes],[AX_GITIGNORE_ADD([/${YOCTO_DIR}])])


AX_KCONFIG_VAR([YOCTO_VERSION])
AC_SUBST([YOCTO_VERSION])

AX_KCONFIG_VAR([YOCTO_GIT])
AC_SUBST([YOCTO_GIT])
AX_KCONFIG_VAR([YOCTO_TAR])
AC_SUBST([YOCTO_TAR])
AX_KCONFIG_VAR([YOCTO_VERSION])
AC_SUBST([YOCTO_VERSION])

# Yocto meta-xilinx support
AX_KCONFIG_CONDITIONAL([ENABLE_YOCTO_XILINX])
AX_KCONFIG_CONDITIONAL([WITH_YOCTO_XILINX_GIT])
AX_KCONFIG_CONDITIONAL([WITH_YOCTO_XILINX_TAR])
AX_KCONFIG_VAR([YOCTO_XILINX_GIT])
AC_SUBST([YOCTO_XILINX_GIT])
AX_KCONFIG_VAR([YOCTO_XILINX_TAR])
AC_SUBST([YOCTO_XILINX_TAR])



# // GIT IGNORE // #
AX_GITIGNORE_SUBST


dnl forward declaration for fpga configure.ac
AX_COMPARE_VERSION([],[eq],[])

AX_PROJECT_VARIABLES

# // include configure.ac in subdirectories // #
AX_CONFIG_SUBDIRS(
		fpga
		fpga/lib/rfx
		projects
)

AX_CONFIG_FILES(
		 Makefile
		 .gitignore
		 )

AC_OUTPUT

