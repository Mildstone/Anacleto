----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/23/2017 10:58:11 AM
-- Design Name: 
-- Module Name: emulator_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity emulator_tb is
--  Port ( );
end emulator_tb;

architecture Behavioral of emulator_tb is
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
   
   component prescaler is
    Port ( div : in STD_LOGIC_VECTOR (31 downto 0);
           clk : in STD_LOGIC;
           clk_out : out STD_LOGIC);
   end component;

   signal clk, clk_ref  : std_logic := '0';

   signal data_in : std_logic_vector(31 downto 0);
   signal div_in : std_logic_vector(31 downto 0);
      
   signal reset    : std_logic;
   signal CNVST_in : STD_LOGIC := '1';
   signal SCLK_out : STD_LOGIC;
   signal SDAT_out : STD_LOGIC;
   
   
begin
 
  reset   <= '0' after 6ns;
  clk     <= not clk     after 4ns;
  --clk_ref <= not clk_ref after 6ns;
      
  CNVST_in <= '1' after 300ns when CNVST_in = '0' else '0' after 60ns;  
  data_in <= x"0000_0001";
  div_in  <= x"0000_0001";

  AD7641_serial_emulator_inst : AD7641_serial_emulator   
  port map(
    reset => reset,
    clk => clk,
    clk_ref => clk_ref,
    CNVST_in => CNVST_in,
    SCLK_out => SCLK_out,
    SDAT_out => SDAT_out,
    data_in => data_in
  );
  
  prescaler_inst : prescaler
  port map(
     div => div_in,
     clk => clk,
     clk_out => clk_ref
   );
   
end Behavioral;
