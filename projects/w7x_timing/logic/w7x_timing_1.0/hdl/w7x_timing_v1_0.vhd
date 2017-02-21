library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity w7x_timing_v1_0 is
    generic (
        STAT_COUNT : integer := 1;
        CTRL_COUNT : integer := 1;
        HEAD_COUNT : integer := 4;
        
        BRAM_SIZE  : integer := 32768;
        DATA_WIDTH : integer := 64;
        ADDR_WIDTH : integer := 15
    );
    port (
        clk_in     : in  STD_LOGIC;
        clk20_in   : in  STD_LOGIC;
        trig_in    : in  STD_LOGIC;
        clk_out    : out STD_LOGIC;
        trig_out   : out STD_LOGIC;
        state_do   : out STD_LOGIC_VECTOR (7 downto 2);
        state_led  : out STD_LOGIC_VECTOR (7 downto 0);
        power_down : out STD_LOGIC;
        -- PortA of blk_mem_gen
        bram_clka  : out  STD_LOGIC;
        bram_douta : in   STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
        bram_dina  : out  STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
        bram_addra : out  STD_LOGIC_VECTOR(ADDR_WIDTH-1 downto 0);
        bram_ena   : out  STD_LOGIC;
        bram_wea   : out  STD_LOGIC;
        bram_rsta  : out  STD_LOGIC;
        -- PortB of blk_mem_gen
        bram_addrb : out  STD_LOGIC_VECTOR(ADDR_WIDTH-1 downto 0);
        bram_clkb  : out  STD_LOGIC;
        bram_doutb : in   STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
        bram_rstb  : out  STD_LOGIC;
        -- Ports of Axi Slave Bus Interface S00_AXI
        s00_axi_clk     : in  std_logic;
        s00_axi_resetn  : in  std_logic;
        s00_axi_awaddr  : in  std_logic_vector(ADDR_WIDTH+DATA_WIDTH/32 downto 0);
        s00_axi_awprot  : in  std_logic_vector(2 downto 0);
        s00_axi_awvalid : in  std_logic;
        s00_axi_awready : out std_logic;
        s00_axi_wdata   : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        s00_axi_wstrb   : in  std_logic_vector((DATA_WIDTH/8)-1 downto 0);
        s00_axi_wvalid  : in  std_logic;
        s00_axi_wready  : out std_logic;
        s00_axi_bresp   : out std_logic_vector(1 downto 0);
        s00_axi_bvalid  : out std_logic;
        s00_axi_bready  : in  std_logic;
        s00_axi_araddr  : in  std_logic_vector(ADDR_WIDTH+DATA_WIDTH/32 downto 0);
        s00_axi_arprot  : in  std_logic_vector(2 downto 0);
        s00_axi_arvalid : in  std_logic;
        s00_axi_arready : out std_logic;
        s00_axi_rdata   : out std_logic_vector(DATA_WIDTH-1 downto 0);
        s00_axi_rresp   : out std_logic_vector(1 downto 0);
        s00_axi_rvalid  : out std_logic;
        s00_axi_rready  : in  std_logic
    );
end w7x_timing_v1_0;

