library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
entity clock_interface is
generic (
  STAT_COUNT : integer := 1;
  CTRL_COUNT : integer := 1;
  HEAD_COUNT : integer := 4;
  BRAM_SIZE  : integer := 32768;
  ADDR_WIDTH : integer := 15;
  DATA_WIDTH : integer := 64
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
end clock_interface;

architecture arch_imp of clock_interface is
constant DATA_COUNT: integer := STAT_COUNT+CTRL_COUNT+HEAD_COUNT;
constant STAT_MIN  : integer := 0;
constant STAT_MAX  : integer := STAT_COUNT;
constant CTRL_MIN  : integer := STAT_MAX;
constant CTRL_MAX  : integer := CTRL_MIN+CTRL_COUNT;
constant HEAD_MIN  : integer := CTRL_MAX;
constant HEAD_MAX  : integer := HEAD_MIN+HEAD_COUNT;
constant TIME_MIN  : integer := 0;
constant TIME_MAX  : integer := BRAM_SIZE;

constant STAT_BASE : integer := STAT_MIN*DATA_WIDTH;
constant STAT_HEAD : integer := STAT_MAX*DATA_WIDTH-1;
constant CTRL_BASE : integer := CTRL_MIN*DATA_WIDTH;
constant CTRL_HEAD : integer := CTRL_MAX*DATA_WIDTH-1;
constant HEAD_BASE : integer := HEAD_MIN*DATA_WIDTH;
constant HEAD_HEAD : integer := HEAD_MAX*DATA_WIDTH-1;
constant TIME_BASE : integer := TIME_MIN*DATA_WIDTH;
constant TIME_HEAD : integer := TIME_MAX*DATA_WIDTH-1;
constant offset    : unsigned(ADDR_WIDTH-1 downto 0) := to_unsigned(HEAD_MAX,ADDR_WIDTH);

type index_array is array(0 to 1) of unsigned(ADDR_WIDTH-1 downto 0);
type logic_array is array(0 to 1) of std_logic;
type strb_array  is array(0 to 1) of std_logic_vector(DATA_WIDTH/8-1 downto 0);
type data_array  is array(0 to 1) of std_logic_vector(DATA_WIDTH-1 downto 0);
type stat_array  is array(0 to 1) of std_logic_vector(STAT_COUNT*DATA_WIDTH-1 downto 0);
type ctrl_array  is array(0 to 1) of std_logic_vector(CTRL_COUNT*DATA_WIDTH-1 downto 0);
type head_array  is array(0 to 1) of std_logic_vector(HEAD_COUNT*DATA_WIDTH-1 downto 0);
signal s_stat_wi_buf : stat_array  := (others => (others => '0'));
signal s_hwrt_wi_buf : logic_array := (others => '0');
signal s_head_wi_buf : head_array  := (others => (others => '0'));
signal s_idx_wi_buf  : index_array := (others => (others => '0'));
signal s_strb_wi_buf : strb_array  := (others => (others => '0'));
signal s_data_wi_buf : data_array  := (others => (others => '0'));
signal s_ctrl_ro_buf : ctrl_array  := (others => (others => '0'));
signal s_head_ro_buf : head_array  := (others => (others => '0'));

function addr2base(addr : unsigned) return integer is
begin
  return to_integer(addr)*DATA_WIDTH;
end addr2base;

signal clock_switch  : std_logic_vector(0 to 1) := (others =>'0');
signal s_clk,clk_int : std_logic := '0';
begin
---- 10MHz clock switch
clock10MHz: process(CLK_20M) begin
  if rising_edge(CLK_20M) then
    clock_switch(1) <= DATA_BUF(13*8);
    clock_switch(0) <= clock_switch(1);
    if clock_switch(0) = '0' then
      clk_int <= not clk_int;
    end if;
  end if;
end process clock10MHz;
-- clk mux
s_clk <= CLK_EXT when clock_switch(0) = '1' else clk_int;
S_CLK_O <= s_clk;
CS <= DATA_BUF(13*8);

M_DATA_RO <= DATA_BUF(addr2base(M_ADDR_I)+DATA_WIDTH-1 downto addr2base(M_ADDR_I))
   when M_ADDR_I < offset else BRAM_RDATA;

update_buffer: process(M_CLK_I,M_ADDR_I,M_STRB_WI,M_DATA_WI)
begin
  if (rising_edge(M_CLK_I)) then
    -- handle driver write operations
    if M_ADDR_I < offset then
      for i in 0 to DATA_WIDTH/8-1 loop
        if M_STRB_WI(i) = '1' then
          DATA_BUF(addr2base(M_ADDR_I)+i*8+7 downto addr2base(M_ADDR_I)+i*8) <= M_DATA_WI(i*8+7 downto i*8);
        end if;
      end loop;
    end if;
    -- handle fpga write operations
    DATA_BUF(STAT_HEAD downto STAT_BASE) <= s_stat_wi_buf(0);
    if s_hwrt_wi_buf(0) = '1' then
      DATA_BUF(HEAD_HEAD downto HEAD_BASE) <= s_head_wi_buf(0);
    end if;
    --if s_addr_wi_buf(0) < offset then
      for i in 0 to DATA_WIDTH/8-1 loop
        if s_strb_wi_buf(0)(i) = '1' then
          --DATA_BUF(addr2base(s_addr_wi_buf(0))+i*8+7 downto addr2base(s_addr_wi_buf(0))+i*8) <=  s_data_wi_buf(0)(i*8+7 downto i*8);
          DATA_BUF(DATA_WIDTH+i*8+7 downto DATA_WIDTH+i*8) <=  s_data_wi_buf(0)(i*8+7 downto i*8);
        end if;
      end loop;
    --end if;    
  end if;
end process update_buffer;

----out   
update_in: process(M_CLK_I)
begin
  if (rising_edge(M_CLK_I)) then
    s_stat_wi_buf(0) <= s_stat_wi_buf(1);
    
    --s_addr_wi_buf(0) <= s_addr_wi_buf(1);
    s_strb_wi_buf(0) <= s_strb_wi_buf(1);
    s_data_wi_buf(0) <= s_data_wi_buf(1);
    
    s_head_wi_buf(0) <= s_head_wi_buf(1);
    s_hwrt_wi_buf(0) <= s_hwrt_wi_buf(1);
  end if;  
end process update_in;

-- two stage buf out
update_out1: process(s_clk,DATA_BUF)
begin
  if falling_edge(s_clk) then
     s_ctrl_ro_buf(1) <= DATA_BUF(CTRL_HEAD downto CTRL_BASE);
     s_head_ro_buf(1) <= DATA_BUF(HEAD_HEAD downto HEAD_BASE);     
  end if;  
end process update_out1;

update_out2: process(s_clk,S_STAT_WI,S_STRB_WI,S_DATA_WI,S_HEAD_WI,S_HWRT_WI)--S_ADDR_WI
begin
  if rising_edge(s_clk) then
    -- write
    s_stat_wi_buf(1) <= S_STAT_WI;
    
    --s_addr_wi_buf(1) <= S_ADDR_WI;
    s_strb_wi_buf(1) <= S_STRB_WI;
    s_data_wi_buf(1) <= S_DATA_WI;
    
    s_head_wi_buf(1) <= S_HEAD_WI;
    s_hwrt_wi_buf(1) <= S_HWRT_WI;
    -- read
    s_ctrl_ro_buf(0) <= s_ctrl_ro_buf(1);
    s_head_ro_buf(0) <= s_head_ro_buf(1);
  end if;
end process update_out2;
S_CTRL_RO <= s_ctrl_ro_buf(0);
S_HEAD_RO <= s_head_ro_buf(0);
end arch_imp;
