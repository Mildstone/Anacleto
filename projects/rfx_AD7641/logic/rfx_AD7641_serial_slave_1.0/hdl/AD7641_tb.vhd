library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity AD7641_tb is
end AD7641_tb;


architecture Behavioral of AD7641_tb is

  component AD7641_serial_slave is
    Generic (
           SERIAL_DATA_LEN : integer := 18;
           TIME_MULT : integer := 100000
    );
    Port ( 
           store_tics      : in   integer;
           cnvst_hi_tics   : in   integer;
           cnvst_lo_tics   : in   integer;
           data_out    : out  std_logic_vector (31 downto 0);
           error_out   : out  std_logic_vector ( 0 downto 0);
           clk         : in   std_logic;
           reset       : in   std_logic; 
           SDAT_in     : in   std_logic; 
           SCLK_in     : in   std_logic;
           CNVST_in    : in   std_logic; 
           CNVST_out   : out  std_logic 
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
  
  --data_in <= x"0002a055";
  --data_in <= x"00023001";
  data_in <= x"0002_0001";
  store_tics    <= 50;
  cnvst_hi_tics <= 8;
  cnvst_lo_tics <= 125;

  -- GEN STIMULI --
--  clk <= not clk after 2ms;
--  clk_ref <= not clk_ref after 5ms;

--  data_in <= x"0002a055";
--  store_tics    <= 300;
--  cnvst_hi_tics <= 10;
--  cnvst_lo_tics <= 350;


  
  AD7641_serial_slave_inst :   AD7641_serial_slave
  generic map(
    TIME_MULT => 1
  )
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
