//Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2016.4 (lin64) Build 1733598 Wed Dec 14 22:35:42 MST 2016
//Date        : Mon Jul 17 07:48:32 2017
//Host        : 172a52d958a7 running 64-bit Ubuntu 14.04.5 LTS
//Command     : generate_target design_1_wrapper.bd
//Design      : design_1_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module design_1_wrapper
   (CNVST_N,
    CNVST_P,
    DDR_addr,
    DDR_ba,
    DDR_cas_n,
    DDR_ck_n,
    DDR_ck_p,
    DDR_cke,
    DDR_cs_n,
    DDR_dm,
    DDR_dq,
    DDR_dqs_n,
    DDR_dqs_p,
    DDR_odt,
    DDR_ras_n,
    DDR_reset_n,
    DDR_we_n,
    FIXED_IO_ddr_vrn,
    FIXED_IO_ddr_vrp,
    FIXED_IO_mio,
    FIXED_IO_ps_clk,
    FIXED_IO_ps_porb,
    FIXED_IO_ps_srstb,
    RST_N,
    RST_P,
    SCLK_N,
    SCLK_P,
    SDAT_N,
    SDAT_P,
    adc_clk_n_i,
    adc_clk_o,
    adc_clk_p_i,
    adc_csn,
    adc_dat_a_i,
    adc_dat_b_i,
    error_state);
  output [0:0]CNVST_N;
  output [0:0]CNVST_P;
  inout [14:0]DDR_addr;
  inout [2:0]DDR_ba;
  inout DDR_cas_n;
  inout DDR_ck_n;
  inout DDR_ck_p;
  inout DDR_cke;
  inout DDR_cs_n;
  inout [3:0]DDR_dm;
  inout [31:0]DDR_dq;
  inout [3:0]DDR_dqs_n;
  inout [3:0]DDR_dqs_p;
  inout DDR_odt;
  inout DDR_ras_n;
  inout DDR_reset_n;
  inout DDR_we_n;
  inout FIXED_IO_ddr_vrn;
  inout FIXED_IO_ddr_vrp;
  inout [53:0]FIXED_IO_mio;
  inout FIXED_IO_ps_clk;
  inout FIXED_IO_ps_porb;
  inout FIXED_IO_ps_srstb;
  output RST_N;
  output RST_P;
  input [0:0]SCLK_N;
  input [0:0]SCLK_P;
  input [0:0]SDAT_N;
  input [0:0]SDAT_P;
  input adc_clk_n_i;
  output adc_clk_o;
  input adc_clk_p_i;
  output adc_csn;
  input [13:0]adc_dat_a_i;
  input [13:0]adc_dat_b_i;
  output error_state;

  wire [0:0]CNVST_N;
  wire [0:0]CNVST_P;
  wire [14:0]DDR_addr;
  wire [2:0]DDR_ba;
  wire DDR_cas_n;
  wire DDR_ck_n;
  wire DDR_ck_p;
  wire DDR_cke;
  wire DDR_cs_n;
  wire [3:0]DDR_dm;
  wire [31:0]DDR_dq;
  wire [3:0]DDR_dqs_n;
  wire [3:0]DDR_dqs_p;
  wire DDR_odt;
  wire DDR_ras_n;
  wire DDR_reset_n;
  wire DDR_we_n;
  wire FIXED_IO_ddr_vrn;
  wire FIXED_IO_ddr_vrp;
  wire [53:0]FIXED_IO_mio;
  wire FIXED_IO_ps_clk;
  wire FIXED_IO_ps_porb;
  wire FIXED_IO_ps_srstb;
  wire RST_N;
  wire RST_P;
  wire [0:0]SCLK_N;
  wire [0:0]SCLK_P;
  wire [0:0]SDAT_N;
  wire [0:0]SDAT_P;
  wire adc_clk_n_i;
  wire adc_clk_o;
  wire adc_clk_p_i;
  wire adc_csn;
  wire [13:0]adc_dat_a_i;
  wire [13:0]adc_dat_b_i;
  wire error_state;

  design_1 design_1_i
       (.CNVST_N(CNVST_N),
        .CNVST_P(CNVST_P),
        .DDR_addr(DDR_addr),
        .DDR_ba(DDR_ba),
        .DDR_cas_n(DDR_cas_n),
        .DDR_ck_n(DDR_ck_n),
        .DDR_ck_p(DDR_ck_p),
        .DDR_cke(DDR_cke),
        .DDR_cs_n(DDR_cs_n),
        .DDR_dm(DDR_dm),
        .DDR_dq(DDR_dq),
        .DDR_dqs_n(DDR_dqs_n),
        .DDR_dqs_p(DDR_dqs_p),
        .DDR_odt(DDR_odt),
        .DDR_ras_n(DDR_ras_n),
        .DDR_reset_n(DDR_reset_n),
        .DDR_we_n(DDR_we_n),
        .FIXED_IO_ddr_vrn(FIXED_IO_ddr_vrn),
        .FIXED_IO_ddr_vrp(FIXED_IO_ddr_vrp),
        .FIXED_IO_mio(FIXED_IO_mio),
        .FIXED_IO_ps_clk(FIXED_IO_ps_clk),
        .FIXED_IO_ps_porb(FIXED_IO_ps_porb),
        .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb),
        .RST_N(RST_N),
        .RST_P(RST_P),
        .SCLK_N(SCLK_N),
        .SCLK_P(SCLK_P),
        .SDAT_N(SDAT_N),
        .SDAT_P(SDAT_P),
        .adc_clk_n_i(adc_clk_n_i),
        .adc_clk_o(adc_clk_o),
        .adc_clk_p_i(adc_clk_p_i),
        .adc_csn(adc_csn),
        .adc_dat_a_i(adc_dat_a_i),
        .adc_dat_b_i(adc_dat_b_i),
        .error_state(error_state));
endmodule
