library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rfx_AD7641_serial_slave_v1_0 is
	generic (
		-- Users to add parameters here
		-- User parameters ends
		-- Do not modify the parameters beyond this line
        SERIAL_DATA_LEN : integer := 18;
        TIME_MULT       : integer := 1000000;
--        STORE_TICS : integer := 250000000;
--        CNVST_HI   : integer :=  20000000;
--        CNVST_LO   : integer := 380000000;

		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 4
	);
	port (
		-- Users to add ports here
		reset       : in   std_logic;
        SDAT_in     : in   std_logic; 
        SCLK_in     : in   std_logic; 
        CNVST_out   : out  std_logic; 
        error_state   : out  std_logic;
        RST_P   : out  std_logic;
        RST_N   : out  std_logic;
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
end rfx_AD7641_serial_slave_v1_0;

architecture arch_imp of rfx_AD7641_serial_slave_v1_0 is
  
    signal reg0 : std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
    signal reg1 : std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
    signal reg2 : std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
    signal reg3 : std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
    
	-- component declaration
	component rfx_AD7641_serial_slave_v1_0_S00_AXI is
		generic (
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 4
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
		reg0 : out  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		reg1 : out  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		reg2 : out  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		reg3 : in   std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0)
		);
	end component rfx_AD7641_serial_slave_v1_0_S00_AXI;

    component AD7641_serial_slave is
     Generic (
           SERIAL_DATA_LEN : integer := 18;
           TIME_MULT       : integer := 100000
     );
     Port ( 
           store_tics      : in   integer;
           cnvst_hi_tics   : in   integer;
           cnvst_lo_tics   : in   integer;
           data_out        : out  std_logic_vector (31 downto 0);
           
           error_out   : out  std_logic;
           clk         : in   std_logic;
           reset       : in   std_logic; 
           SDAT_in     : in   std_logic; 
           SCLK_in     : in   std_logic;
           CNVST_in    : in   std_logic; 
           CNVST_out   : out  std_logic;
           RST_P   : out  std_logic;
           RST_N   : out  std_logic
           );
    end component AD7641_serial_slave;

begin

-- Instantiation of Axi Bus Interface S00_AXI
rfx_AD7641_serial_slave_v1_0_S00_AXI_inst : rfx_AD7641_serial_slave_v1_0_S00_AXI
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
		reg0 => reg0,
		reg1 => reg1,
		reg2 => reg2,
		reg3 => reg3

	);

	-- Add user logic here
AD7641_serial_slave_inst : AD7641_serial_slave
   generic map(
    SERIAL_DATA_LEN => SERIAL_DATA_LEN,
    TIME_MULT => TIME_MULT
   )
   port map (
     store_tics    => to_integer(signed(reg0)),
     cnvst_hi_tics => to_integer(signed(reg1)),
     cnvst_lo_tics => to_integer(signed(reg2)),
     data_out      => reg3,
     
     clk => s00_axi_aclk,
     reset => reset,
     SDAT_in => SDAT_in,
     SCLK_in => SCLK_in,
     CNVST_in => '0',
     CNVST_out => CNVST_out,
     error_out => error_state,
     		------ Marco port map for reset ----
     rst_p => RST_P,
     rst_n => RST_N
   );   
	-- User logic ends

end arch_imp;
