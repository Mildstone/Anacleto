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
   
   signal clk, clk_ref  : std_logic := '0';
   signal data_in : std_logic_vector(31 downto 0);
   
   signal reset : std_logic;
   signal CNVST_in : STD_LOGIC := '1';
   signal SCLK_out : STD_LOGIC;
   signal SDAT_out : STD_LOGIC;
   
   
begin
 
  
  clk     <= not clk     after 100ns;
  clk_ref <= not clk_ref after 1us;
    
  CNVST_in <= '1' after 35us when CNVST_in = '0'
    else '0' after 3us;
  

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
   
end Behavioral;
