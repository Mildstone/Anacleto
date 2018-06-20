## ////////////////////////////////////////////////////////////////////////// //
##
## This file is part of the anacleto project.
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

# //////////////////////////////////////////////////////////////////////////// #
# //  FPGA  ////////////////////////////////////////////////////////////////// #
# //////////////////////////////////////////////////////////////////////////// #


AX_KCONFIG_MODULES([ENABLE_BOARD],
			[red_pitaya], [],
			[zybo], [])
AC_SUBST([ENABLED_BOARDS],[${ENABLE_BOARD_MODULES}])

AX_KCONFIG_WITH_CHOICE([BOARD],["Select default board"],
			   [WITH_SOC_RED_PITAYA],["red_pitaya"],
			   [WITH_SOC_ZYBO],["zybo"],
			   [WITH_SOC_CUSTOM],["custom"]
			   )
AC_SUBST([BOARD])

AX_KCONFIG_VAR([red_pitaya_BOARD_PRESET])
AC_SUBST([red_pitaya_BOARD_PRESET])
AX_KCONFIG_VAR([red_pitaya_BOARD_PART])
AC_SUBST([red_pitaya_BOARD_PART])
AX_KCONFIG_VAR([red_pitaya_VIVADO_SOC_PART])
AC_SUBST([red_pitaya_VIVADO_SOC_PART])

AX_KCONFIG_VAR([zybo_BOARD_PRESET])
AC_SUBST([zybo_BOARD_PRESET])
AX_KCONFIG_VAR([zybo_BOARD_PART])
AC_SUBST([zybo_BOARD_PART])
AX_KCONFIG_VAR([zybo_VIVADO_SOC_PART])
AC_SUBST([zybo_VIVADO_SOC_PART])

AX_KCONFIG_VAR([custom_BOARD_PRESET])
AC_SUBST([custom_BOARD_PRESET])
AX_KCONFIG_VAR([custom_BOARD_PART])
AC_SUBST([custom_BOARD_PART])
AX_KCONFIG_VAR([custom_VIVADO_SOC_PART])
AC_SUBST([custom_VIVADO_SOC_PART])


AX_KCONFIG_WITH_CHOICE([VIVADO_VERSION],["Vivado version to use"],
			   [VIVADO_VERSION_2015_4],["2015.4"],
			   [VIVADO_VERSION_2016_1],["2016.1"],
			   [VIVADO_VERSION_2016_2],["2016.2"],
			   [VIVADO_VERSION_2016_4],["2016.4"],
			   [VIVADO_VERSION_2017_1],["2017.1"],
			   [VIVADO_VERSION_2017_2],["2017.2"],
			   [VIVADO_VERSION_2017_4],["2017.4"],
			   [VIVADO_VERSION_2018_1],["2018.1"])
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


## /////// CONFIG FILES ////////////////

AX_CONFIG_FILES(
  Makefile
  lib/red-pitaya-notes/Makefile
)

## /////////////////////////////////////
