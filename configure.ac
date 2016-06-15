dnl Process this file with autoconf to produce a configure script.

AC_PREREQ([2.69])
AC_INIT([autoconf-bootstrap], [0.1], [andrea.rgn@gmail.com])
AC_CONFIG_MACRO_DIRS([m4])
AC_CONFIG_AUX_DIR([conf])
dnl AC_CONFIG_SRCDIR([include/mdsdescrip.h])

AX_DOCKER_BUILD

AC_CANONICAL_TARGET
AM_INIT_AUTOMAKE([1.15 foreign subdir-objects])

AC_CONFIG_HEADERS([config.h])

dnl RELEASE
AX_IS_RELEASE([always])
AX_CHECK_ENABLE_DEBUG([no],,,,[-g -O2])


# Checks for programs.
AC_PROG_AWK
AC_PROG_MKDIR_P
AC_PROG_SED
AC_PROG_CC


# update submodules ( uncomment if needed )
# pushd ${srcdir}; source ./conf/update_submodules.sh; popd






AC_CONFIG_FILES( 
                 Makefile
                 src/Makefile
               )
AC_OUTPUT
