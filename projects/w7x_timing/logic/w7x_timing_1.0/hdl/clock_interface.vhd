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
  -- BRAM interface
  BRAM_RDATA : in   STD_LOGIC_VECTOR(63 downto 0);
  -- master clock domain
  M_CLK_I    : in  STD_LOGIC;
  M_RST_I    : in  STD_LOGIC;
  M_ADDR_I   : in  UNSIGNED(ADDR_WIDTH-1 downto 0);
  M_DATA_RO  : out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
  M_DATA_WI  : in  STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
  M_STRB_WI  : in  STD_LOGIC_VECTOR(DATA_WIDTH/8-1 downto 0);
  M_WE_WI    : in  STD_LOGIC;
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

begin

M_DATA_RO <= DATA_BUF(addr2base(M_ADDR_I)+DATA_WIDTH-1 downto addr2base(M_ADDR_I))
   when M_ADDR_I < offset else BRAM_RDATA;

update_buffer: process(M_CLK_I,M_RST_I,M_ADDR_I,M_STRB_WI,M_DATA_WI)
begin
  if (rising_edge(M_CLK_I)) then
    if M_RST_I = '1' then
      DATA_BUF <= (others => '0');
    else
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
      if s_idx_wi_buf(0) < HEAD_MAX then
        for i in 0 to DATA_WIDTH/8-1 loop
          if s_strb_wi_buf(0)(i) = '1' then
            DATA_BUF(addr2base(s_idx_wi_buf(0))+i*8+7 downto addr2base(s_idx_wi_buf(0))+i*8) <=  s_data_wi_buf(0)(i*8+7 downto i*8);
          end if;
        end loop;
      end if;    
    end if;
  end if;
end process update_buffer;

----out   
update_in: process(M_CLK_I)
begin
  if (rising_edge(M_CLK_I)) then
    s_stat_wi_buf(0) <= s_stat_wi_buf(1);
    
    s_idx_wi_buf(0)  <= s_idx_wi_buf(1);
    s_strb_wi_buf(0) <= s_strb_wi_buf(1);
    s_data_wi_buf(0) <= s_data_wi_buf(1);
    
    s_head_wi_buf(0) <= s_head_wi_buf(1);
    s_hwrt_wi_buf(0) <= s_hwrt_wi_buf(1);
  end if;  
end process update_in;

-- two stage buf out
update_out1: process(S_CLK_I,DATA_BUF)--, s_idx_ri_buf)
variable idx, address  : integer;
begin
  if falling_edge(S_CLK_I) then
--     if s_idx_ri_buf < HEAD_MAX
--     then  s_data_ro_buf(1) <=  DATA_BUF(idx2base(s_idx_ri_buf)+DATA_WIDTH-1 downto idx2base(s_idx_ri_buf));
--     elsif s_idx_ri_buf < HEAD_MAX+DATA_COUNT
--     then  s_data_ro_buf(1) <= BRAM_RDATA;
--     else  s_data_ro_buf(1) <= (others => '0');
--     end if;
     s_ctrl_ro_buf(1) <= DATA_BUF(CTRL_HEAD downto CTRL_BASE);
     s_head_ro_buf(1) <= DATA_BUF(HEAD_HEAD downto HEAD_BASE);     
  end if;  
end process update_out1;

update_out2: process(S_CLK_I,S_STAT_WI,S_IDX_WI,S_STRB_WI,S_DATA_WI,S_HEAD_WI,S_HWRT_WI)--,S_IDX_RI)
variable address  : integer;
begin
  if rising_edge(S_CLK_I) then
    -- write
    s_stat_wi_buf(1) <= S_STAT_WI;
    
    s_idx_wi_buf(1)  <= to_unsigned(S_IDX_WI,ADDR_WIDTH);
    s_strb_wi_buf(1) <= S_STRB_WI;
    s_data_wi_buf(1) <= S_DATA_WI;
    
    s_head_wi_buf(1) <= S_HEAD_WI;
    s_hwrt_wi_buf(1) <= S_HWRT_WI;
    -- read
    s_ctrl_ro_buf(0) <= s_ctrl_ro_buf(1);
    s_head_ro_buf(0) <= s_head_ro_buf(1);
    --s_idx_ri_buf     <= S_IDX_RI;
    --s_data_ro_buf(0) <= s_data_ro_buf(1);
  end if;  
end process update_out2;
S_CTRL_RO <= s_ctrl_ro_buf(0);
S_HEAD_RO <= s_head_ro_buf(0);
--S_DATA_RO <= s_data_ro_buf(0);
end arch_imp;
