library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity w7x_timing_v1_0 is
    generic (
        BRAM_SIZE  : integer := 54272;
        BRAM_WIDTH : integer := 40;
        DATA_WIDTH : integer := 64;
        ADDR_WIDTH : integer := 16
    );
    port (
        clk_axi_in : in  std_logic;
        clk_in     : in  STD_LOGIC;
        clk20_in   : in  STD_LOGIC;
        trig_in    : in  STD_LOGIC;
        state_do   : out STD_LOGIC_VECTOR (7 downto 2);
        state_led  : out STD_LOGIC_VECTOR (7 downto 0);
        power_down : out STD_LOGIC;
        -- PortA of blk_mem_gen
        bram_clka  : out  STD_LOGIC;
        bram_douta : in   STD_LOGIC_VECTOR(BRAM_WIDTH-1 downto 0);
        bram_dina  : out  STD_LOGIC_VECTOR(BRAM_WIDTH-1 downto 0);
        bram_addra : out  STD_LOGIC_VECTOR(ADDR_WIDTH-1 downto 0);
        bram_ena   : out  STD_LOGIC;
        bram_wea   : out  STD_LOGIC;
        bram_rsta  : out  STD_LOGIC;
        -- PortB of blk_mem_gen
        bram_addrb : out  STD_LOGIC_VECTOR(ADDR_WIDTH-1 downto 0);
        bram_clkb  : out  STD_LOGIC;
        bram_doutb : in   STD_LOGIC_VECTOR(BRAM_WIDTH-1 downto 0);
        bram_rstb  : out  STD_LOGIC;
        -- Ports of Axi Slave Bus Interface S00_AXI
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
      DATA_WIDTH     : integer;
      ADDR_WIDTH     : integer;
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

    component w7x_timing is
    generic (
      HEAD_COUNT  : integer;
      ADDR_WIDTH  : integer;
      TIME_WIDTH  : integer;
      DATA_WIDTH  : integer
    );
    port (
    clk_in     : in  STD_LOGIC;
    trigger_in : in  STD_LOGIC;
    armed_in   : in  STD_LOGIC;
    clear_in   : in  STD_LOGIC;
    head_in    : in  STD_LOGIC_VECTOR(HEAD_COUNT*DATA_WIDTH-1 downto 0);
    sample_in  : in  STD_LOGIC_VECTOR(TIME_WIDTH-1 downto 0);
    index_out  : out UNSIGNED(ADDR_WIDTH-1 downto 0);
    state_out  : out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0)
    );
    end component w7x_timing;

    constant STAT_COUNT: integer := 1;
    constant CTRL_COUNT: integer := 1;
    constant HEAD_COUNT: integer := 6;
    constant DATA_COUNT: integer := 8;
    constant STAT_MIN  : integer := 0;
    constant STAT_MAX  : integer := STAT_COUNT;
    constant CTRL_MIN  : integer := STAT_MAX;
    constant CTRL_MAX  : integer := CTRL_MIN+CTRL_COUNT;
    constant HEAD_MIN  : integer := CTRL_MAX;
    constant HEAD_MAX  : integer := HEAD_MIN+HEAD_COUNT;
    
    constant STAT_BASE : integer := STAT_MIN*DATA_WIDTH;
    constant STAT_HEAD : integer := STAT_MAX*DATA_WIDTH-1;
    constant CTRL_BASE : integer := CTRL_MIN*DATA_WIDTH;
    constant CTRL_HEAD : integer := CTRL_MAX*DATA_WIDTH-1;
    constant HEAD_BASE : integer := HEAD_MIN*DATA_WIDTH;
    constant HEAD_HEAD : integer := HEAD_MAX*DATA_WIDTH-1;
    constant offset    : unsigned(ADDR_WIDTH-1 downto 0) := to_unsigned(DATA_COUNT,ADDR_WIDTH);

    function addr2base(addr : unsigned) return integer is begin
      return to_integer(addr)*DATA_WIDTH;
    end addr2base;
    signal m_addr    : unsigned(ADDR_WIDTH-1 downto 0);
    signal m_rdata   : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal m_wdata   : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal m_strb    : std_logic_vector((DATA_WIDTH/8)-1 downto 0);
    signal s_addr    : unsigned(ADDR_WIDTH-1 downto 0);

    signal state     : std_logic_vector(STAT_COUNT*DATA_WIDTH-1 downto 0);
    signal head_save : std_logic_vector(HEAD_COUNT*DATA_WIDTH-1 downto 0) := (others => '0');

    signal data_buf  : std_logic_vector(HEAD_HEAD               downto 0) := (others => '0');
    alias  state_buf : std_logic_vector(STAT_COUNT*DATA_WIDTH-1 downto 0) is data_buf(STAT_HEAD downto STAT_BASE);
    alias  ctrl_buf  : std_logic_vector(CTRL_COUNT*DATA_WIDTH-1 downto 0) is data_buf(CTRL_HEAD downto CTRL_BASE);
    alias  head_buf  : std_logic_vector(HEAD_COUNT*DATA_WIDTH-1 downto 0) is data_buf(HEAD_HEAD downto HEAD_BASE);
    
    signal bram_douta_buf : std_logic_vector(BRAM_WIDTH-1 downto 0);

    alias c_init     : std_logic_vector(7 downto 0) is ctrl_buf(0*8+7 downto 0*8);
    alias c_trig     : std_logic_vector(7 downto 0) is ctrl_buf(1*8+7 downto 1*8);
    alias c_clear    : std_logic_vector(7 downto 0) is ctrl_buf(2*8+7 downto 2*8);
    alias c_reinit   : std_logic_vector(7 downto 0) is ctrl_buf(3*8+7 downto 3*8);
    alias c_save     : std_logic_vector(7 downto 0) is ctrl_buf(4*8+7 downto 4*8);
    alias c_extclk   : std_logic_vector(7 downto 0) is ctrl_buf(5*8+7 downto 5*8);
    alias c_invert   : std_logic_vector(7 downto 0) is ctrl_buf(6*8+7 downto 6*8);
    alias c_gate     : std_logic_vector(7 downto 0) is ctrl_buf(7*8+7 downto 7*8);

    signal trigger   : std_logic;
    alias  sig       : std_logic is state(7);
    alias  gate      : std_logic is state(6);
    alias  armed     : std_logic is state(3);
    alias  ok        : std_logic is state(0);

    signal clk       : std_logic := '0';
    signal clk_int   : std_logic := '0';
    
