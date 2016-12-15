--Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2015.4 (lin64) Build 1412921 Wed Nov 18 09:44:32 MST 2015
--Date        : Thu Dec 15 10:07:19 2016
--Host        : c0140022195e running 64-bit Ubuntu 14.04.5 LTS
--Command     : generate_target system_wrapper.bd
--Design      : system_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity system_wrapper is
  port (
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
    IDS_N : in STD_LOGIC_VECTOR ( 0 to 0 );
    IDS_P : in STD_LOGIC_VECTOR ( 0 to 0 );
    IDS_led : out STD_LOGIC_VECTOR ( 0 to 0 );
    clock_out_N : out STD_LOGIC_VECTOR ( 0 to 0 );
    clock_out_P : out STD_LOGIC_VECTOR ( 0 to 0 );
    led_o : out STD_LOGIC;
    prescaler_output_LED_clk : out STD_LOGIC;
    prescaler_output_clk_1 : out STD_LOGIC;
    prescaler_output_clk_negato_2 : out STD_LOGIC;
    pwm_n_out : out STD_LOGIC_VECTOR ( 0 to 0 );
    pwm_n_out_1 : out STD_LOGIC_VECTOR ( 0 to 0 );
    pwm_out : out STD_LOGIC_VECTOR ( 0 to 0 );
    pwm_out_1 : out STD_LOGIC_VECTOR ( 0 to 0 );
    test_speed_out_led : out STD_LOGIC
  );
end system_wrapper;

architecture STRUCTURE of system_wrapper is
  component system is
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
    pwm_n_out : out STD_LOGIC_VECTOR ( 0 to 0 );
    pwm_n_out_1 : out STD_LOGIC_VECTOR ( 0 to 0 );
    pwm_out : out STD_LOGIC_VECTOR ( 0 to 0 );
    pwm_out_1 : out STD_LOGIC_VECTOR ( 0 to 0 );
    led_o : out STD_LOGIC;
    IDS_led : out STD_LOGIC_VECTOR ( 0 to 0 );
    clock_out_P : out STD_LOGIC_VECTOR ( 0 to 0 );
    clock_out_N : out STD_LOGIC_VECTOR ( 0 to 0 );
    IDS_P : in STD_LOGIC_VECTOR ( 0 to 0 );
    IDS_N : in STD_LOGIC_VECTOR ( 0 to 0 );
    prescaler_output_clk_negato_2 : out STD_LOGIC;
    test_speed_out_led : out STD_LOGIC;
    prescaler_output_clk_1 : out STD_LOGIC;
    prescaler_output_LED_clk : out STD_LOGIC
  );
  end component system;
begin
system_i: component system
     port map (
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
      IDS_N(0) => IDS_N(0),
      IDS_P(0) => IDS_P(0),
      IDS_led(0) => IDS_led(0),
      clock_out_N(0) => clock_out_N(0),
      clock_out_P(0) => clock_out_P(0),
      led_o => led_o,
      prescaler_output_LED_clk => prescaler_output_LED_clk,
      prescaler_output_clk_1 => prescaler_output_clk_1,
      prescaler_output_clk_negato_2 => prescaler_output_clk_negato_2,
      pwm_n_out(0) => pwm_n_out(0),
      pwm_n_out_1(0) => pwm_n_out_1(0),
      pwm_out(0) => pwm_out(0),
      pwm_out_1(0) => pwm_out_1(0),
      test_speed_out_led => test_speed_out_led
    );
end STRUCTURE;
