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
AC_PROG_SED
AC_PROG_CC

AC_CHECK_PROGS([CURL],[curl])
AC_CHECK_PROGS([TAR],[gtar tar])
AC_CHECK_PROGS([UNIQ],[uniq])
AC_CHECK_PROGS([WC],[wc])


# //////////////////////////////////////////////////////////////////////////// #
# //  BUILD COMMON  ////////////////////////////////////////////////////////// #
# //////////////////////////////////////////////////////////////////////////// #

AX_KCONFIG_VAR_WITH([DOWNLOAD_DIR],["Default download directory path"])
AC_SUBST([DOWNLOAD_DIR])
AX_GITIGNORE_ADD([${DOWNLOAD_DIR}])

AX_KCONFIG_VAR_WITH([MAKE_PROCESS],
		    ["Number of parallel process (aka -j option, 0=auto)"])
AS_VAR_IF([MAKE_PROCESS],[0],
	  [AS_VAR_SET([MAKE_PROCESS],[$(grep -c ^processor /proc/cpuinfo)])])
AC_MSG_NOTICE([build make process -j${MAKE_PROCESS}])
AC_SUBST([MAKE_PROCESS])


# //////////////////////////////////////////////////////////////////////////// #
# //  TOOLCHAIN  ///////////////////////////////////////////////////////////// #
# //////////////////////////////////////////////////////////////////////////// #

AX_KCONFIG_VAR_ENABLE([ENABLE_CUSTOM_TOOLCHAIN],["Enable external toolchain"])

AX_KCONFIG_CHOICE([TOOLCHAIN_RETRIEVE],
		  [TOOLCHAIN_RETRIEVE_TAR],["tar"],
		  [TOOLCHAIN_RETRIEVE_DIR],["dir"])

AX_KCONFIG_VAR_WITH([TOOLCHAIN_TAR],["url path for Linaro toolchain binaries"])
AC_SUBST([TOOLCHAIN_TAR])

AX_KCONFIG_VAR_WITH([TOOLCHAIN_DIR],["Set toolchain base dir"])
AC_SUBST([TOOLCHAIN_DIR])
AX_GITIGNORE_ADD([${TOOLCHAIN_DIR}])

AX_KCONFIG_VAR_WITH([CROSS_COMPILE],["Set crosscompile command"])
AC_SUBST([CROSS_COMPILE])


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




# // GIT IGNORE // #
AX_GITIGNORE_SUBST

AC_CONFIG_FILES( 
                 Makefile
		 .gitignore
               )
AC_OUTPUT
