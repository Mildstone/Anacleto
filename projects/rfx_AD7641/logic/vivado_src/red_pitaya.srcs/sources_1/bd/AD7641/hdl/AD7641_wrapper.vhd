--Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2015.4 (lin64) Build 1412921 Wed Nov 18 09:44:32 MST 2015
--Date        : Fri Jun  9 13:01:21 2017
--Host        : c9b68b82cb6f running 64-bit Ubuntu 14.04.5 LTS
--Command     : generate_target AD7641_wrapper.bd
--Design      : AD7641_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity AD7641_wrapper is
  port (
    CNVST_led : out STD_LOGIC_VECTOR ( 0 to 0 );
    CNVST_out_N : out STD_LOGIC_VECTOR ( 0 to 0 );
    CNVST_out_P : out STD_LOGIC_VECTOR ( 0 to 0 );
    DDR_addr : inout STD_LOGIC_VECTOR ( 14 downto 0 );
    DDR_ba : inout STD_LOGIC_VECTOR ( 2 downto 0 );
    DDR_cas_n : inout STD_LOGIC;
    DDR_ck_n : inout STD_LOGIC;
    DDR_ck_p : inout STD_LOGIC;
    DDR_cke : inout STD_LOGIC;
    DDR_cs_n : inout STD_LOGIC;
    DDR_dm : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dq : inout STD_LOGIC_VECTOR ( 31 downto 0 );
    DDR_dqs_n : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dqs_p : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_odt : inout STD_LOGIC;
    DDR_ras_n : inout STD_LOGIC;
    DDR_reset_n : inout STD_LOGIC;
    DDR_we_n : inout STD_LOGIC;
    FIXED_IO_ddr_vrn : inout STD_LOGIC;
    FIXED_IO_ddr_vrp : inout STD_LOGIC;
    FIXED_IO_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
    FIXED_IO_ps_clk : inout STD_LOGIC;
    FIXED_IO_ps_porb : inout STD_LOGIC;
    FIXED_IO_ps_srstb : inout STD_LOGIC;
    RST_out_N : out STD_LOGIC_VECTOR ( 0 to 0 );
    RST_out_P : out STD_LOGIC_VECTOR ( 0 to 0 );
    SCLK_in_N : in STD_LOGIC_VECTOR ( 0 to 0 );
    SCLK_in_P : in STD_LOGIC_VECTOR ( 0 to 0 );
    SDAT_in_N : in STD_LOGIC_VECTOR ( 0 to 0 );
    SDAT_in_P : in STD_LOGIC_VECTOR ( 0 to 0 );
    error_state_led : out STD_LOGIC
  );
end AD7641_wrapper;

architecture STRUCTURE of AD7641_wrapper is
  component AD7641 is
  port (
    DDR_cas_n : inout STD_LOGIC;
    DDR_cke : inout STD_LOGIC;
    DDR_ck_n : inout STD_LOGIC;
    DDR_ck_p : inout STD_LOGIC;
    DDR_cs_n : inout STD_LOGIC;
    DDR_reset_n : inout STD_LOGIC;
    DDR_odt : inout STD_LOGIC;
    DDR_ras_n : inout STD_LOGIC;
    DDR_we_n : inout STD_LOGIC;
    DDR_ba : inout STD_LOGIC_VECTOR ( 2 downto 0 );
    DDR_addr : inout STD_LOGIC_VECTOR ( 14 downto 0 );
    DDR_dm : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dq : inout STD_LOGIC_VECTOR ( 31 downto 0 );
    DDR_dqs_n : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dqs_p : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    FIXED_IO_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
    FIXED_IO_ddr_vrn : inout STD_LOGIC;
    FIXED_IO_ddr_vrp : inout STD_LOGIC;
    FIXED_IO_ps_srstb : inout STD_LOGIC;
    FIXED_IO_ps_clk : inout STD_LOGIC;
    FIXED_IO_ps_porb : inout STD_LOGIC;
    CNVST_out_N : out STD_LOGIC_VECTOR ( 0 to 0 );
    CNVST_out_P : out STD_LOGIC_VECTOR ( 0 to 0 );
    SCLK_in_N : in STD_LOGIC_VECTOR ( 0 to 0 );
    SDAT_in_N : in STD_LOGIC_VECTOR ( 0 to 0 );
    SCLK_in_P : in STD_LOGIC_VECTOR ( 0 to 0 );
    SDAT_in_P : in STD_LOGIC_VECTOR ( 0 to 0 );
    error_state_led : out STD_LOGIC;
    CNVST_led : out STD_LOGIC_VECTOR ( 0 to 0 );
    RST_out_P : out STD_LOGIC_VECTOR ( 0 to 0 );
    RST_out_N : out STD_LOGIC_VECTOR ( 0 to 0 )
  );
  end component AD7641;
begin
AD7641_i: component AD7641
     port map (
      CNVST_led(0) => CNVST_led(0),
      CNVST_out_N(0) => CNVST_out_N(0),
      CNVST_out_P(0) => CNVST_out_P(0),
      DDR_addr(14 downto 0) => DDR_addr(14 downto 0),
      DDR_ba(2 downto 0) => DDR_ba(2 downto 0),
      DDR_cas_n => DDR_cas_n,
      DDR_ck_n => DDR_ck_n,
      DDR_ck_p => DDR_ck_p,
      DDR_cke => DDR_cke,
      DDR_cs_n => DDR_cs_n,
      DDR_dm(3 downto 0) => DDR_dm(3 downto 0),
      DDR_dq(31 downto 0) => DDR_dq(31 downto 0),
      DDR_dqs_n(3 downto 0) => DDR_dqs_n(3 downto 0),
      DDR_dqs_p(3 downto 0) => DDR_dqs_p(3 downto 0),
      DDR_odt => DDR_odt,
      DDR_ras_n => DDR_ras_n,
      DDR_reset_n => DDR_reset_n,
      DDR_we_n => DDR_we_n,
      FIXED_IO_ddr_vrn => FIXED_IO_ddr_vrn,
      FIXED_IO_ddr_vrp => FIXED_IO_ddr_vrp,
      FIXED_IO_mio(53 downto 0) => FIXED_IO_mio(53 downto 0),
      FIXED_IO_ps_clk => FIXED_IO_ps_clk,
      FIXED_IO_ps_porb => FIXED_IO_ps_porb,
      FIXED_IO_ps_srstb => FIXED_IO_ps_srstb,
      RST_out_N(0) => RST_out_N(0),
      RST_out_P(0) => RST_out_P(0),
      SCLK_in_N(0) => SCLK_in_N(0),
      SCLK_in_P(0) => SCLK_in_P(0),
      SDAT_in_N(0) => SDAT_in_N(0),
      SDAT_in_P(0) => SDAT_in_P(0),
      error_state_led => error_state_led
    );
end STRUCTURE;
