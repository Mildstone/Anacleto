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
AX_KCONFIG_VAR([TOOLCHAIN_TAR])
AX_KCONFIG_VAR([TOOLCHAIN_PATH])
AX_KCONFIG_VAR([CROSS_COMPILE])

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



# COMPILER OPTIONS
AX_KCONFIG_VAR([LINUX_CFLAGS])
AX_KCONFIG_VAR([LINUX_IMAGE])
AX_KCONFIG_VAR([LINUX_DIR])
AC_SUBST([LINUX_CFLAGS])
AC_SUBST([LINUX_IMAGE])
AC_SUBST([LINUX_DIR])


# DEVICE
AX_KCONFIG_VAR([DEVICE_NAME])
AX_KCONFIG_VAR([DEVICE_IP])
AX_KCONFIG_VAR([DEVICE_ACCESS])
AX_KCONFIG_VAR([DEVICE_USER])
dnl AX_KCONFIG_VAR([DEVICE_PASSWD])
AX_KCONFIG_VAR([DEVICE_MODULES_DIR])
AC_SUBST([DEVICE_NAME])
AC_SUBST([DEVICE_IP])
AC_SUBST([DEVICE_ACCESS])
AC_SUBST([DEVICE_USER])
dnl AC_SUBST([DEVICE_PASSWD])
AC_SUBST([DEVICE_MODULES_DIR])



AC_CONFIG_FILES( 
                 Makefile
                 src/Makefile
                 src/Kbuild
               )
AC_OUTPUT
