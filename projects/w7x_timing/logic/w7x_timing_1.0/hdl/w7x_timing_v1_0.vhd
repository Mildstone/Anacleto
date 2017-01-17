library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity w7x_timing_v1_0 is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 8
	);
	port (
		-- Users to add ports here
        clk: in STD_LOGIC;
        trig: in STD_LOGIC;
        sig: out STD_LOGIC;
        gate: out STD_LOGIC;
        prog: out STD_LOGIC;
        armed: out STD_LOGIC;
        triged: out STD_LOGIC;
        
		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Slave Bus Interface S00_AXI
		s00_axi_aclk	: in std_logic;
		s00_axi_aresetn	: in std_logic;
		s00_axi_awaddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_awprot	: in std_logic_vector(2 downto 0);
		s00_axi_awvalid	: in std_logic;
		s00_axi_awready	: out std_logic;
		s00_axi_wdata	: in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_wstrb	: in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
		s00_axi_wvalid	: in std_logic;
		s00_axi_wready	: out std_logic;
		s00_axi_bresp	: out std_logic_vector(1 downto 0);
		s00_axi_bvalid	: out std_logic;
		s00_axi_bready	: in std_logic;
		s00_axi_araddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_arprot	: in std_logic_vector(2 downto 0);
		s00_axi_arvalid	: in std_logic;
		s00_axi_arready	: out std_logic;
		s00_axi_rdata	: out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_rresp	: out std_logic_vector(1 downto 0);
		s00_axi_rvalid	: out std_logic;
		s00_axi_rready	: in std_logic
	);
end w7x_timing_v1_0;

