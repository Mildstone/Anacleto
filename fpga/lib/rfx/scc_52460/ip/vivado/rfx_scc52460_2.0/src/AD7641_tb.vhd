library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity AD7641_tb is
end AD7641_tb;


architecture Behavioral of AD7641_tb is

  component AD7641_serial_slave is
    Generic (
	   SERIAL_DATA_LEN : integer := 18
    );
    Port (
           store_tics      : in   integer;
           cnvst_hi_tics   : in   integer;
           cnvst_lo_tics   : in   integer;

           data_out    : out  std_logic_vector (31 downto 0);
           error_out   : out  std_logic;
	       store_out   : out  std_logic;

           clk         : in   std_logic;
           reset       : in   std_logic;
           SDAT_in     : in   std_logic;
           SCLK_in     : in   std_logic;
           CNVST_in    : in   std_logic;
           CNVST_out   : out  std_logic;
	       RST_P       : out  std_logic;
	       RST_N       : out  std_logic
           );
  end component;
 
  component AD7641_serial_emulator is
      Generic (
       SERIAL_DATA_LEN : integer := 18       
      );
      Port ( reset    : in STD_LOGIC;
             clk      : in STD_LOGIC;
             clk_ref  : in STD_LOGIC;
             CNVST_in : in STD_LOGIC;
             SCLK_out : out STD_LOGIC;
             SDAT_out : out STD_LOGIC;
             data_in  : in STD_LOGIC_VECTOR (31 downto 0));
  end component;
 
 
  signal clk : std_logic := '0';
  signal clk_ref : std_logic := '0';
  
  signal reset, SCLK, SDAT, CNVST  : std_logic;
  signal data_out : std_logic_vector (31 downto 0);
  
  signal store_tics,  cnvst_hi_tics, cnvst_lo_tics : integer;
  signal data_in : std_logic_vector (31 downto 0);

begin
  
  
  reset <= '0';
  
  -- GEN STIMULI --  
  clk <= not clk after 2ns;
  clk_ref <= not clk_ref after 5ns;
  
  -- data_in <= x"0002a055";
  -- data_in <= x"00023001";
  -- data_in <= x"0002_0001";
  store_tics    <= 50;
  cnvst_hi_tics <= 3;
  cnvst_lo_tics <= 125;

  data_in_gen : process (CNVST)
   variable data : integer := 16#0001_0000#; 
  begin
   if rising_edge(CNVST) then
    data := data + 1;
    data_in <= std_logic_vector(to_unsigned(data, 32));
   end if;
  end process;

  
  AD7641_serial_slave_inst :   AD7641_serial_slave
  port map(
    store_tics => store_tics,
    cnvst_hi_tics => cnvst_hi_tics,
    cnvst_lo_tics => cnvst_lo_tics,
    data_out => data_out,
    clk => clk,
    reset => reset,
    SDAT_in => SDAT,
    SCLK_in => SCLK,
    CNVST_in => '0',
    CNVST_out => CNVST
  );

  AD7641_serial_emulator_inst : AD7641_serial_emulator
  port map (    
    reset => reset,
    clk => clk,
    clk_ref => clk_ref,
    CNVST_in => CNVST,
    SCLK_out => SCLK,
    SDAT_out => SDAT,
    data_in => data_in
  );
  


end Behavioral;
