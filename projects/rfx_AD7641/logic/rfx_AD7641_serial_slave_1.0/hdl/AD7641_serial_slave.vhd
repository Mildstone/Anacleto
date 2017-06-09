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
           error_out   : out  std_logic;
           clk         : in   std_logic;
           reset       : in   std_logic;
           SDAT_in     : in   std_logic;
           SCLK_in     : in   std_logic;
           CNVST_in    : in   std_logic;
           CNVST_out   : out  std_logic;
           RST_P   : out  std_logic;  -- vanno in common mode
           RST_N   : out  std_logic   -- vanno in common mode
           );

end AD7641_serial_slave;

architecture Behavioral of AD7641_serial_slave is

  type   state_type is (st_read_wait, st_read, st_idle);
  signal state, next_state : state_type := st_idle;

  signal cnvst_reset           : std_logic := '1';
  signal read_reset            : std_logic := '1';
  signal cnvst_gen             : std_logic := '0';
  signal cnvst                 : std_logic := '0';
  
  signal rst_pos                : std_logic := '0';
  signal rst_neg                 : std_logic := '0';

  constant HALF_DATA_LEN      : integer := SERIAL_DATA_LEN/2;
  signal data_0, data_1       : std_logic_vector(HALF_DATA_LEN-1 downto 0) := (others => '0');
  signal data_count_0         : integer := 0;
  signal data_count_1         : integer := 0; 
  signal data                 : std_logic_vector(SERIAL_DATA_LEN-1 downto 0) := (others => '0');
  signal store                : std_logic := '0';
  signal SCLK_buf             : std_logic := '0';

begin

  cnvst <= CNVST_in or cnvst_gen;
  CNVST_out <= cnvst;
  SCLK_buf <= SCLK_in;
  error_out <= SCLK_buf;
  --data_out(31 downto SERIAL_DATA_LEN) <= (others => '0');
  
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
  proc_store : process (read_reset, clk)
   variable count : integer := 0;
   variable thc   : integer := 0;
  begin
   thc := store_tics * TIME_MULT;
   if read_reset = '1' then
    count := 0;
    data_out(SERIAL_DATA_LEN-1 downto 0) <= (others => '0');
   elsif rising_edge(clk) then
    if cnvst = '1' then
     count := 0;
     store <= '0';
    elsif (count < thc ) then
     store <= '0';
     count := count+1;
    else
     store <= '1';
    end if;
    -- store
    if (count = thc-1) then
     data_out(SERIAL_DATA_LEN-1 downto 0) <= data;
     data_out(31 downto SERIAL_DATA_LEN) <= (others => data(SERIAL_DATA_LEN-1));
    end if;
   end if; -- clk
  end process;
  
  -- main --
  proc_main : process (clk, reset, cnvst)
  begin   
   if (reset = '1') or (cnvst_hi_tics = 0) then
    read_reset  <= '1';
   else
    read_reset  <= '0';
   end if;
  end process;
  
  --Reset process
    proc_reset : process (clk, read_reset)
    variable pulse : integer := 0;
  begin   
  if read_reset = '1' then
    rst_n  <= '0'; --ADC off
    rst_p  <= '1'; --DC/DC off and FF disable (Q==0)
    cnvst_reset <= '1';
    pulse := 0;    
  elsif rising_edge(clk) then
    rst_n  <= '1'; --ADC on
    rst_p  <= '0'; --DC/DC on and FF enable  
    if (pulse < 10000 ) then
      pulse := pulse + 1;
      cnvst_reset <= '1';
    else
      cnvst_reset <= '0';       
    end if;    
  end if;  
 end process; 

  --  READ process 0 --
  proc_read_0 : process (SCLK_in, read_reset, store)
  begin
    if read_reset = '1' then
     data_0 <= (others => '0');
    elsif store = '1' then
     data_count_0 <= 0;
    elsif rising_edge(SCLK_in) then
     data_0 <= data_0(HALF_DATA_LEN-2 downto 0) & SDAT_in;
     data_count_0 <= data_count_0 + 1;
    end if;
  end process;

  --  READ process 1 --
  proc_read_1 : process (SCLK_in, read_reset, store)
  begin
    if read_reset = '1' then
     data_1 <= (others => '0');
    elsif store = '1' then
     data_count_1 <= 0;
    elsif falling_edge(SCLK_in) then
     data_1 <= data_1(HALF_DATA_LEN-2 downto 0) & SDAT_in;
     data_count_1 <= data_count_1 + 1;     
    end if;
  end process;

  gen_data : for i in 0 to HALF_DATA_LEN-1 generate
   data(i*2+1 downto i*2) <= data_0(i) & data_1(i);
  end generate gen_data;
            
end Behavioral;
