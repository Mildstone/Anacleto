library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity w7x_timing_v1_0 is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface S00_AXI
		MAX_MEMORY           : integer := 4096;
		C_S00_AXI_DATA_COUNT : integer := 128;--4096/32;
		MAX_SAMPLES          : integer := 59;--4096/64-5;
		C_S00_AXI_DATA_WIDTH : integer := 32;
		C_S00_AXI_ADDR_WIDTH : integer := 24
	);
	port (
		-- Users to add ports here
        clk  : in  STD_LOGIC;
		trig : in  STD_LOGIC;
		state: out STD_LOGIC_VECTOR (0 to 5);          
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
    type INT_BUF_TYPE is array(0 to 9) of std_logic_vector(31 downto 0);
    signal transfer : INT_BUF_TYPE;
    signal buf : std_logic_vector(MAX_SAMPLES*2*C_S00_AXI_DATA_WIDTH-1 downto 0);
 -- component declaration
	component w7x_timing_v1_0_S00_AXI is
		generic (
		C_S_AXI_DATA_COUNT  : integer;
		C_S_AXI_DATA_WIDTH	: integer;
		C_S_AXI_ADDR_WIDTH	: integer
		);
		port (
		S_AXI_ACLK    : in  std_logic;
		S_AXI_ARESETN : in  std_logic;
		S_AXI_AWADDR  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_AWPROT  : in  std_logic_vector(2 downto 0);
		S_AXI_AWVALID : in  std_logic;
		S_AXI_AWREADY : out std_logic;
		S_AXI_WDATA   : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_WSTRB   : in  std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		S_AXI_WVALID  : in  std_logic;
		S_AXI_WREADY  : out std_logic;
		S_AXI_BRESP   : out std_logic_vector(1 downto 0);
		S_AXI_BVALID  : out std_logic;
		S_AXI_BREADY  : in  std_logic;
		S_AXI_ARADDR  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_ARPROT  : in  std_logic_vector(2 downto 0);
		S_AXI_ARVALID : in  std_logic;
		S_AXI_ARREADY : out std_logic;
		S_AXI_RDATA   : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_RRESP   : out std_logic_vector(1 downto 0);
		S_AXI_RVALID  : out std_logic;
		S_AXI_RREADY  : in  std_logic;
		
		OUT_REG: out std_logic_vector(C_S_AXI_DATA_COUNT*C_S_AXI_DATA_WIDTH-1 downto 0)
    );
	end component w7x_timing_v1_0_S00_AXI;


    component w7x_timing is
        generic(
          MAX_SAMPLES : integer
        );
        port (
           clk   : in  STD_LOGIC;
           trig  : in  STD_LOGIC;
           init  : in  STD_LOGIC;
           bstate: out STD_LOGIC_VECTOR (0 to 5);
    
           width : in  STD_LOGIC_VECTOR (31 downto 0);
           period: in  STD_LOGIC_VECTOR (31 downto 0);
           repeat: in  STD_LOGIC_VECTOR (31 downto 0);
           sample: in  STD_LOGIC_VECTOR (31 downto 0);
     
           delay : in  STD_LOGIC_VECTOR (63 downto 0);
           cycle : in  STD_LOGIC_VECTOR (63 downto 0);
           seq   : in  STD_LOGIC_VECTOR (MAX_SAMPLES*64-1 downto 0)
        );
	end component w7x_timing;




begin

-- Instantiation of Axi Bus Interface S00_AXI
w7x_timing_v1_0_S00_AXI_inst : w7x_timing_v1_0_S00_AXI
	generic map (
	    C_S_AXI_DATA_COUNT => C_S00_AXI_DATA_COUNT,
		C_S_AXI_DATA_WIDTH => C_S00_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH => C_S00_AXI_ADDR_WIDTH
	)
	port map (
		S_AXI_ACLK    => s00_axi_aclk,
		S_AXI_ARESETN => s00_axi_aresetn,
		S_AXI_AWADDR  => s00_axi_awaddr,
		S_AXI_AWPROT  => s00_axi_awprot,
		S_AXI_AWVALID => s00_axi_awvalid,
		S_AXI_AWREADY => s00_axi_awready,
		S_AXI_WDATA   => s00_axi_wdata,
		S_AXI_WSTRB   => s00_axi_wstrb,
		S_AXI_WVALID  => s00_axi_wvalid,
		S_AXI_WREADY  => s00_axi_wready,
		S_AXI_BRESP   => s00_axi_bresp,
		S_AXI_BVALID  => s00_axi_bvalid,
		S_AXI_BREADY  => s00_axi_bready,
		S_AXI_ARADDR  => s00_axi_araddr,
		S_AXI_ARPROT  => s00_axi_arprot,
		S_AXI_ARVALID => s00_axi_arvalid,
		S_AXI_ARREADY => s00_axi_arready,
		S_AXI_RDATA   => s00_axi_rdata,
		S_AXI_RRESP	  => s00_axi_rresp,
		S_AXI_RVALID  => s00_axi_rvalid,
		S_AXI_RREADY  => s00_axi_rready,		
		OUT_REG(C_S00_AXI_DATA_COUNT*C_S00_AXI_DATA_WIDTH-1 downto 10*C_S00_AXI_DATA_WIDTH) => buf,
		OUT_REG(0*C_S00_AXI_DATA_WIDTH+C_S00_AXI_DATA_WIDTH-1 downto 0*C_S00_AXI_DATA_WIDTH) => transfer(0),
		OUT_REG(1*C_S00_AXI_DATA_WIDTH+C_S00_AXI_DATA_WIDTH-1 downto 1*C_S00_AXI_DATA_WIDTH) => transfer(1),
		OUT_REG(2*C_S00_AXI_DATA_WIDTH+C_S00_AXI_DATA_WIDTH-1 downto 2*C_S00_AXI_DATA_WIDTH) => transfer(2),
		OUT_REG(3*C_S00_AXI_DATA_WIDTH+C_S00_AXI_DATA_WIDTH-1 downto 3*C_S00_AXI_DATA_WIDTH) => transfer(3),
		OUT_REG(4*C_S00_AXI_DATA_WIDTH+C_S00_AXI_DATA_WIDTH-1 downto 4*C_S00_AXI_DATA_WIDTH) => transfer(4),
        OUT_REG(5*C_S00_AXI_DATA_WIDTH+C_S00_AXI_DATA_WIDTH-1 downto 5*C_S00_AXI_DATA_WIDTH) => transfer(5),
        OUT_REG(6*C_S00_AXI_DATA_WIDTH+C_S00_AXI_DATA_WIDTH-1 downto 6*C_S00_AXI_DATA_WIDTH) => transfer(6),
		OUT_REG(7*C_S00_AXI_DATA_WIDTH+C_S00_AXI_DATA_WIDTH-1 downto 7*C_S00_AXI_DATA_WIDTH) => transfer(7),
		OUT_REG(8*C_S00_AXI_DATA_WIDTH+C_S00_AXI_DATA_WIDTH-1 downto 8*C_S00_AXI_DATA_WIDTH) => transfer(8),
		OUT_REG(9*C_S00_AXI_DATA_WIDTH+C_S00_AXI_DATA_WIDTH-1 downto 9*C_S00_AXI_DATA_WIDTH) => transfer(9)
	);

w7x_timing_inst : w7x_timing
	generic map (
      MAX_SAMPLES => MAX_SAMPLES
    ) port map (
           clk    => clk,
           trig   => trig,
           bstate => state,
           init   => transfer(0)(0),
           width  => transfer(4),
           period => transfer(5),
           repeat => transfer(8),
           sample => transfer(9),
           delay(31 downto 0)  => transfer(2),
           delay(63 downto 32) => transfer(3),
           cycle(31 downto 0)  => transfer(6),
           cycle(63 downto 32) => transfer(7),
           seq => buf
      );
end arch_imp;
