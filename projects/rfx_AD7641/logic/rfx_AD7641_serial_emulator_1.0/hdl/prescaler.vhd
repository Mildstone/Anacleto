----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/12/2017 12:52:05 PM
-- Design Name: 
-- Module Name: prescaler - Behavioral
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
use ieee.numeric_std.all;
 

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity prescaler is
    Port ( div : in STD_LOGIC_VECTOR (31 downto 0);
           clk : in STD_LOGIC;
           clk_out : out STD_LOGIC);
end prescaler;

architecture Behavioral of prescaler is
 signal thr : unsigned(div'length-1 downto 0) := to_unsigned(0,div'length);
begin
 thr <= unsigned(div);
 process (clk)
  variable cnt : unsigned(div'length-1 downto 0) := to_unsigned(0,div'length);
 begin
  if rising_edge(clk) then
   if cnt < 2*thr-1 then
    cnt := cnt + 1;
   else
    cnt := to_unsigned(0,32);
   end if;
   if cnt < thr then
    clk_out <= '0';
   else
    clk_out <= '1';
   end if;
  end if;
 end process;
end Behavioral;