begin
---- 10MHz clock switch
clock10MHz: process(clk20_in) begin
  if rising_edge(clk20_in) then
    clk_int <= not clk_int;
  end if;
end process clock10MHz;
clk <= clk_in when c_extclk(0) = '1' else clk_int;

trigger    <= c_trig(0) or trig_in;
power_down <= c_extclk(0);
---- BRAM
bram_clka   <= clk_axi_in;
bram_rsta   <= '0';
bram_addra  <= std_logic_vector(m_addr-offset);
bram_update: process(clk_axi_in,m_strb,m_wdata,bram_douta) begin
  if rising_edge(clk_axi_in) then
    bram_douta_buf <= bram_douta;
    for i in 0 to BRAM_WIDTH/8-1 loop
      if m_strb(i) = '1'
      then bram_dina(i*8+7 downto i*8) <= m_wdata(i*8+7 downto i*8);
      else bram_dina(i*8+7 downto i*8) <= bram_douta_buf(i*8+7 downto i*8);
      end if;
    end loop;
  end if;
end process bram_update;
m_rdata(BRAM_WIDTH-1 downto 0)          <= data_buf(addr2base(m_addr)+BRAM_WIDTH-1 downto addr2base(m_addr))
   when m_addr < offset else bram_douta;
m_rdata(DATA_WIDTH-1 downto BRAM_WIDTH) <= data_buf(addr2base(m_addr)+DATA_WIDTH-1 downto addr2base(m_addr)+BRAM_WIDTH)
   when m_addr < offset else (others => '0');

-- b channel
bram_rstb  <= '0';
bram_clkb  <= clk;
bram_addrb <= std_logic_vector(s_addr);
---- translate DOUT states
output: for i in 2 to 7 generate
  state_do(i) <= not gate when (c_invert(i) and     c_gate(i)) = '1'
            else not sig  when (c_invert(i) and not c_gate(i)) = '1'
            else sig      when (c_invert(i) or      c_gate(i)) = '0'
            else gate;
end generate output;

---- translate LED states
state_led(0) <= not trigger;
state_led(1) <= clk;
state_led(2) <= sig;--sig
state_led(3) <= gate;--gate
state_led(4) <= c_init(0);
state_led(5) <= c_reinit(0);
state_led(6) <= c_extclk(0);
state_led(7) <= not state(0);--error/not ok

----DATA_BUF
update_buffer: process(clk_axi_in,m_addr,m_strb,m_wdata,head_save,data_buf,state)
begin
  if rising_edge(clk_axi_in) then
    -- handle driver write operations
    if m_addr < offset then
      for i in 0 to DATA_WIDTH/8-1 loop
        if m_strb(i) = '1' then
          data_buf(addr2base(m_addr)+i*8+7 downto addr2base(m_addr)+i*8) <= m_wdata(i*8+7 downto i*8);
        end if;
      end loop;
    end if;
    -- handle fpga write operations
    state_buf <= state;
    if armed = '0' then
      c_trig <= (others => '0');
    elsif c_reinit(0) = '1' then
      head_buf <= head_save;
    end if;
    if ok = '1' then
      c_clear <= (others => '0');
    end if;
    if c_save(0) = '1' then
      head_save <= head_buf;
      c_save <= (others => '0');
    end if;
  end if;
end process update_buffer;

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
        S_AXI_CLK     => clk_axi_in,
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

---- Instantiation of main program
w7x_timing_inst : w7x_timing
    generic map (
        DATA_WIDTH => DATA_WIDTH,
        TIME_WIDTH => BRAM_WIDTH,
        ADDR_WIDTH => ADDR_WIDTH,
        HEAD_COUNT => HEAD_COUNT
    )
    port map (
       clk_in        => clk,
       trigger_in    => trigger,
       armed_in      => c_init(0),
       clear_in      => c_clear(0),
       index_out     => s_addr,
       state_out     => state,
       head_in       => head_buf,
       sample_in     => bram_doutb
      );
end arch_imp;
