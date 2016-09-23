################################################################################
# HSI tcl script for building RedPitaya FSBL
#
# Usage:
# hsi -mode tcl -source red_pitaya_hsi_fsbl.tcl
################################################################################

global env
set srcdir   $env(srcdir)
set top_srcdir   $env(top_srcdir)

set SYSTEM           $env(SYSTEM)
set SOC_BOARD        $env(SOC_BOARD)
set FPGA_SDC         $env(FPGA_SDC)
set FPGA_BIT         $env(FPGA_BIT)
set VIVADO_VERSION   $env(VIVADO_VERSION)
set VIVADO_SOC_PART  $env(VIVADO_SOC_PART)
set FPGA_REPO_DIR    $env(FPGA_REPO_DIR)

set path_sdk sdk

open_hw_design $path_sdk/$SYSTEM.sysdef
generate_app -hw system_0 -os standalone -proc ps7_cortexa9_0 -app zynq_fsbl -compile -sw fsbl -dir $path_sdk/fsbl

exit