architecture arch_imp of w7x_timing_v1_0 is

    signal transfer_bit: std_logic;
    signal transfer_0: std_logic_vector(32-1 downto 0);
    signal transfer_1: std_logic_vector(32-1 downto 0);
    signal transfer_2: std_logic_vector(32-1 downto 0);
    signal transfer_3: std_logic_vector(32-1 downto 0);
    signal transfer_4: std_logic_vector(32-1 downto 0);
    signal transfer_5: std_logic_vector(32-1 downto 0);
    signal transfer_6: std_logic_vector(32-1 downto 0);
    signal transfer_7: std_logic_vector(32-1 downto 0);
    signal transfer_8: std_logic_vector(32-1 downto 0);
    signal transfer_9: std_logic_vector(32-1 downto 0);
    signal transfer_10: std_logic_vector(32-1 downto 0);
    signal transfer_11: std_logic_vector(32-1 downto 0);
    signal transfer_12: std_logic_vector(32-1 downto 0);
    signal transfer_13: std_logic_vector(32-1 downto 0);
    signal transfer_14: std_logic_vector(32-1 downto 0);
    signal transfer_15: std_logic_vector(32-1 downto 0);
    signal transfer_16: std_logic_vector(32-1 downto 0);
    signal transfer_17: std_logic_vector(32-1 downto 0);
    signal transfer_18: std_logic_vector(32-1 downto 0);
    signal transfer_19: std_logic_vector(32-1 downto 0);
    signal transfer_20: std_logic_vector(32-1 downto 0);
    signal transfer_21: std_logic_vector(32-1 downto 0);
    signal transfer_22: std_logic_vector(32-1 downto 0);
    signal transfer_23: std_logic_vector(32-1 downto 0);
    signal transfer_24: std_logic_vector(32-1 downto 0);
    signal transfer_25: std_logic_vector(32-1 downto 0);
    signal transfer_26: std_logic_vector(32-1 downto 0);
    signal transfer_27: std_logic_vector(32-1 downto 0);
    signal transfer_28: std_logic_vector(32-1 downto 0);
    signal transfer_29: std_logic_vector(32-1 downto 0);
    signal transfer_30: std_logic_vector(32-1 downto 0);
    signal transfer_31: std_logic_vector(32-1 downto 0);
    signal transfer_32: std_logic_vector(32-1 downto 0);
    signal transfer_33: std_logic_vector(32-1 downto 0);
    signal transfer_34: std_logic_vector(32-1 downto 0);
    signal transfer_35: std_logic_vector(32-1 downto 0);
    signal transfer_36: std_logic_vector(32-1 downto 0);
    signal transfer_37: std_logic_vector(32-1 downto 0);
    signal transfer_38: std_logic_vector(32-1 downto 0);
    signal transfer_39: std_logic_vector(32-1 downto 0);
    signal transfer_40: std_logic_vector(32-1 downto 0);
    
	-- component declaration
	component w7x_timing_v1_0_S00_AXI is
		generic (
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 8
		);
		port (
		S_AXI_ACLK	: in std_logic;
		S_AXI_ARESETN	: in std_logic;
		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		S_AXI_AWVALID	: in std_logic;
		S_AXI_AWREADY	: out std_logic;
		S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		S_AXI_WVALID	: in std_logic;
		S_AXI_WREADY	: out std_logic;
		S_AXI_BRESP	: out std_logic_vector(1 downto 0);
		S_AXI_BVALID	: out std_logic;
		S_AXI_BREADY	: in std_logic;
		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		S_AXI_ARVALID	: in std_logic;
		S_AXI_ARREADY	: out std_logic;
		S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_RRESP	: out std_logic_vector(1 downto 0);
		S_AXI_RVALID	: out std_logic;
		S_AXI_RREADY	: in std_logic;
		
		OUT_REG_0: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        OUT_REG_1: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        OUT_REG_2: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        OUT_REG_3: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        OUT_REG_4: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        OUT_REG_5: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        OUT_REG_6: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        OUT_REG_7: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        OUT_REG_8: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        OUT_REG_9: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        OUT_REG_10: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        OUT_REG_11: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        OUT_REG_12: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        OUT_REG_13: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        OUT_REG_14: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        OUT_REG_15: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        OUT_REG_16: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        OUT_REG_17: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        OUT_REG_18: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        OUT_REG_19: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        OUT_REG_20: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        OUT_REG_21: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        OUT_REG_22: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        OUT_REG_23: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        OUT_REG_24: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        OUT_REG_25: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        OUT_REG_26: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        OUT_REG_27: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        OUT_REG_28: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        OUT_REG_29: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        OUT_REG_30: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        OUT_REG_31: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        OUT_REG_32: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        OUT_REG_33: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        OUT_REG_34: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        OUT_REG_35: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        OUT_REG_36: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        OUT_REG_37: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        OUT_REG_38: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        OUT_REG_39: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        OUT_REG_40: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0)
    );
	end component w7x_timing_v1_0_S00_AXI;


    component w7x_timing is
    port ( clk : in STD_LOGIC;
           trig : in STD_LOGIC;
           init : in STD_LOGIC;
           sig: out STD_LOGIC;
           gate: out STD_LOGIC;
           prog: out STD_LOGIC;
           arm: out STD_LOGIC;
           triged: out STD_LOGIC;
           delay_l : in STD_LOGIC_VECTOR (31 downto 0);
           delay_h : in STD_LOGIC_VECTOR (31 downto 0);
           wid : in STD_LOGIC_VECTOR (31 downto 0);
           period : in STD_LOGIC_VECTOR (31 downto 0);
           cycle_l : in STD_LOGIC_VECTOR (31 downto 0);
           cycle_h : in STD_LOGIC_VECTOR (31 downto 0);
           repeat : in STD_LOGIC_VECTOR (31 downto 0);
           count : in STD_LOGIC_VECTOR (31 downto 0);
           seq_0_l : in STD_LOGIC_VECTOR (31 downto 0);
           seq_0_h : in STD_LOGIC_VECTOR (31 downto 0);
           seq_1_l : in STD_LOGIC_VECTOR (31 downto 0);
           seq_1_h : in STD_LOGIC_VECTOR (31 downto 0);
           seq_2_l : in STD_LOGIC_VECTOR (31 downto 0);
           seq_2_h : in STD_LOGIC_VECTOR (31 downto 0);
           seq_3_l : in STD_LOGIC_VECTOR (31 downto 0);
           seq_3_h : in STD_LOGIC_VECTOR (31 downto 0);
           seq_4_l : in STD_LOGIC_VECTOR (31 downto 0);
           seq_4_h : in STD_LOGIC_VECTOR (31 downto 0);
           seq_5_l : in STD_LOGIC_VECTOR (31 downto 0);
           seq_5_h : in STD_LOGIC_VECTOR (31 downto 0);
           seq_6_l : in STD_LOGIC_VECTOR (31 downto 0);
           seq_6_h : in STD_LOGIC_VECTOR (31 downto 0);
           seq_7_l : in STD_LOGIC_VECTOR (31 downto 0);
           seq_7_h : in STD_LOGIC_VECTOR (31 downto 0);
           seq_8_l : in STD_LOGIC_VECTOR (31 downto 0);
           seq_8_h : in STD_LOGIC_VECTOR (31 downto 0);
           seq_9_l : in STD_LOGIC_VECTOR (31 downto 0);
           seq_9_h : in STD_LOGIC_VECTOR (31 downto 0);
           seq_10_l : in STD_LOGIC_VECTOR (31 downto 0);
           seq_10_h : in STD_LOGIC_VECTOR (31 downto 0);
           seq_11_l : in STD_LOGIC_VECTOR (31 downto 0);
           seq_11_h : in STD_LOGIC_VECTOR (31 downto 0);
           seq_12_l : in STD_LOGIC_VECTOR (31 downto 0);
           seq_12_h : in STD_LOGIC_VECTOR (31 downto 0);
           seq_13_l : in STD_LOGIC_VECTOR (31 downto 0);
           seq_13_h : in STD_LOGIC_VECTOR (31 downto 0);
           seq_14_l : in STD_LOGIC_VECTOR (31 downto 0);
           seq_14_h : in STD_LOGIC_VECTOR (31 downto 0);
           seq_15_l : in STD_LOGIC_VECTOR (31 downto 0);
           seq_15_h : in STD_LOGIC_VECTOR (31 downto 0));
           

	end component w7x_timing;




begin

