library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity w7x_timing_v1_0 is
	generic (
		STAT_COUNT           : integer := 1;
		CTRL_COUNT           : integer := 1;
		HEAD_COUNT           : integer := 4;
		
        BRAM_SIZE            : integer := 32768;
		DATA_WIDTH : integer := 64;
		ADDR_WIDTH : integer := 15
	);
	port (
        clk_in   : in  STD_LOGIC;
		trig_in  : in  STD_LOGIC;
		state_out: out STD_LOGIC_VECTOR (5 downto 0);
        -- PortA of blk_mem_gen
        bram_addra : out  STD_LOGIC_VECTOR(14 downto 0);
        bram_clka  : out  STD_LOGIC;
        bram_dina  : out  STD_LOGIC_VECTOR(63 downto 0);
        bram_wea   : out  STD_LOGIC_VECTOR( 0 downto 0);
        bram_rsta  : out  STD_LOGIC;
        -- PortB of blk_mem_gen
        bram_addrb : out  STD_LOGIC_VECTOR(14 downto 0);
        bram_clkb  : out  STD_LOGIC;
        bram_doutb : in   STD_LOGIC_VECTOR(63 downto 0);
        bram_rstb  : out  STD_LOGIC;
		-- Ports of Axi Slave Bus Interface S00_AXI
		s00_axi_clk	    : in  std_logic;
		s00_axi_resetn	: in  std_logic;
		s00_axi_awaddr  : in  std_logic_vector(ADDR_WIDTH+DATA_WIDTH/32 downto 0);
		s00_axi_awprot	: in  std_logic_vector(2 downto 0);
		s00_axi_awvalid	: in  std_logic;
		s00_axi_awready	: out std_logic;
		s00_axi_wdata	: in  std_logic_vector(DATA_WIDTH-1 downto 0);
		s00_axi_wstrb	: in  std_logic_vector((DATA_WIDTH/8)-1 downto 0);
		s00_axi_wvalid	: in  std_logic;
		s00_axi_wready	: out std_logic;
		s00_axi_bresp	: out std_logic_vector(1 downto 0);
		s00_axi_bvalid	: out std_logic;
		s00_axi_bready	: in  std_logic;
		s00_axi_araddr	: in  std_logic_vector(ADDR_WIDTH+DATA_WIDTH/32 downto 0);
		s00_axi_arprot	: in  std_logic_vector(2 downto 0);
		s00_axi_arvalid	: in  std_logic;
		s00_axi_arready	: out std_logic;
		s00_axi_rdata	: out std_logic_vector(DATA_WIDTH-1 downto 0);
		s00_axi_rresp	: out std_logic_vector(1 downto 0);
		s00_axi_rvalid	: out std_logic;
		s00_axi_rready	: in  std_logic
	);
end w7x_timing_v1_0;

