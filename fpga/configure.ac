# //////////////////////////////////////////////////////////////////////////// #
# //  FPGA  ////////////////////////////////////////////////////////////////// #
# //////////////////////////////////////////////////////////////////////////// #

AX_KCONFIG_WITH_CHOICE([BOARD],["Select SoC board to use"],
			   [WITH_SOC_RED_PITAYA],["red_pitaya"],
			   [WITH_SOC_PARALLELLA],["parallella"])
AC_SUBST([BOARD])

AX_KCONFIG_VAR([VIVADO_SOC_PART])
AC_SUBST([VIVADO_SOC_PART])

AX_KCONFIG_WITH_CHOICE([VIVADO_VERSION],["Vivado version to use"],
			   [VIVADO_VERSION_2015_4],["2015.4"],
			   [VIVADO_VERSION_2016_1],["2016.1"],
			   [VIVADO_VERSION_2016_2],["2016.2"],
			   [VIVADO_VERSION_2016_4],["2016.4"],
			   [VIVADO_VERSION_2017_1],["2017.1"],
			   [VIVADO_VERSION_2017_2],["2017.2"])
AC_SUBST([VIVADO_VERSION])

AX_KCONFIG_WITH_CHOICE([VIVADO_SETUP_METHOD],["Vivado setup method"],
					   [VIVADO_SETUP_METHOD_BASEPATH],[basepath],
					   [VIVADO_SETUP_METHOD_SCRIPTS],[scripts])
AS_CASE([${VIVADO_SETUP_METHOD}],
[basepath],
  [AX_KCONFIG_VAR([XILINX_BASE_PATHDIR])
   AS_VAR_SET([VIVADO_SETUP_SCRIPT],
			  [${XILINX_BASE_PATHDIR}/Vivado/${VIVADO_VERSION}/settings64.sh])
   AS_VAR_SET([VIVADO_SDK_SETUP_SCRIPT],
			  [${XILINX_BASE_PATHDIR}/SDK/${VIVADO_VERSION}/settings64.sh])
  ],
[scripts],
  [AX_KCONFIG_VAR([VIVADO_SETUP_SCRIPT])
   AX_KCONFIG_VAR([VIVADO_SDK_SETUP_SCRIPT])
  ],
  [AC_ERROR(["Xilinx config method not set"])])
AC_SUBST([VIVADO_SETUP_SCRIPT])
AC_SUBST([VIVADO_SDK_SETUP_SCRIPT])

AX_KCONFIG_VAR_ENABLE([ENABLE_FPGA])
AM_CONDITIONAL([ENABLE_FPGA],[test -n "${ENABLE_FPGA}" -a -f "${VIVADO_SETUP_SCRIPT}"])

AX_COMPARE_VERSION(${VIVADO_VERSION},[lt],[2017],
				   AS_VAR_SET([SYSTEM_DTS],[system.dts]),
				   AS_VAR_SET([SYSTEM_DTS],[system-top.dts]))
AC_SUBST([SYSTEM_DTS])

AX_KCONFIG_VAR([DEVICETREE_BASEFILES_TAR])
AC_SUBST([DEVICETREE_BASEFILES_TAR])
