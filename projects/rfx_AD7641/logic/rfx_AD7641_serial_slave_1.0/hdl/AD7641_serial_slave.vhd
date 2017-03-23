library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity AD7641_serial_slave is
    Generic (
           SERIAL_DATA_LEN : integer := 18;
           CNVST_TICS      : integer := 10;
           START_IDLE      : integer := 10
    );
    Port ( 
           data_out    : out  std_logic_vector (31 downto 0);
           clk         : in   std_logic;
           reset       : in   std_logic; 
           SDAT_in     : in   std_logic; 
           SCLK_in     : in   std_logic; 
           CNVST_out   : out  std_logic 
           );
           
end AD7641_serial_slave;

architecture Behavioral of AD7641_serial_slave is
  
  signal gen_set               : std_logic := '0';
  signal data_out_buffer       : std_logic_vector(31 downto 0) := (others => '0');
  signal data_out_buffer_ready : std_logic := '1';
begin  
  
  main : process(clk, reset)
   variable count : integer := 0;
  begin
  if reset = '1' then
   gen_set <= '0';
   count := 0;
  elsif rising_edge(clk) then
   -- IDLE time after reset     
   if count < START_IDLE then
    count := count + 1;
   else
    gen_set <= '1';
   end if;
   -- if ready spool buffer
   if data_out_buffer_ready = '1' then
    data_out <= data_out_buffer;
    gen_set <= '1';
   else
    gen_set <= '0';
   end if;
  end if;
  end process main;
  
  gen_CNVST : process (clk, reset, gen_set)
   variable count  : integer := 0;
   variable enable : std_logic := '0';
  begin
   if reset = '1' then
     CNVST_out <= '0';
--   elsif enable = '1' and gen_set = '1' then
--     count := CNVST_TICS;
--     enable := '0';
--   elsif enable = '0' and gen_set = '0' then
--     enable := '1';     
--   elsif rising_edge(clk) then
--    if count > 0 then
--     CNVST_out <= '1';
--     count := count -1;
--    else
--     CNVST_out <= '0';
--    end if;
   elsif rising_edge(clk) then
    if data_out_buffer_ready = '1' then
     CNVST_out <= '1';
    else
      CNVST_out <= '0';
    end if; 
   end if;
  end process gen_cnvst;
    
  proc_read : process (SCLK_in, reset)
    variable pos : integer := 0;
  begin
    if reset = '1' then
     pos := 0;
    elsif rising_edge(SCLK_in) then
     data_out_buffer(pos) <= SDAT_in;
     pos := (pos + 1) mod SERIAL_DATA_LEN;
     if pos = 0 then
      data_out_buffer_ready <= '1';
     else
      data_out_buffer_ready <= '0';
     end if;
    end if;  
  end process  proc_read;

end Behavioral;