architecture arch_imp of w7x_timing_v1_0 is
    constant HEAD_MAX   : integer := STAT_COUNT+CTRL_COUNT+HEAD_COUNT;
    constant TOTAL_MEM  : integer := HEAD_MAX + BRAM_SIZE;
    signal data_buf     : STD_LOGIC_VECTOR(HEAD_MAX*DATA_WIDTH-1 downto 0);
    signal m_addr       : UNSIGNED(ADDR_WIDTH-1 downto 0);
    signal m_strb       : STD_LOGIC_VECTOR((DATA_WIDTH/8)-1 downto 0);
    signal m_data       : STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
    signal m_rst        : STD_LOGIC;
    signal load_head    : STD_LOGIC;
    --signal index_raw    : integer;
    signal index_sample : integer;
    --signal sample       : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal stat         : std_logic_vector(STAT_COUNT*DATA_WIDTH-1 downto 0);
    signal head_in      : std_logic_vector(HEAD_COUNT*DATA_WIDTH-1 downto 0);
    signal head_out     : std_logic_vector(HEAD_COUNT*DATA_WIDTH-1 downto 0);
    signal bctrl_in     : STD_LOGIC_VECTOR((DATA_WIDTH/8)-1 downto 0);
    signal ctrl_in      : std_logic_vector(CTRL_COUNT*DATA_WIDTH-1 downto 0);
    signal bctrl_out    : STD_LOGIC_VECTOR((DATA_WIDTH/8)-1 downto 0);
    signal ctrl_out     : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal ctrl_strb    : STD_LOGIC_VECTOR((DATA_WIDTH/8)-1 downto 0);

    signal trigger      : std_logic;
 -- component declaration
	component w7x_timing_v1_0_S00_AXI is
	generic (
      DATA_COUNT : integer;
      DATA_WIDTH : integer;
      ADDR_WIDTH : integer;
      AXI_ADDR_WIDTH : integer 
    );
    port (
     DATA_BUF      : inout STD_LOGIC_VECTOR(DATA_COUNT*DATA_WIDTH-1 downto 0);
     ADDR_OUT      : out   UNSIGNED(ADDR_WIDTH-1 downto 0);
     STRB_OUT      : out   STD_LOGIC_VECTOR((DATA_WIDTH/8)-1 downto 0);
     DATA_OUT      : out   STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
     RST_OUT       : out   STD_LOGIC;
      
     -- AXI ports
     S_AXI_CLK    : in  std_logic;
     S_AXI_RESETN : in  std_logic;
     S_AXI_AWADDR  : in  std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
     S_AXI_AWPROT  : in  std_logic_vector(2 downto 0);
     S_AXI_AWVALID : in  std_logic;
     S_AXI_AWREADY : out std_logic;
     S_AXI_WDATA   : in  std_logic_vector(DATA_WIDTH-1 downto 0);
     S_AXI_WSTRB   : in  std_logic_vector((DATA_WIDTH/8)-1 downto 0);
     S_AXI_WVALID  : in  std_logic;
     S_AXI_WREADY  : out std_logic;
     S_AXI_BRESP   : out std_logic_vector(1 downto 0);
     S_AXI_BVALID  : out std_logic;
     S_AXI_BREADY  : in  std_logic;
     S_AXI_ARADDR  : in  std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
     S_AXI_ARPROT  : in  std_logic_vector(2 downto 0);
     S_AXI_ARVALID : in  std_logic;
     S_AXI_ARREADY : out std_logic;
     S_AXI_RDATA   : out std_logic_vector(DATA_WIDTH-1 downto 0);
     S_AXI_RRESP   : out std_logic_vector(1 downto 0);
     S_AXI_RVALID  : out std_logic;
     S_AXI_RREADY  : in  std_logic
    );
	end component w7x_timing_v1_0_S00_AXI;

    component clock_interface is
    generic (
      STAT_COUNT : integer;
      CTRL_COUNT : integer;
      HEAD_COUNT : integer;
      BRAM_SIZE  : integer;      
      ADDR_WIDTH : integer;
      DATA_WIDTH : integer
    );
    port (
    -- BRAM interface
    BRAM_WADDR : out  STD_LOGIC_VECTOR(14 downto 0);
    BRAM_WCLK  : out  STD_LOGIC;
    BRAM_WDATA : out  STD_LOGIC_VECTOR(63 downto 0);
    BRAM_WE    : out  STD_LOGIC_VECTOR( 0 downto 0);
    --BRAM_RADDR : out  STD_LOGIC_VECTOR(14 downto 0);
    --BRAM_RCLK  : out  STD_LOGIC;
    --BRAM_RDATA : in   STD_LOGIC_VECTOR(63 downto 0);
    -- master clock domain
    M_CLK_I    : in  STD_LOGIC;
    M_RST_I    : in  STD_LOGIC;
    M_ADDR_I   : in  UNSIGNED(ADDR_WIDTH-1 downto 0);
    M_DATA_WI  : in  STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
    M_STRB_WI  : in  STD_LOGIC_VECTOR(DATA_WIDTH/8-1 downto 0);
    -- slave clock domain
    S_CLK_I    : in  STD_LOGIC;
    S_STAT_WI  : in  STD_LOGIC_VECTOR(STAT_COUNT*DATA_WIDTH-1 downto 0);
    S_IDX_WI   : in  INTEGER;
    S_DATA_WI  : in  STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
    S_STRB_WI  : in  STD_LOGIC_VECTOR(DATA_WIDTH/8-1 downto 0);
    S_HEAD_WI  : in  STD_LOGIC_VECTOR(HEAD_COUNT*DATA_WIDTH-1 downto 0);
    S_HWRT_WI  : in  STD_LOGIC;
    --S_IDX_RI   : in  INTEGER;
    --S_DATA_RO  : out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
    S_HEAD_RO  : out STD_LOGIC_VECTOR(HEAD_COUNT*DATA_WIDTH-1 downto 0);  
    S_CTRL_RO  : out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
    -- shared flip-flop memory
    DATA_BUF   : inout STD_LOGIC_VECTOR((STAT_COUNT+CTRL_COUNT+HEAD_COUNT)*DATA_WIDTH-1 downto 0)
    );
    end component clock_interface;

    component w7x_timing is
    generic (
      ERROR_COUNT : integer
    );
    port (
    clk_in        : in  STD_LOGIC;
    ctrl_in       : in  STD_LOGIC_VECTOR(7 downto 0);
    head_in       : in  STD_LOGIC_VECTOR(4*64-1 downto 0);
    head_out      : out STD_LOGIC_VECTOR(4*64-1 downto 0);
    ctrl_strb     : out STD_LOGIC_VECTOR(7 downto 0);
    ctrl_out      : out STD_LOGIC_VECTOR(7 downto 0);
    load_head_out : out STD_LOGIC;
    index_out     : out integer;
    state_out     : out STD_LOGIC_VECTOR(7 downto 0);
    error_out     : out STD_LOGIC_VECTOR(ERROR_COUNT*8-1 downto 0);
    sample_in     : in  STD_LOGIC_VECTOR(63 downto 0)
    );
	end component w7x_timing;