architecture arch_imp of w7x_timing_v1_0 is
 -- component declaration
    component w7x_timing_v1_0_S00_AXI is
    generic (
      DATA_WIDTH : integer;
      ADDR_WIDTH : integer;
      AXI_ADDR_WIDTH : integer 
    );
    port (
     ADDR_OUT      : out   UNSIGNED(ADDR_WIDTH-1 downto 0);
     DATA_IN       : in    STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
     DATA_OUT      : out   STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
     STRB_OUT      : out   STD_LOGIC_VECTOR((DATA_WIDTH/8)-1 downto 0);
     EN_OUT        : out   STD_LOGIC;
     WE_OUT        : out   STD_LOGIC;
     -- AXI ports
     S_AXI_CLK     : in  std_logic;
     S_AXI_RESETN  : in  std_logic;
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
    CS         : out STD_LOGIC;
    CLK_EXT    : in  STD_LOGIC;
    CLK_20M    : in  STD_LOGIC;
    -- BRAM interface
    BRAM_RDATA : in   STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
    -- master clock domain
    M_CLK_I    : in  STD_LOGIC;
    M_ADDR_I   : in  UNSIGNED(ADDR_WIDTH-1 downto 0);
    M_DATA_RO  : out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
    M_DATA_WI  : in  STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
    M_STRB_WI  : in  STD_LOGIC_VECTOR(DATA_WIDTH/8-1 downto 0);
    -- slave clock domain
    S_CLK_O    : out STD_LOGIC;
    S_STAT_WI  : in  STD_LOGIC_VECTOR(STAT_COUNT*DATA_WIDTH-1 downto 0);
    --S_ADDR_WI  : in  UNSIGNED(ADDR_WIDTH-1 downto 0);
    S_DATA_WI  : in  STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
    S_STRB_WI  : in  STD_LOGIC_VECTOR(DATA_WIDTH/8-1 downto 0);
    S_HEAD_WI  : in  STD_LOGIC_VECTOR(HEAD_COUNT*DATA_WIDTH-1 downto 0);
    S_HWRT_WI  : in  STD_LOGIC;
    S_HEAD_RO  : out STD_LOGIC_VECTOR(HEAD_COUNT*DATA_WIDTH-1 downto 0);
    S_CTRL_RO  : out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
    -- shared flip-flop memory
    DATA_BUF   : inout STD_LOGIC_VECTOR((STAT_COUNT+CTRL_COUNT+HEAD_COUNT)*DATA_WIDTH-1 downto 0)
    );
    end component clock_interface;

    component w7x_timing is
    generic (
      HEAD_COUNT  : integer;
      ADDR_WIDTH  : integer;
      DATA_WIDTH  : integer
    );
    port (
    clk_in        : in  STD_LOGIC;
    ctrl_in       : in  STD_LOGIC_VECTOR(7 downto 0);
    head_in       : in  STD_LOGIC_VECTOR(HEAD_COUNT*DATA_WIDTH-1 downto 0);
    head_out      : out STD_LOGIC_VECTOR(HEAD_COUNT*DATA_WIDTH-1 downto 0);
    ctrl_strb     : out STD_LOGIC_VECTOR(7 downto 0);
    ctrl_out      : out STD_LOGIC_VECTOR(7 downto 0);
    load_head_out : out STD_LOGIC;
    index_out     : out UNSIGNED(ADDR_WIDTH-1 downto 0);
    state_out     : out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
    sample_in     : in  STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0)
    );
    end component w7x_timing;

    constant i_init     : integer := 0;
    constant i_trig     : integer := 1;
    constant i_reinit   : integer := 3;
    constant HEAD_MAX   : integer := STAT_COUNT+CTRL_COUNT+HEAD_COUNT;
    constant uHEAD_MAX  : unsigned(ADDR_WIDTH-1 downto 0) := to_unsigned(HEAD_MAX,ADDR_WIDTH);
    --constant oneaddr    : unsigned(ADDR_WIDTH-1 downto 0) := to_unsigned(1,ADDR_WIDTH);
    signal data_buf     : std_logic_vector(HEAD_MAX*DATA_WIDTH-1 downto 0);
    signal m_addr       : unsigned(ADDR_WIDTH-1 downto 0);
    signal m_rdata      : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal m_wdata      : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal m_strb       : std_logic_vector((DATA_WIDTH/8)-1 downto 0);
    signal load_head    : STD_LOGIC;
    signal index_sample : unsigned(ADDR_WIDTH-1 downto 0);
    signal staterr      : std_logic_vector(STAT_COUNT*DATA_WIDTH-1 downto 0);
    signal head_in      : std_logic_vector(HEAD_COUNT*DATA_WIDTH-1 downto 0);
    signal head_out     : std_logic_vector(HEAD_COUNT*DATA_WIDTH-1 downto 0);
    signal bctrl_in     : std_logic_vector((DATA_WIDTH/8)-1 downto 0);
    signal ctrl_in      : std_logic_vector(CTRL_COUNT*DATA_WIDTH-1 downto 0);
    signal bctrl_out    : std_logic_vector((DATA_WIDTH/8)-1 downto 0);
    signal ctrl_out     : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal ctrl_strb    : std_logic_vector((DATA_WIDTH/8)-1 downto 0);

    signal trigger      : STD_LOGIC;
    signal clk,clk_cs   : STD_LOGIC;
