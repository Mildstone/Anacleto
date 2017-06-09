----------------------------------------------------------------------------------
-- Company: RFX
-- Engineer: Marco Gottardo 
-- 
-- Create Date: 11/09/2016 02:40:31 PM
-- Design Name: FPGA Frequency prescaler
-- Module Name: Prescaler_code - Behavioral
-- Project Name: 
-- Target Devices: ZYNQ7010 
-- Tool Versions: V1.0
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
use IEEE.numeric_std.ALL;
-- USE ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Prescaler_code is
    Port ( clk     : in STD_LOGIC;
           reset   : in std_logic;    
           divider : in STD_LOGIC_VECTOR (31 downto 0) := x"FFFFFFFF";
           clk_out : out STD_LOGIC
         );
end Prescaler_code;

architecture Behavioral of Prescaler_code is
  signal togle : unsigned (31 downto 0) := (others => '0'); 
begin  
  togle <= unsigned(divider);  
process (reset, clk)
 variable cnt : unsigned(31 downto 0);
begin
 if reset = '1' then
  cnt := to_unsigned(0,32);
 elsif rising_edge(clk) then
  cnt := cnt + 1;
  if cnt < togle then
   clk_out <= '1';
  elsif cnt < 2*togle then
   clk_out <= '0';
  else
   clk_out <= '1';
   cnt := to_unsigned(0,32);
  end if;  
 end if;
end process;

end Behavioral;
