
################################################################
# This is a generated script based on design: red_pitaya_ps_1
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2017.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_msg_id "BD_TCL-109" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source red_pitaya_ps_1_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7z010clg400-1
}


# CHANGE DESIGN NAME HERE
set design_name red_pitaya_ps_1

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_msg_id "BD_TCL-001" "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_msg_id "BD_TCL-002" "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_msg_id "BD_TCL-004" "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_msg_id "BD_TCL-005" "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_msg_id "BD_TCL-114" "ERROR" $errMsg}
   return $nRet
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set DDR [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR ]
  set FIXED_IO [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO ]

  # Create ports
  set adc_dat_a [ create_bd_port -dir I -from 13 -to 0 adc_dat_a ]
  set adc_dat_b [ create_bd_port -dir I -from 13 -to 0 adc_dat_b ]
  set led_o2_V [ create_bd_port -dir O -from 0 -to 0 -type data led_o2_V ]
  set led_o_V [ create_bd_port -dir O -from 0 -to 0 -type data led_o_V ]
  set start [ create_bd_port -dir O -from 0 -to 0 start ]

  # Create instance: axi_cfg_register_0, and set properties
  set axi_cfg_register_0 [ create_bd_cell -type ip -vlnv pavel-demin:user:axi_cfg_register:1.0 axi_cfg_register_0 ]
  set_property -dict [ list \
CONFIG.CFG_DATA_WIDTH {32} \
 ] $axi_cfg_register_0

  set_property -dict [ list \
CONFIG.NUM_READ_OUTSTANDING {1} \
CONFIG.NUM_WRITE_OUTSTANDING {1} \
 ] [get_bd_intf_pins /axi_cfg_register_0/S_AXI]

  # Create instance: axi_cfg_starter, and set properties
  set axi_cfg_starter [ create_bd_cell -type ip -vlnv pavel-demin:user:axi_cfg_register:1.0 axi_cfg_starter ]
  set_property -dict [ list \
CONFIG.CFG_DATA_WIDTH {32} \
 ] $axi_cfg_starter

  set_property -dict [ list \
CONFIG.NUM_READ_OUTSTANDING {1} \
CONFIG.NUM_WRITE_OUTSTANDING {1} \
 ] [get_bd_intf_pins /axi_cfg_starter/S_AXI]

  # Create instance: axi_fifo_mm_s_0, and set properties
  set axi_fifo_mm_s_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_fifo_mm_s:4.1 axi_fifo_mm_s_0 ]
  set_property -dict [ list \
CONFIG.C_USE_RX_DATA {1} \
CONFIG.C_USE_TX_CTRL {0} \
CONFIG.C_USE_TX_DATA {0} \
 ] $axi_fifo_mm_s_0

  # Create instance: axis_decimator_0, and set properties
  set axis_decimator_0 [ create_bd_cell -type ip -vlnv pavel-demin:user:axis_decimator:1.0 axis_decimator_0 ]

  set_property -dict [ list \
CONFIG.TDATA_NUM_BYTES {4} \
 ] [get_bd_intf_pins /axis_decimator_0/M_AXIS]

  # Create instance: axis_packetizer_0, and set properties
  set axis_packetizer_0 [ create_bd_cell -type ip -vlnv pavel-demin:user:axis_packetizer:1.0 axis_packetizer_0 ]

  set_property -dict [ list \
CONFIG.TDATA_NUM_BYTES {4} \
 ] [get_bd_intf_pins /axis_packetizer_0/M_AXIS]

  # Create instance: axis_red_pitaya_adc_0, and set properties
  set axis_red_pitaya_adc_0 [ create_bd_cell -type ip -vlnv pavel-demin:user:axis_red_pitaya_adc:2.0 axis_red_pitaya_adc_0 ]

  set_property -dict [ list \
CONFIG.TDATA_NUM_BYTES {4} \
 ] [get_bd_intf_pins /axis_red_pitaya_adc_0/M_AXIS]

  # Create instance: red_pitaya_ps, and set properties
  set red_pitaya_ps [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 red_pitaya_ps ]
  set_property -dict [ list \
CONFIG.PCW_ACT_ENET0_PERIPHERAL_FREQMHZ {125.000000} \
CONFIG.PCW_ACT_FPGA0_PERIPHERAL_FREQMHZ {125.000000} \
CONFIG.PCW_ACT_QSPI_PERIPHERAL_FREQMHZ {125.000000} \
CONFIG.PCW_ACT_SDIO_PERIPHERAL_FREQMHZ {100.000000} \
CONFIG.PCW_ACT_SPI_PERIPHERAL_FREQMHZ {166.666672} \
CONFIG.PCW_ACT_UART_PERIPHERAL_FREQMHZ {100.000000} \
CONFIG.PCW_CLK0_FREQ {125000000} \
CONFIG.PCW_ENET0_ENET0_IO {MIO 16 .. 27} \
CONFIG.PCW_ENET0_GRP_MDIO_ENABLE {1} \
CONFIG.PCW_ENET0_GRP_MDIO_IO {MIO 52 .. 53} \
CONFIG.PCW_ENET0_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_ENET_RESET_ENABLE {1} \
CONFIG.PCW_ENET_RESET_SELECT {Share reset pin} \
CONFIG.PCW_EN_ENET0 {1} \
CONFIG.PCW_EN_GPIO {1} \
CONFIG.PCW_EN_I2C0 {1} \
CONFIG.PCW_EN_QSPI {1} \
CONFIG.PCW_EN_SDIO0 {1} \
CONFIG.PCW_EN_SPI1 {1} \
CONFIG.PCW_EN_UART0 {1} \
CONFIG.PCW_EN_UART1 {1} \
CONFIG.PCW_EN_USB0 {1} \
CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {125} \
CONFIG.PCW_FPGA1_PERIPHERAL_FREQMHZ {250} \
CONFIG.PCW_FPGA3_PERIPHERAL_FREQMHZ {200} \
CONFIG.PCW_GPIO_MIO_GPIO_ENABLE {1} \
CONFIG.PCW_GPIO_MIO_GPIO_IO {MIO} \
CONFIG.PCW_I2C0_I2C0_IO {MIO 50 .. 51} \
CONFIG.PCW_I2C0_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_I2C_PERIPHERAL_FREQMHZ {111.111115} \
CONFIG.PCW_I2C_RESET_ENABLE {1} \
CONFIG.PCW_I2C_RESET_SELECT {Share reset pin} \
CONFIG.PCW_IRQ_F2P_INTR {1} \
CONFIG.PCW_MIO_0_IOTYPE {LVCMOS 3.3V} \
CONFIG.PCW_MIO_0_PULLUP {enabled} \
CONFIG.PCW_MIO_0_SLEW {slow} \
CONFIG.PCW_MIO_10_IOTYPE {LVCMOS 3.3V} \
CONFIG.PCW_MIO_10_PULLUP {enabled} \
CONFIG.PCW_MIO_10_SLEW {slow} \
CONFIG.PCW_MIO_11_IOTYPE {LVCMOS 3.3V} \
CONFIG.PCW_MIO_11_PULLUP {enabled} \
CONFIG.PCW_MIO_11_SLEW {slow} \
CONFIG.PCW_MIO_12_IOTYPE {LVCMOS 3.3V} \
CONFIG.PCW_MIO_12_PULLUP {enabled} \
CONFIG.PCW_MIO_12_SLEW {slow} \
CONFIG.PCW_MIO_13_IOTYPE {LVCMOS 3.3V} \
CONFIG.PCW_MIO_13_PULLUP {enabled} \
CONFIG.PCW_MIO_13_SLEW {slow} \
CONFIG.PCW_MIO_14_IOTYPE {LVCMOS 3.3V} \
CONFIG.PCW_MIO_14_PULLUP {enabled} \
CONFIG.PCW_MIO_14_SLEW {slow} \
CONFIG.PCW_MIO_15_IOTYPE {LVCMOS 3.3V} \
CONFIG.PCW_MIO_15_PULLUP {enabled} \
CONFIG.PCW_MIO_15_SLEW {slow} \
CONFIG.PCW_MIO_16_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_16_PULLUP {disabled} \
CONFIG.PCW_MIO_16_SLEW {fast} \
CONFIG.PCW_MIO_17_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_17_PULLUP {disabled} \
CONFIG.PCW_MIO_17_SLEW {fast} \
CONFIG.PCW_MIO_18_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_18_PULLUP {disabled} \
CONFIG.PCW_MIO_18_SLEW {fast} \
CONFIG.PCW_MIO_19_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_19_PULLUP {disabled} \
CONFIG.PCW_MIO_19_SLEW {fast} \
CONFIG.PCW_MIO_1_IOTYPE {LVCMOS 3.3V} \
CONFIG.PCW_MIO_1_PULLUP {enabled} \
CONFIG.PCW_MIO_1_SLEW {slow} \
CONFIG.PCW_MIO_20_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_20_PULLUP {disabled} \
CONFIG.PCW_MIO_20_SLEW {fast} \
CONFIG.PCW_MIO_21_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_21_PULLUP {disabled} \
CONFIG.PCW_MIO_21_SLEW {fast} \
CONFIG.PCW_MIO_22_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_22_PULLUP {disabled} \
CONFIG.PCW_MIO_22_SLEW {fast} \
CONFIG.PCW_MIO_23_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_23_PULLUP {disabled} \
CONFIG.PCW_MIO_23_SLEW {fast} \
CONFIG.PCW_MIO_24_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_24_PULLUP {disabled} \
CONFIG.PCW_MIO_24_SLEW {fast} \
CONFIG.PCW_MIO_25_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_25_PULLUP {disabled} \
CONFIG.PCW_MIO_25_SLEW {fast} \
CONFIG.PCW_MIO_26_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_26_PULLUP {disabled} \
CONFIG.PCW_MIO_26_SLEW {fast} \
CONFIG.PCW_MIO_27_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_27_PULLUP {disabled} \
CONFIG.PCW_MIO_27_SLEW {fast} \
CONFIG.PCW_MIO_28_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_28_PULLUP {disabled} \
CONFIG.PCW_MIO_28_SLEW {fast} \
CONFIG.PCW_MIO_29_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_29_PULLUP {disabled} \
CONFIG.PCW_MIO_29_SLEW {fast} \
CONFIG.PCW_MIO_2_IOTYPE {LVCMOS 3.3V} \
CONFIG.PCW_MIO_2_SLEW {slow} \
CONFIG.PCW_MIO_30_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_30_PULLUP {disabled} \
CONFIG.PCW_MIO_30_SLEW {fast} \
CONFIG.PCW_MIO_31_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_31_PULLUP {disabled} \
CONFIG.PCW_MIO_31_SLEW {fast} \
CONFIG.PCW_MIO_32_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_32_PULLUP {disabled} \
CONFIG.PCW_MIO_32_SLEW {fast} \
CONFIG.PCW_MIO_33_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_33_PULLUP {disabled} \
CONFIG.PCW_MIO_33_SLEW {fast} \
CONFIG.PCW_MIO_34_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_34_PULLUP {disabled} \
CONFIG.PCW_MIO_34_SLEW {fast} \
CONFIG.PCW_MIO_35_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_35_PULLUP {disabled} \
CONFIG.PCW_MIO_35_SLEW {fast} \
CONFIG.PCW_MIO_36_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_36_PULLUP {disabled} \
CONFIG.PCW_MIO_36_SLEW {fast} \
CONFIG.PCW_MIO_37_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_37_PULLUP {disabled} \
CONFIG.PCW_MIO_37_SLEW {fast} \
CONFIG.PCW_MIO_38_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_38_PULLUP {disabled} \
CONFIG.PCW_MIO_38_SLEW {fast} \
CONFIG.PCW_MIO_39_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_39_PULLUP {disabled} \
CONFIG.PCW_MIO_39_SLEW {fast} \
CONFIG.PCW_MIO_3_IOTYPE {LVCMOS 3.3V} \
CONFIG.PCW_MIO_3_SLEW {slow} \
CONFIG.PCW_MIO_40_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_40_PULLUP {enabled} \
CONFIG.PCW_MIO_40_SLEW {slow} \
CONFIG.PCW_MIO_41_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_41_PULLUP {enabled} \
CONFIG.PCW_MIO_41_SLEW {slow} \
CONFIG.PCW_MIO_42_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_42_PULLUP {enabled} \
CONFIG.PCW_MIO_42_SLEW {slow} \
CONFIG.PCW_MIO_43_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_43_PULLUP {enabled} \
CONFIG.PCW_MIO_43_SLEW {slow} \
CONFIG.PCW_MIO_44_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_44_PULLUP {enabled} \
CONFIG.PCW_MIO_44_SLEW {slow} \
CONFIG.PCW_MIO_45_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_45_PULLUP {enabled} \
CONFIG.PCW_MIO_45_SLEW {slow} \
CONFIG.PCW_MIO_46_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_46_PULLUP {enabled} \
CONFIG.PCW_MIO_46_SLEW {slow} \
CONFIG.PCW_MIO_47_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_47_PULLUP {enabled} \
CONFIG.PCW_MIO_47_SLEW {slow} \
CONFIG.PCW_MIO_48_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_48_PULLUP {enabled} \
CONFIG.PCW_MIO_48_SLEW {slow} \
CONFIG.PCW_MIO_49_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_49_PULLUP {enabled} \
CONFIG.PCW_MIO_49_SLEW {slow} \
CONFIG.PCW_MIO_4_IOTYPE {LVCMOS 3.3V} \
CONFIG.PCW_MIO_4_SLEW {slow} \
CONFIG.PCW_MIO_50_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_50_PULLUP {enabled} \
CONFIG.PCW_MIO_50_SLEW {slow} \
CONFIG.PCW_MIO_51_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_51_PULLUP {enabled} \
CONFIG.PCW_MIO_51_SLEW {slow} \
CONFIG.PCW_MIO_52_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_52_PULLUP {enabled} \
CONFIG.PCW_MIO_52_SLEW {slow} \
CONFIG.PCW_MIO_53_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_53_PULLUP {enabled} \
CONFIG.PCW_MIO_53_SLEW {slow} \
CONFIG.PCW_MIO_5_IOTYPE {LVCMOS 3.3V} \
CONFIG.PCW_MIO_5_SLEW {slow} \
CONFIG.PCW_MIO_6_IOTYPE {LVCMOS 3.3V} \
CONFIG.PCW_MIO_6_SLEW {slow} \
CONFIG.PCW_MIO_7_IOTYPE {LVCMOS 3.3V} \
CONFIG.PCW_MIO_7_SLEW {slow} \
CONFIG.PCW_MIO_8_IOTYPE {LVCMOS 3.3V} \
CONFIG.PCW_MIO_8_SLEW {slow} \
CONFIG.PCW_MIO_9_IOTYPE {LVCMOS 3.3V} \
CONFIG.PCW_MIO_9_PULLUP {enabled} \
CONFIG.PCW_MIO_9_SLEW {slow} \
CONFIG.PCW_MIO_TREE_PERIPHERALS {GPIO#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#GPIO#UART 1#UART 1#SPI 1#SPI 1#SPI 1#SPI 1#UART 0#UART 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#SD 0#SD 0#SD 0#SD 0#SD 0#SD 0#SD 0#SD 0#USB Reset#GPIO#I2C 0#I2C 0#Enet 0#Enet 0} \
CONFIG.PCW_MIO_TREE_SIGNALS {gpio[0]#qspi0_ss_b#qspi0_io[0]#qspi0_io[1]#qspi0_io[2]#qspi0_io[3]#qspi0_sclk#gpio[7]#tx#rx#mosi#miso#sclk#ss[0]#rx#tx#tx_clk#txd[0]#txd[1]#txd[2]#txd[3]#tx_ctl#rx_clk#rxd[0]#rxd[1]#rxd[2]#rxd[3]#rx_ctl#data[4]#dir#stp#nxt#data[0]#data[1]#data[2]#data[3]#clk#data[5]#data[6]#data[7]#clk#cmd#data[0]#data[1]#data[2]#data[3]#cd#wp#reset#gpio[49]#scl#sda#mdc#mdio} \
CONFIG.PCW_PRESET_BANK1_VOLTAGE {LVCMOS 2.5V} \
CONFIG.PCW_QSPI_GRP_SINGLE_SS_ENABLE {1} \
CONFIG.PCW_QSPI_GRP_SINGLE_SS_IO {MIO 1 .. 6} \
CONFIG.PCW_QSPI_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_QSPI_PERIPHERAL_FREQMHZ {125} \
CONFIG.PCW_QSPI_QSPI_IO {MIO 1 .. 6} \
CONFIG.PCW_SD0_GRP_CD_ENABLE {1} \
CONFIG.PCW_SD0_GRP_CD_IO {MIO 46} \
CONFIG.PCW_SD0_GRP_WP_ENABLE {1} \
CONFIG.PCW_SD0_GRP_WP_IO {MIO 47} \
CONFIG.PCW_SD0_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_SD0_SD0_IO {MIO 40 .. 45} \
CONFIG.PCW_SDIO_PERIPHERAL_VALID {1} \
CONFIG.PCW_SPI1_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_SPI1_SPI1_IO {MIO 10 .. 15} \
CONFIG.PCW_SPI_PERIPHERAL_VALID {1} \
CONFIG.PCW_UART0_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_UART0_UART0_IO {MIO 14 .. 15} \
CONFIG.PCW_UART1_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_UART1_UART1_IO {MIO 8 .. 9} \
CONFIG.PCW_UART_PERIPHERAL_VALID {1} \
CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY0 {0.0} \
CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY1 {0.0} \
CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY2 {0.0} \
CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY3 {0.0} \
CONFIG.PCW_UIPARAM_DDR_BUS_WIDTH {16 Bit} \
CONFIG.PCW_UIPARAM_DDR_PARTNO {MT41J256M16 RE-125} \
CONFIG.PCW_USB0_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_USB0_RESET_ENABLE {1} \
CONFIG.PCW_USB0_RESET_IO {MIO 48} \
CONFIG.PCW_USB0_USB0_IO {MIO 28 .. 39} \
CONFIG.PCW_USB_RESET_ENABLE {1} \
CONFIG.PCW_USB_RESET_SELECT {Share reset pin} \
CONFIG.PCW_USE_FABRIC_INTERRUPT {1} \
CONFIG.PCW_USE_M_AXI_GP0 {1} \
 ] $red_pitaya_ps

  # Create instance: red_pitaya_ps_axi_periph, and set properties
  set red_pitaya_ps_axi_periph [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 red_pitaya_ps_axi_periph ]
  set_property -dict [ list \
CONFIG.NUM_MI {5} \
 ] $red_pitaya_ps_axi_periph

  # Create instance: rst_red_pitaya_ps_125M, and set properties
  set rst_red_pitaya_ps_125M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_red_pitaya_ps_125M ]

  # Create instance: trigger_0, and set properties
  set trigger_0 [ create_bd_cell -type ip -vlnv xilinx.com:hls:trigger:1.0 trigger_0 ]

  # Create instance: xlconstant_0, and set properties
  set xlconstant_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0 ]
  set_property -dict [ list \
CONFIG.CONST_WIDTH {32} \
 ] $xlconstant_0

  # Create instance: xlslice_0, and set properties
  set xlslice_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_0 ]

  # Create interface connections
  connect_bd_intf_net -intf_net axis_decimator_0_M_AXIS [get_bd_intf_pins axis_decimator_0/M_AXIS] [get_bd_intf_pins axis_packetizer_0/S_AXIS]
  connect_bd_intf_net -intf_net axis_packetizer_0_M_AXIS [get_bd_intf_pins axis_packetizer_0/M_AXIS] [get_bd_intf_pins trigger_0/A]
  connect_bd_intf_net -intf_net axis_red_pitaya_adc_0_M_AXIS [get_bd_intf_pins axis_decimator_0/S_AXIS] [get_bd_intf_pins axis_red_pitaya_adc_0/M_AXIS]
  connect_bd_intf_net -intf_net red_pitaya_ps_DDR [get_bd_intf_ports DDR] [get_bd_intf_pins red_pitaya_ps/DDR]
  connect_bd_intf_net -intf_net red_pitaya_ps_FIXED_IO [get_bd_intf_ports FIXED_IO] [get_bd_intf_pins red_pitaya_ps/FIXED_IO]
  connect_bd_intf_net -intf_net red_pitaya_ps_M_AXI_GP0 [get_bd_intf_pins red_pitaya_ps/M_AXI_GP0] [get_bd_intf_pins red_pitaya_ps_axi_periph/S00_AXI]
  connect_bd_intf_net -intf_net red_pitaya_ps_axi_periph_M01_AXI [get_bd_intf_pins axi_fifo_mm_s_0/S_AXI] [get_bd_intf_pins red_pitaya_ps_axi_periph/M01_AXI]
  connect_bd_intf_net -intf_net red_pitaya_ps_axi_periph_M02_AXI [get_bd_intf_pins axi_cfg_register_0/S_AXI] [get_bd_intf_pins red_pitaya_ps_axi_periph/M02_AXI]
  connect_bd_intf_net -intf_net red_pitaya_ps_axi_periph_M03_AXI [get_bd_intf_pins axi_cfg_starter/S_AXI] [get_bd_intf_pins red_pitaya_ps_axi_periph/M03_AXI]
  connect_bd_intf_net -intf_net red_pitaya_ps_axi_periph_M04_AXI [get_bd_intf_pins red_pitaya_ps_axi_periph/M04_AXI] [get_bd_intf_pins trigger_0/s_axi_C]
  connect_bd_intf_net -intf_net trigger_0_B [get_bd_intf_pins axi_fifo_mm_s_0/AXI_STR_RXD] [get_bd_intf_pins trigger_0/B]

  # Create port connections
  connect_bd_net -net adc_dat_a_1 [get_bd_ports adc_dat_a] [get_bd_pins axis_red_pitaya_adc_0/adc_dat_a]
  connect_bd_net -net adc_dat_b_1 [get_bd_ports adc_dat_b] [get_bd_pins axis_red_pitaya_adc_0/adc_dat_b]
  connect_bd_net -net axi_cfg_register_0_cfg_data [get_bd_pins axi_cfg_register_0/cfg_data] [get_bd_pins axis_decimator_0/cfg_data]
  connect_bd_net -net axi_cfg_starter_cfg_data [get_bd_pins axi_cfg_starter/cfg_data] [get_bd_pins xlslice_0/Din]
  connect_bd_net -net axi_fifo_mm_s_0_interrupt [get_bd_pins axi_fifo_mm_s_0/interrupt] [get_bd_pins red_pitaya_ps/IRQ_F2P]
  connect_bd_net -net red_pitaya_ps_FCLK_CLK0 [get_bd_pins axi_cfg_register_0/aclk] [get_bd_pins axi_cfg_starter/aclk] [get_bd_pins axi_fifo_mm_s_0/s_axi_aclk] [get_bd_pins axis_decimator_0/aclk] [get_bd_pins axis_packetizer_0/aclk] [get_bd_pins axis_red_pitaya_adc_0/aclk] [get_bd_pins red_pitaya_ps/FCLK_CLK0] [get_bd_pins red_pitaya_ps/M_AXI_GP0_ACLK] [get_bd_pins red_pitaya_ps_axi_periph/ACLK] [get_bd_pins red_pitaya_ps_axi_periph/M00_ACLK] [get_bd_pins red_pitaya_ps_axi_periph/M01_ACLK] [get_bd_pins red_pitaya_ps_axi_periph/M02_ACLK] [get_bd_pins red_pitaya_ps_axi_periph/M03_ACLK] [get_bd_pins red_pitaya_ps_axi_periph/M04_ACLK] [get_bd_pins red_pitaya_ps_axi_periph/S00_ACLK] [get_bd_pins rst_red_pitaya_ps_125M/slowest_sync_clk] [get_bd_pins trigger_0/ap_clk]
  connect_bd_net -net red_pitaya_ps_FCLK_RESET0_N [get_bd_pins red_pitaya_ps/FCLK_RESET0_N] [get_bd_pins rst_red_pitaya_ps_125M/ext_reset_in]
  connect_bd_net -net rst_red_pitaya_ps_125M_interconnect_aresetn [get_bd_pins red_pitaya_ps_axi_periph/ARESETN] [get_bd_pins rst_red_pitaya_ps_125M/interconnect_aresetn]
  connect_bd_net -net rst_red_pitaya_ps_125M_peripheral_aresetn [get_bd_pins axi_cfg_register_0/aresetn] [get_bd_pins axi_cfg_starter/aresetn] [get_bd_pins axi_fifo_mm_s_0/s_axi_aresetn] [get_bd_pins axis_decimator_0/aresetn] [get_bd_pins axis_packetizer_0/aresetn] [get_bd_pins red_pitaya_ps_axi_periph/M00_ARESETN] [get_bd_pins red_pitaya_ps_axi_periph/M01_ARESETN] [get_bd_pins red_pitaya_ps_axi_periph/M02_ARESETN] [get_bd_pins red_pitaya_ps_axi_periph/M03_ARESETN] [get_bd_pins red_pitaya_ps_axi_periph/M04_ARESETN] [get_bd_pins red_pitaya_ps_axi_periph/S00_ARESETN] [get_bd_pins rst_red_pitaya_ps_125M/peripheral_aresetn] [get_bd_pins trigger_0/ap_rst_n]
  connect_bd_net -net trigger_0_led_V [get_bd_ports led_o_V] [get_bd_pins trigger_0/led_V]
  connect_bd_net -net trigger_0_led_o2_V [get_bd_ports led_o2_V] [get_bd_pins trigger_0/led2_V]
  connect_bd_net -net xlconstant_0_dout [get_bd_pins axis_packetizer_0/cfg_data] [get_bd_pins xlconstant_0/dout]
  connect_bd_net -net xlslice_0_Dout [get_bd_ports start] [get_bd_pins xlslice_0/Dout]

  # Create address segments
  create_bd_addr_seg -range 0x00001000 -offset 0x60000000 [get_bd_addr_spaces red_pitaya_ps/Data] [get_bd_addr_segs axi_cfg_register_0/s_axi/reg0] SEG_axi_cfg_register_0_reg0
  create_bd_addr_seg -range 0x00001000 -offset 0x50000000 [get_bd_addr_spaces red_pitaya_ps/Data] [get_bd_addr_segs axi_cfg_starter/s_axi/reg0] SEG_axi_cfg_register_1_reg0
  create_bd_addr_seg -range 0x00010000 -offset 0x43C10000 [get_bd_addr_spaces red_pitaya_ps/Data] [get_bd_addr_segs axi_fifo_mm_s_0/S_AXI/Mem0] SEG_axi_fifo_mm_s_0_Mem0
  create_bd_addr_seg -range 0x00010000 -offset 0x43C00000 [get_bd_addr_spaces red_pitaya_ps/Data] [get_bd_addr_segs trigger_0/s_axi_C/Reg] SEG_trigger_0_Reg


  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


