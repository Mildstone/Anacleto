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
  
  constant st_read         : std_logic_vector (0 downto 0) :=  "1"; 
  constant st_idle         : std_logic_vector (0 downto 0) :=  "0";

  -- type   state_type is (st_reset, st_read_wait, st_read, st_idle);
  signal state, next_state : std_logic_vector (0 downto 0) := st_idle;  

  signal cnvst_reset           : std_logic := '1';
  signal read_reset            : std_logic := '1';
  signal cnvst_gen             : std_logic := '0';
  signal cnvst                 : std_logic := '0';

  signal sclk_gen              : std_logic := '0';
  signal sclk_0 ,sclk_1        : std_logic := '0';

  signal data_out_buffer_pos   : integer := 0;
  signal data_out_buffer       : std_logic_vector(31 downto 0) := (others => '0');
  signal data_out_buffer_ready : std_logic := '1';
  

begin  

  cnvst <= CNVST_in or cnvst_gen;
  CNVST_out <= cnvst;

  sm_advance : process(clk,reset)
  begin
   if rising_edge(clk) then
    if reset = '1' then
     cnvst_reset <= '1';
     state <= st_idle;
    else
     if cnvst_hi_tics = 0 then
      cnvst_reset <= '1';
     else
      cnvst_reset <= '0';
     end if;
     state <= next_state;
    end if;
   end if;
  end process;  
    
    
  proc_sm_decode : process(state, cnvst, data_out_buffer_ready)   
  begin
   next_state <= state;
   case (state) is
    when st_idle =>
     read_reset <= '0';
     if cnvst = '1' then
      read_reset <= '1';
      next_state <= st_read;
     end if;
    when st_read =>
     read_reset <= '0';
     if data_out_buffer_ready = '1' then
      next_state <= st_idle;
     end if;
    when others =>
     next_state <= state;
   end case;
  end process;

  -- STORE --
  proc_store : process (clk, cnvst)
   --constant store_tics : integer := 500;
   variable count : integer := 0;
   variable thc   : integer := 0;   
  begin   
   thc := store_tics * TIME_MULT;
   if rising_edge(clk) then
    if cnvst = '1' then
       count := 0;
    elsif (count > thc ) then
     data_out <= data_out_buffer;
     error_out <= st_read;
    else
     count := count+1;
     error_out <= st_idle;
    end if;
   end if;
  end process;

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

    
  --  READ process --
  proc_read : process (SCLK_in, read_reset)
    variable count : integer := 0;
  begin
    if read_reset = '1' then
     count := 0;
     data_out_buffer_ready <= '0';
     data_out_buffer <= x"00000000";
    elsif rising_edge(SCLK_in) then
     data_out_buffer(SERIAL_DATA_LEN-1 downto 0) 
      <= data_out_buffer(SERIAL_DATA_LEN-2 downto 0) & SDAT_in;
     if(count < SERIAL_DATA_LEN) then
      count := (count + 1);
      data_out_buffer_ready <= '0';
     else
      count := 0;
      data_out_buffer_ready <= '1';
     end if;
         
    end if;
  end process;

end Behavioral;