-- Instantiation of Axi Bus Interface S00_AXI
w7x_timing_v1_0_S00_AXI_inst : w7x_timing_v1_0_S00_AXI
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S00_AXI_ADDR_WIDTH
	)
	port map (
		S_AXI_ACLK	=> s00_axi_aclk,
		S_AXI_ARESETN	=> s00_axi_aresetn,
		S_AXI_AWADDR	=> s00_axi_awaddr,
		S_AXI_AWPROT	=> s00_axi_awprot,
		S_AXI_AWVALID	=> s00_axi_awvalid,
		S_AXI_AWREADY	=> s00_axi_awready,
		S_AXI_WDATA	=> s00_axi_wdata,
		S_AXI_WSTRB	=> s00_axi_wstrb,
		S_AXI_WVALID	=> s00_axi_wvalid,
		S_AXI_WREADY	=> s00_axi_wready,
		S_AXI_BRESP	=> s00_axi_bresp,
		S_AXI_BVALID	=> s00_axi_bvalid,
		S_AXI_BREADY	=> s00_axi_bready,
		S_AXI_ARADDR	=> s00_axi_araddr,
		S_AXI_ARPROT	=> s00_axi_arprot,
		S_AXI_ARVALID	=> s00_axi_arvalid,
		S_AXI_ARREADY	=> s00_axi_arready,
		S_AXI_RDATA	=> s00_axi_rdata,
		S_AXI_RRESP	=> s00_axi_rresp,
		S_AXI_RVALID	=> s00_axi_rvalid,
		S_AXI_RREADY	=> s00_axi_rready,
		
		
		OUT_REG_0  => transfer_0,
		OUT_REG_1  => transfer_1,
		OUT_REG_2  => transfer_2,
		OUT_REG_3  => transfer_3,
		OUT_REG_4  => transfer_4,
		OUT_REG_5  => transfer_5,
		OUT_REG_6  => transfer_6,
		OUT_REG_7  => transfer_7,
		OUT_REG_8  => transfer_8,
		OUT_REG_9  => transfer_9,
		OUT_REG_10  => transfer_10,
		OUT_REG_11  => transfer_11,
		OUT_REG_12  => transfer_12,
		OUT_REG_13  => transfer_13,
		OUT_REG_14  => transfer_14,
		OUT_REG_15  => transfer_15,
		OUT_REG_16  => transfer_16,
		OUT_REG_17  => transfer_17,
		OUT_REG_18  => transfer_18,
		OUT_REG_19  => transfer_19,
		OUT_REG_20  => transfer_20,
		OUT_REG_21  => transfer_21,
		OUT_REG_22  => transfer_22,
		OUT_REG_23  => transfer_23,
		OUT_REG_24  => transfer_24,
		OUT_REG_25  => transfer_25,
		OUT_REG_26  => transfer_26,
		OUT_REG_27  => transfer_27,
		OUT_REG_28  => transfer_28,
		OUT_REG_29  => transfer_29,
		OUT_REG_30  => transfer_30,
		OUT_REG_31  => transfer_31,
		OUT_REG_32  => transfer_32,
		OUT_REG_33  => transfer_33,
		OUT_REG_34  => transfer_34,
		OUT_REG_35  => transfer_35,
		OUT_REG_36  => transfer_36,
		OUT_REG_37  => transfer_37,
		OUT_REG_38  => transfer_38,
		OUT_REG_39  => transfer_39,
		OUT_REG_40  => transfer_40
	);

w7x_timing_inst : w7x_timing

	port map (
           init => transfer_0(0),
           delay_l => transfer_1,
           delay_h => transfer_2,
           wid  => transfer_3,
           period  => transfer_4,
           cycle_l  => transfer_5,
           cycle_h  => transfer_6,
           repeat  => transfer_7,
           count  => transfer_8,
           seq_0_l  => transfer_9,
           seq_0_h  => transfer_10,
           seq_1_l  => transfer_11,
           seq_1_h  => transfer_12,
           seq_2_l  => transfer_13,
           seq_2_h  => transfer_14,
           seq_3_l  => transfer_15,
           seq_3_h  => transfer_16,
           seq_4_l  => transfer_17,
           seq_4_h  => transfer_18,
           seq_5_l  => transfer_19,
           seq_5_h  => transfer_20,
           seq_6_l  => transfer_21,
           seq_6_h  => transfer_22,
           seq_7_l  => transfer_23,
           seq_7_h  => transfer_24,
           seq_8_l  => transfer_25,
           seq_8_h  => transfer_26,
           seq_9_l  => transfer_27,
           seq_9_h  => transfer_28,
           seq_10_l  => transfer_29,
           seq_10_h  => transfer_30,
           seq_11_l  => transfer_31,
           seq_11_h  => transfer_32,
           seq_12_l  => transfer_33,
           seq_12_h  => transfer_34,
           seq_13_l  => transfer_35,
           seq_13_h  => transfer_36,
           seq_14_l  => transfer_37,
           seq_14_h  => transfer_38,
           seq_15_l  => transfer_39,
           seq_15_h  => transfer_40,
           clk => clk,
           trig => trig,
           prog => prog,
           sig => sig,
           gate => gate,
           triged => triged,
           arm => armed
           
      );


	-- Add user logic here

	-- User logic ends

end arch_imp;