begin
---- BRAM
-- wire the read access to bram
bram_clkb  <= clk_in;
bram_addrb <= std_logic_vector(to_unsigned(index_sample,ADDR_WIDTH));
bram_rsta <= '0';
bram_rstb <= '0';
---- translate control bits to bytes
ctrl_out <= (0 => bctrl_out(0),
             8 => bctrl_out(1),
            16 => bctrl_out(2),
            24 => bctrl_out(3),
            32 => bctrl_out(4),
            40 => bctrl_out(2),
            48 => bctrl_out(3),
            56 => bctrl_out(4),
            others =>'0');
bctrl_in <= (0 => ctrl_in( 0),
             1 => ctrl_in( 8) or trig_in,
             2 => ctrl_in(16),
             3 => ctrl_in(24),
             4 => ctrl_in(32),
             5 => ctrl_in(40),
             6 => ctrl_in(48),
             7 => ctrl_in(56));
---- translate software state to LED/DOUT state
process (clk_in,stat)
variable idx : integer; 
begin
  if rising_edge(clk_in) then
    for i in 0 to 4 loop
      state_out(i) <= stat(7-i);
    end loop; 
    state_out(5)   <= not stat(0);
  end if;
end process;
 

---- Instantiation of Axi Bus Interface S00_AXI
w7x_timing_v1_0_S00_AXI_inst : w7x_timing_v1_0_S00_AXI
	generic map (
	    DATA_COUNT => HEAD_MAX,
		DATA_WIDTH => DATA_WIDTH,
		ADDR_WIDTH => ADDR_WIDTH,
		AXI_ADDR_WIDTH => ADDR_WIDTH+DATA_WIDTH/32+1
	)
	port map (
        DATA_BUF      => data_buf,
	    ADDR_OUT      => m_addr,
        STRB_OUT      => m_strb,
        DATA_OUT      => m_data,
	    RST_OUT       => m_rst,
		S_AXI_CLK     => s00_axi_clk,
		S_AXI_RESETN  => s00_axi_resetn,
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

---- Instantiation of clock_interface
w7x_timing_clock_interface_inst : clock_interface
	generic map (
	    STAT_COUNT => STAT_COUNT,
	    CTRL_COUNT => CTRL_COUNT,
	    HEAD_COUNT => HEAD_COUNT,	    
	    BRAM_SIZE  => BRAM_SIZE,
	    ADDR_WIDTH => ADDR_WIDTH,
        DATA_WIDTH => DATA_WIDTH
    )
    port map (
        BRAM_WADDR => bram_addra,
        BRAM_WCLK  => bram_clka,
        BRAM_WDATA => bram_dina,
        BRAM_WE    => bram_wea,
        --BRAM_RADDR => bram_addrb,
        --BRAM_RCLK  => bram_clkb,
        --BRAM_RDATA => bram_doutb,
        M_CLK_I    => s00_axi_clk,
        S_CLK_I    => clk_in,
        M_RST_I    => m_rst,
        M_ADDR_I   => m_addr,
        M_DATA_WI  => m_data,
        M_STRB_WI  => m_strb,
        S_STAT_WI  => stat,
        S_IDX_WI   => 1,
        S_DATA_WI  => ctrl_out,
        S_STRB_WI  => ctrl_strb,
        S_HEAD_WI  => head_out,
        S_HWRT_WI  => load_head,
        --S_IDX_RI   => index_raw,
        --S_DATA_RO  => sample,
        S_HEAD_RO  => head_in,
        S_CTRL_RO  => ctrl_in,
        DATA_BUF   => data_buf
      );

---- Instantiation of main program
w7x_timing_inst : w7x_timing
	generic map (
        ERROR_COUNT => STAT_COUNT*DATA_WIDTH/8-1
    )
    port map (
           clk_in        => clk_in,
           ctrl_in       => bctrl_in,
           ctrl_out      => bctrl_out,
           ctrl_strb     => ctrl_strb,
           load_head_out => load_head,
           index_out     => index_sample,
           state_out     => stat(7 downto 0),
           error_out     => stat(STAT_COUNT*DATA_WIDTH-1 downto 8),
           head_in       => head_in,
           head_out      => head_out,
           sample_in     => bram_doutb
      );
end arch_imp;
