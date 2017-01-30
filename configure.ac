dnl Process this file with autoconf to produce a configure script.

dnl AUTOCONF ///////////////////////////////////////////////////////////////////
AC_PREREQ([2.69])
AC_INIT([autoconf-bootstrap], [0.1], [andrea.rgn@gmail.com])
AC_CONFIG_MACRO_DIRS([m4])
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

dnl AX_DOCKER_BUILD ////////////////////////////////////////////////////////////
dnl see: m4_ax_docker_build.m4
dnl /// Kconfig docker variables import example ...
AS_VAR_IF([CONFIG_ENABLE_DOCKER],[y],[
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

AC_CONFIG_HEADERS([config.h])

dnl RELEASE
AX_IS_RELEASE([always])
AX_CHECK_ENABLE_DEBUG([no],,,,[-g -O2])


# Checks for programs.
AC_PROG_AWK
AC_PROG_MKDIR_P
AC_PROG_SED
AC_PROG_CC

AC_CHECK_PROGS([CURL],[curl])
AC_CHECK_PROGS([TAR],[gtar tar])
AC_CHECK_PROGS([UNIQ],[uniq])
AC_CHECK_PROGS([WC],[wc])



# //////////////////////////////////////////////////////////////////////////// #
# //  TOOLCHAIN  ///////////////////////////////////////////////////////////// #
# //////////////////////////////////////////////////////////////////////////// #


AX_KCONFIG_VAR_ENABLE([ENABLE_TOOLCHAIN],["Enable external toolchain"])
AX_KCONFIG_CHOICE([TOOLCHAIN_VENDOR],
		  [TOOLCHAIN_LINARO_BIN],["linaro_web"],
		  [TOOLCHAIN_DIR],["dir"])

AS_ECHO(["linaro bin: ${TOOLCHAIN_LINARO_BIN}"])

AX_KCONFIG_VAR_WITH([LINARO_BIN_TAR],["url path for Linaro toolchain binaries"])
AC_SUBST([LINARO_BIN_TAR])

AX_KCONFIG_VAR_WITH([WITH_TOOLCHAIN_DIR],["Set toolchain base dir"])
AC_SUBST([WITH_TOOLCHAIN_DIR])

AX_KCONFIG_VAR_WITH([CROSS_COMPILE],["Toolchain prefix of build executables"])
AC_SUBST([CROSS_COMPILE])

# COMPILER OPTIONS
AX_KCONFIG_VAR([LINUX_CFLAGS])
AX_KCONFIG_VAR([LINUX_PACKAGE])
AX_KCONFIG_VAR([LINUX_DIR])
AC_SUBST([LINUX_CFLAGS])
AC_SUBST([LINUX_PACKAGE])
AC_SUBST([LINUX_DIR])




# // GIT IGNORE // #
AX_GITIGNORE_SUBST

AC_CONFIG_FILES( 
                 Makefile
		 .gitignore
               )
AC_OUTPUT
