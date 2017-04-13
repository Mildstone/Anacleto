library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rfx_AD7641_serial_emulator_v1_0 is
	generic (
        SERIAL_DATA_LEN : integer := 18;
		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 4
	);
	port (
		-- Users to add ports here
		reset    : in STD_LOGIC;
        CNVST_in : in  STD_LOGIC;
        SCLK_out : out STD_LOGIC;
        SDAT_out : out STD_LOGIC;
        clk      : in std_logic;
        
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
end rfx_AD7641_serial_emulator_v1_0;

architecture arch_imp of rfx_AD7641_serial_emulator_v1_0 is

    signal reg0 : std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
    signal reg1 : std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
    signal pclk : std_logic;
	-- component declaration
	component rfx_AD7641_serial_emulator_v1_0_S00_AXI is
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
		reg0	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        reg1    : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0) 
		);
	end component rfx_AD7641_serial_emulator_v1_0_S00_AXI;

    component AD7641_serial_emulator is
      Generic (
       SERIAL_DATA_LEN : integer := 18
      );
      Port ( 
           reset    : in STD_LOGIC;
           clk      : in  STD_LOGIC;
           clk_ref  : in  STD_LOGIC;
           CNVST_in : in  STD_LOGIC;
           SCLK_out : out STD_LOGIC;
           SDAT_out : out STD_LOGIC;
           data_in  : in  STD_LOGIC_VECTOR (31 downto 0));
    end component;

    component prescaler is
    Port ( div : in STD_LOGIC_VECTOR (31 downto 0);
           clk : in STD_LOGIC;
           clk_out : out STD_LOGIC);
    end component;

begin

-- Instantiation of Axi Bus Interface S00_AXI
rfx_AD7641_serial_emulator_v1_0_S00_AXI_inst : rfx_AD7641_serial_emulator_v1_0_S00_AXI
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
		reg1 => reg1
	);

	-- Add user logic here
   AD7641_serial_emulator_inst : AD7641_serial_emulator
   generic map (
     SERIAL_DATA_LEN => SERIAL_DATA_LEN
   )
   port map(
     reset => not reset,
     clk   => clk,    
     clk_ref  =>  pclk,
     CNVST_in => CNVST_in,
     SCLK_out => SCLK_out,
     SDAT_out => SDAT_out,
     data_in  => reg0
   );
	-- User logic ends

   prescaler_inst : prescaler
   port map(
     div => reg1,
     clk => clk,
     clk_out => pclk
   );

end arch_imp;
