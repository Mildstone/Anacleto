library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity w7x_timing_v1_0 is
	generic (
		-- Users to add parameters here
		HEADER_SIZE          : integer := 5;
        MAX_SAMPLES          : integer := 16;
        TIME_WIDTH           : integer := 40;  -- ca 30h @ 10MHz
		-- User parameters ends
		-- Do not modify the parameters beyond this line

		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_DATA_WIDTH : integer := 64;
		C_S00_AXI_ADDR_WIDTH : integer := 25
	);
	port (
		-- Users to add ports here
        clk  : in  STD_LOGIC;
		trig : in  STD_LOGIC;
		state: out STD_LOGIC_VECTOR (0 to 5);          
        -- User ports ends
		-- Do not modify the ports beyond this line

		-- Ports of Axi Slave Bus Interface S00_AXI
		s00_axi_aclk	: in  std_logic;
		s00_axi_aresetn	: in  std_logic;
		s00_axi_awaddr  : in  std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_awprot	: in  std_logic_vector(2 downto 0);
		s00_axi_awvalid	: in  std_logic;
		s00_axi_awready	: out std_logic;
		s00_axi_wdata	: in  std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_wstrb	: in  std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
		s00_axi_wvalid	: in  std_logic;
		s00_axi_wready	: out std_logic;
		s00_axi_bresp	: out std_logic_vector(1 downto 0);
		s00_axi_bvalid	: out std_logic;
		s00_axi_bready	: in  std_logic;
		s00_axi_araddr	: in  std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_arprot	: in  std_logic_vector(2 downto 0);
		s00_axi_arvalid	: in  std_logic;
		s00_axi_arready	: out std_logic;
		s00_axi_rdata	: out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_rresp	: out std_logic_vector(1 downto 0);
		s00_axi_rvalid	: out std_logic;
		s00_axi_rready	: in  std_logic
	);
end w7x_timing_v1_0;

architecture arch_imp of w7x_timing_v1_0 is
    signal index        : std_logic_vector(31 downto 0);
    signal initNtrig    : std_logic_vector(63 downto 0);
    signal delay        : std_logic_vector(63 downto 0);
    signal widthNperiod : std_logic_vector(63 downto 0);
    signal cycle        : std_logic_vector(63 downto 0);
    signal repeatNcount : std_logic_vector(63 downto 0);
    signal sample       : std_logic_vector(63 downto 0);
 -- component declaration
	component w7x_timing_v1_0_S00_AXI is
	generic (
		C_S_AXI_HEAD_COUNT  : integer;
        C_S_AXI_DATA_COUNT  : integer;
		C_S_AXI_DATA_WIDTH	: integer;
		C_S_AXI_ADDR_WIDTH	: integer
	);
	port (
        USR_CLK       : in  std_logic;
		DATA_INDEX    : in  std_logic_vector(31 downto 0);
		HEAD_OUT      : out std_logic_vector(C_S_AXI_HEAD_COUNT*C_S_AXI_DATA_WIDTH-1 downto 0);		
		DATA_OUT      : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);

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
		S_AXI_RREADY  : in  std_logic
    );
	end component w7x_timing_v1_0_S00_AXI;


    component w7x_timing is
    generic (
      TIME_WIDTH : integer
    );
    port (
       clk   : in  STD_LOGIC;
       trig  : in  STD_LOGIC;
       init  : in  STD_LOGIC;
       bstate: out STD_LOGIC_VECTOR (0 to 5);
       index:  out STD_LOGIC_VECTOR (31 downto 0);
       delay : in  STD_LOGIC_VECTOR (63 downto 0);
       width : in  STD_LOGIC_VECTOR (31 downto 0);
       period: in  STD_LOGIC_VECTOR (31 downto 0);
       cycle : in  STD_LOGIC_VECTOR (63 downto 0);
       repeat: in  STD_LOGIC_VECTOR (31 downto 0);
       count : in  STD_LOGIC_VECTOR (31 downto 0);
       sample: in  STD_LOGIC_VECTOR (63 downto 0)
    );
	end component w7x_timing;




begin

-- Instantiation of Axi Bus Interface S00_AXI
w7x_timing_v1_0_S00_AXI_inst : w7x_timing_v1_0_S00_AXI
	generic map (
	    C_S_AXI_HEAD_COUNT => HEADER_SIZE,
	    C_S_AXI_DATA_COUNT => MAX_SAMPLES,
		C_S_AXI_DATA_WIDTH => C_S00_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH => C_S00_AXI_ADDR_WIDTH
	)
	port map (
        USR_CLK => clk,
        DATA_INDEX => index,
		HEAD_OUT(0*C_S00_AXI_DATA_WIDTH+C_S00_AXI_DATA_WIDTH-1 downto 0*C_S00_AXI_DATA_WIDTH) => initNtrig,
        HEAD_OUT(1*C_S00_AXI_DATA_WIDTH+C_S00_AXI_DATA_WIDTH-1 downto 1*C_S00_AXI_DATA_WIDTH) => delay,
        HEAD_OUT(2*C_S00_AXI_DATA_WIDTH+C_S00_AXI_DATA_WIDTH-1 downto 2*C_S00_AXI_DATA_WIDTH) => widthNperiod,
        HEAD_OUT(3*C_S00_AXI_DATA_WIDTH+C_S00_AXI_DATA_WIDTH-1 downto 3*C_S00_AXI_DATA_WIDTH) => cycle,
        HEAD_OUT(4*C_S00_AXI_DATA_WIDTH+C_S00_AXI_DATA_WIDTH-1 downto 4*C_S00_AXI_DATA_WIDTH) => repeatNcount,
        DATA_OUT(C_S00_AXI_DATA_WIDTH-1 downto 0) => sample,
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
		S_AXI_RREADY  => s00_axi_rready	
	);

w7x_timing_inst : w7x_timing
	generic map (
        TIME_WIDTH => TIME_WIDTH
    )
    port map (
           clk    => clk,
           trig   => trig,
           bstate => state,
           index  => index,
           init   => initNtrig(0),
           delay  => delay,
           width  => widthNperiod(31 downto  0),
           period => widthNperiod(63 downto 32),
           cycle  => cycle,
           repeat => repeatNcount(31 downto  0),
           count  => repeatNcount(63 downto 32),
           sample  => sample
      );
end arch_imp;
