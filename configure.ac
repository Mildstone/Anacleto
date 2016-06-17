dnl Process this file with autoconf to produce a configure script.


dnl AUTOCONF ///////////////////////////////////////////////////////////////////
AC_PREREQ([2.69])
AC_INIT([autoconf-bootstrap], [0.1], [andrea.rgn@gmail.com])
AC_CONFIG_MACRO_DIRS([m4])
AC_CONFIG_AUX_DIR([conf])
dnl AC_CONFIG_SRCDIR([...])

dnl AUTOMAKE ///////////////////////////////////////////////////////////////////
AM_INIT_AUTOMAKE([1.15 foreign subdir-objects])


dnl update submodules at first ... (must be cleaned out)
AS_IF([${srcdir}/conf/update_submodules],
      [AS_ECHO(["Submodules succesfully updated"])],
      [AS_ECHO(["Error updating submodules"])])

dnl AX_KCONFIG /////////////////////////////////////////////////////////////////
dnl see: m4/ax_enable_kconfig.m4
AX_KCONFIG([conf/kconfig])


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
AX_DOCKER_BUILD


AC_CANONICAL_TARGET
AC_CONFIG_HEADERS([config.h])

dnl RELEASE
AX_IS_RELEASE([always])
AX_CHECK_ENABLE_DEBUG([no],,,,[-g -O2])


# Checks for programs.
AC_PROG_AWK
AC_PROG_MKDIR_P
AC_PROG_SED
AC_PROG_CC


# TOOLCHAIN
AS_VAR_SET_IF([TOOLCHAIN_TAR],,AS_VAR_SET([TOOLCHAIN_TAR],[${CONFIG_TOOLCHAIN_TAR}]))
AS_VAR_SET_IF([TOOLCHAIN_PATH],,AS_VAR_SET([TOOLCHAIN_PATH],[${CONFIG_TOOLCHAIN_PATH}]))
AS_VAR_SET_IF([CROSS_COMPILE],,AS_VAR_SET([CROSS_COMPILE],[${CONFIG_CROSS_COMPILE}]))
              
AC_ARG_WITH([toolchain-tar],
            [AS_HELP_STRING([--with-toolchain-tar], [url of the toolchain tar to use])],
            [AS_VAR_SET([TOOLCHAIN_TAR],[${with_toolchain_tar}])])

AC_SUBST([TOOLCHAIN_TAR])
AC_SUBST([TOOLCHAIN_PATH])
AC_SUBST([CROSS_COMPILE])

AS_IF([ test -d toolchain ],,
      [AS_BOX([// Downloading toolchain tar from ${TOOLCHAIN_TAR} //////], [\/])
       ${MKDIR_P} -p toolchain
       curl -SL ${TOOLCHAIN_TAR} | tar -xJv -C toolchain])



AC_CONFIG_FILES( 
                 Makefile
                 src/Makefile
               )
AC_OUTPUT
