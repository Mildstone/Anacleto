library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity AD7641_serial_slave is
    Generic (
           SERIAL_DATA_LEN : integer := 18;
           TIME_MULT       : integer := 1000000
    );
    Port (
           store_tics      : in   integer;
           cnvst_hi_tics   : in   integer;
           cnvst_lo_tics   : in   integer;

           data_out    : out  std_logic_vector (31 downto 0);
           error_out   : out  std_logic_vector (0 downto 0);
           clk         : in   std_logic;
           reset       : in   std_logic;
           SDAT_in     : in   std_logic;
           SCLK_in     : in   std_logic;
           CNVST_in    : in   std_logic;
           CNVST_out   : out  std_logic
           );

end AD7641_serial_slave;

architecture Behavioral of AD7641_serial_slave is

  type   state_type is (st_read_wait, st_read, st_idle);
  signal state, next_state : state_type := st_idle;

  signal cnvst_reset           : std_logic := '1';
  signal read_reset            : std_logic := '1';
  signal cnvst_gen             : std_logic := '0';
  signal cnvst                 : std_logic := '0';

  constant HALF_DATA_LEN      : integer := SERIAL_DATA_LEN/2;
  signal data_0, data_1       : std_logic_vector(HALF_DATA_LEN-1 downto 0) := (others => '0'); 
  signal data                 : std_logic_vector(SERIAL_DATA_LEN-1 downto 0) := (others => '0');
  signal store                : std_logic := '0';

begin

  cnvst <= CNVST_in or cnvst_gen;
  CNVST_out <= cnvst;
  data_out(31 downto SERIAL_DATA_LEN) <= (others => '0');
   
  -- CNVST generator --
  proc_gen_CNVST : process (clk, cnvst_reset)
   variable count : integer := 0;
   variable hit   : integer := 0;
   variable lot   : integer := 0;
  begin
   hit := cnvst_hi_tics * TIME_MULT;
   lot := cnvst_lo_tics * TIME_MULT;
   if rising_edge(clk) then
    if cnvst_reset = '1' then
     cnvst_gen <= '0';
     count := 0;
    elsif (count < hit ) then
     cnvst_gen <= '1';
    elsif (count < lot) then
     cnvst_gen <= '0';
    else
     count := 0;
     cnvst_gen <= '0';
    end if;
    count := (count + 1);
   end if;
  end process;

  -- STORE --
  proc_store : process (reset, clk)
   variable count : integer := 0;
   variable thc   : integer := 0;
  begin
   thc := store_tics * TIME_MULT;
   if reset = '1' then
    count := 0;    
   elsif rising_edge(clk) then
    store <= '0';
    if cnvst = '1' then
       count := 0;
    elsif (count > thc ) then
     store <= '1';
     data_out(SERIAL_DATA_LEN-1 downto 0) <= data;
     error_out <= b"1";
    else
     count := count+1;
     error_out <= b"0";
    end if;
   end if;
  end process;
  
  
--  process (store)
--  begin
--   if rising_edge(store) then
--    data_out(SERIAL_DATA_LEN-1 downto 0) <= data; 
--   end if;
--  end process;
  
  -- main --
  proc_main : process (clk, reset, cnvst)
  begin   
   if reset = '1' then
    read_reset  <= '1';
    cnvst_reset <= '1';
   else
    read_reset  <= '0';
    cnvst_reset <= '0';            
   end if;
  end process;

  --  READ process 0 --
  proc_read_0 : process (SCLK_in, read_reset)
  begin    
    if rising_edge(SCLK_in) then
     data_0 <= data_0(HALF_DATA_LEN-2 downto 0) & SDAT_in;
    end if;
  end process;

  --  READ process 1 --
  proc_read_1 : process (SCLK_in, read_reset)
  begin
    if falling_edge(SCLK_in) then
     data_1 <= data_1(HALF_DATA_LEN-2 downto 0) & SDAT_in;     
    end if;
  end process;

  gen_data : for i in 0 to HALF_DATA_LEN-1 generate
   data(i*2+1 downto i*2) <= data_0(i) & data_1(i);
  end generate gen_data;
            
end Behavioral;
