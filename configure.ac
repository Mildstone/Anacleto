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

dnl AS_IF([test -f ${WITH_TOOLCHAIN_DIR}/${WITH_CROSS_COMPILE}${CC} ],,
dnl      [AS_VAR_IF([TOOLCHAIN_VENDOR],[linaro_web],
dnl	  [AS_BOX([// Downloading toolchain tar from ${WITH_LINARO_BIN_TAR} //////], [\/])
dnl	   ${MKDIR_P} -p toolchain
dnl	   ${CURL} -SL ${WITH_LINARO_BIN_TAR} | ${TAR} -xJv -C toolchain])])

dnl # AC_LANG(C)
dnl # ----------
dnl # CFLAGS is not in ac_cpp because -g, -O, etc. are not valid cpp options.
dnl # AC_LANG_DEFINE(NAME, ABBREV, PREFIX, COMPILER-VAR, COPY-FROM, SHELL-VARS)
dnl AC_LANG_DEFINE([XC], [c], [XC], [XCC], [],
dnl [
dnl ac_ext=c
dnl ac_cpp='$CPP $CPPFLAGS'
dnl ac_compile='$CC -c $CFLAGS $CPPFLAGS conftest.$ac_ext >&AS_MESSAGE_LOG_FD'
dnl ac_link='$CC -o conftest$ac_exeext $CFLAGS $CPPFLAGS $LDFLAGS conftest.$ac_ext $LIBS >&AS_MESSAGE_LOG_FD'
dnl ac_compiler_gnu=$ac_cv_c_compiler_gnu
dnl ])



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
# //  FPGA  ////////////////////////////////////////////////////////////////// #
# //////////////////////////////////////////////////////////////////////////// #


dnl AX_KCONFIG_CONDITIONAL([VIVADO_VERSION_2015_4])
dnl AX_KCONFIG_CONDITIONAL([VIVADO_VERSION_2016_2])
dnl AS_VAR_IF([VIVADO_VERSION_2015_4],[yes], AS_VAR_SET([VIVADO_VERSION],["2015.4"]))
dnl AS_VAR_IF([VIVADO_VERSION_2016_2],[yes], AS_VAR_SET([VIVADO_VERSION],["2016.2"]))

AX_KCONFIG_WITH_CHOICE([VIVADO_VERSION],["Vivado version to use"],
		       [VIVADO_VERSION_2015_4],["2015.4"],
		       [VIVADO_VERSION_2016_2],["2016.2"],
		       [VIVADO_VERSION_2016_4],["2016.4"]
		      )
AC_SUBST([VIVADO_VERSION])

AX_KCONFIG_VAR([VIVADO_SETUP_SCRIPT])
AC_SUBST([VIVADO_SETUP_SCRIPT])

AX_KCONFIG_VAR([VIVADO_SDK_SETUP_SCRIPT])
AC_SUBST([VIVADO_SDK_SETUP_SCRIPT])

AX_KCONFIG_WITH_CHOICE([SOC_BOARD],["Select SoC board to use"],
		       [WITH_SOC_RED_PITAYA],["red_pitaya"],
		       [WITH_SOC_PARALLELLA],["parallella"])
AC_SUBST([SOC_BOARD])

AX_KCONFIG_VAR_ENABLE([ENABLE_FPGA])
AM_CONDITIONAL([ENABLE_FPGA],[test -n "${ENABLE_FPGA}" -a -f "${VIVADO_SETUP_SCRIPT}"])

AX_KCONFIG_VAR([DEVICETREE_BASEFILES_TAR])
AC_SUBST([DEVICETREE_BASEFILES_TAR])


# //////////////////////////////////////////////////////////////////////////// #
# //  LINUX  ///////////////////////////////////////////////////////////////// #
# //////////////////////////////////////////////////////////////////////////// #

AX_KCONFIG_VAR([LINUX_DIR])
AC_SUBST([LINUX_DIR])
AX_GITIGNORE_ADD([/${LINUX_DIR}])

AS_IF([test x"${srcdir}" = x$(pwd) ],
      AS_VAR_SET([CONFIG_LINUX_DIR_IN_SRCTREE],[y]))
AX_KCONFIG_CONDITIONAL([LINUX_DIR_IN_SRCTREE])

AX_KCONFIG_CONDITIONAL([WITH_LINUX_GIT])
AX_KCONFIG_CONDITIONAL([WITH_LINUX_TAR])

AX_KCONFIG_VAR([LINUX_GIT])
AC_SUBST([LINUX_GIT])
AX_KCONFIG_VAR([LINUX_TAR])
AC_SUBST([LINUX_TAR])

AX_KCONFIG_CONDITIONAL([LINUX_UIMAGE])
AX_KCONFIG_CONDITIONAL([LINUX_ZIMAGE])
AS_VAR_IF([LINUX_UIMAGE],[yes], AS_VAR_SET([LINUX_PACKAGE],[uImage]))
AS_VAR_IF([LINUX_ZIMAGE],[yes], AS_VAR_SET([LINUX_PACKAGE],[zImage]))
AC_SUBST([LINUX_PACKAGE])

AX_KCONFIG_VAR([LINUX_UIMAGE_LOADADDR])
AC_SUBST([LINUX_UIMAGE_LOADADDR])
AX_KCONFIG_VAR([LINUX_DEF_CONFIG])
AC_SUBST([LINUX_DEF_CONFIG])

dnl AS_VAR_IF([WITH_LINUX_TAR],[yes],
dnl	  [AS_ECHO("---- DOWNLOAD LINUX ----")
dnl	   AX_DOWNLOAD_TAR(${LINUX_TAR},${LINUX_DIR},[tmp])])

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

AC_CONFIG_FILES( 
                 Makefile
		 fpga/Makefile

		 projects/rfx_dmatests/Makefile
		 projects/rfx_dmatests/logic/Makefile
		 projects/rfx_dmatests/src/Kbuild
		 projects/rfx_dmatests/src/Makefile

		 projects/rfx_pwmgen/Makefile
		 projects/rfx_pwmgen/logic/Makefile
		 projects/rfx_pwmgen/src/Kbuild
		 projects/rfx_pwmgen/src/Makefile

		 dnl		 projects/rfx_axibase/Makefile
		 dnl		 projects/rfx_axibase/logic/Makefile
		 dnl		 projects/rfx_axibase/src/Kbuild
		 dnl		 projects/rfx_axibase/src/Makefile

		 projects/ext_HrRossi/Makefile
		 projects/ext_HrRossi/logic/Makefile
		 projects/ext_HrRossi/src/Kbuild
		 projects/ext_HrRossi/src/Makefile

		 projects/rfx_AD7641/Makefile
		 projects/rfx_AD7641/logic/Makefile
		 projects/rfx_AD7641/src/Kbuild
		 projects/rfx_AD7641/src/Makefile

		 projects/rfx_RPHctl/Makefile
		 projects/rfx_RPHctl/logic/Makefile
		 projects/rfx_RPHctl/src/Kbuild
		 projects/rfx_RPHctl/src/Makefile

		 projects/w7x_timing/Makefile
		 projects/w7x_timing/logic/Makefile
		 projects/w7x_timing/src/Kbuild
		 projects/w7x_timing/src/Makefile

		 .gitignore
               )
AC_OUTPUT