begin
clk_out    <= clk;
trigger    <= ctrl_in(8) or trig_in;
trig_out   <= trigger;
power_down <= clk_cs;
---- BRAM
bram_clka   <= s00_axi_clk;
bram_rsta   <= '0';
bram_addra  <= std_logic_vector(m_addr);
strb: for i in 0 to DATA_WIDTH/8-1 generate begin
  bram_dina(i*8+7 downto i*8) <= m_wdata(i*8+7 downto i*8) when m_strb(i) = '1' else bram_douta(i*8+7 downto i*8);
end generate;
-- b channel
bram_rstb  <= '0';
bram_clkb  <= clk;
bram_addrb <= std_logic_vector(index_sample+uHEAD_MAX);
---- translate control bits to bytes
ctrl: for i in 0 to 7 generate
  ctrl_out(i*8+7 downto i*8) <= (others => bctrl_out(i));
end generate ctrl;
bctrl: for i in 0 to 7 generate
  bctrl_in(i) <= trigger when i=i_trig else ctrl_in(i*8);
end generate bctrl;
---- translate DOUT states
state_do(2)  <= staterr(7); --sig
state_do(3)  <= staterr(6); --gate
state_do(4)  <= '0';
state_do(5)  <= staterr(7); --sig
state_do(6)  <= staterr(7); --sig
state_do(7)  <= staterr(7); --sig
---- translate LED states
state_led(0) <= not trigger;
state_led(1) <= clk;
state_led(2) <= staterr(7);--sig
state_led(3) <= staterr(6);--gate
state_led(4) <= bctrl_in(i_init);
state_led(5) <= bctrl_in(i_reinit);
state_led(6) <= clk_cs;
state_led(7) <= not staterr(0);--error/not ok

---- Instantiation of Axi Bus Interface S00_AXI
w7x_timing_v1_0_S00_AXI_inst : w7x_timing_v1_0_S00_AXI
    generic map (
        DATA_WIDTH     => DATA_WIDTH,
        ADDR_WIDTH     => ADDR_WIDTH,
        AXI_ADDR_WIDTH => ADDR_WIDTH+DATA_WIDTH/32+1
    )
    port map (
        ADDR_OUT      => m_addr,
        DATA_IN       => m_rdata,
        DATA_OUT      => m_wdata,
        STRB_OUT      => m_strb,
        WE_OUT        => bram_wea,
        EN_OUT        => bram_ena,
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
        S_AXI_RRESP   => s00_axi_rresp,
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
        CS         => clk_cs,
        CLK_EXT    => clk_in,
        CLK_20M    => clk20_in,
        BRAM_RDATA => bram_douta,
        M_CLK_I    => s00_axi_clk,
        M_ADDR_I   => m_addr,
        M_DATA_RO  => m_rdata,
        M_DATA_WI  => m_wdata,
        M_STRB_WI  => m_strb,
        S_CLK_O    => clk,
        S_STAT_WI  => staterr,
        --S_ADDR_WI  => oneaddr,
        S_DATA_WI  => ctrl_out,
        S_STRB_WI  => ctrl_strb,
        S_HEAD_WI  => head_out,
        S_HWRT_WI  => load_head,
        S_HEAD_RO  => head_in,
        S_CTRL_RO  => ctrl_in,
        DATA_BUF   => data_buf
      );

---- Instantiation of main program
w7x_timing_inst : w7x_timing
    generic map (
        DATA_WIDTH => DATA_WIDTH,
        ADDR_WIDTH => ADDR_WIDTH,
        HEAD_COUNT => HEAD_COUNT
    )
    port map (
       clk_in        => clk,
       ctrl_in       => bctrl_in,
       ctrl_out      => bctrl_out,
       ctrl_strb     => ctrl_strb,
       load_head_out => load_head,
       index_out     => index_sample,
       state_out     => staterr,
       head_in       => head_in,
       head_out      => head_out,
       sample_in     => bram_doutb
      );
end arch_imp;
