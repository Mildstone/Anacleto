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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Prescaler_code is
    Port ( clk : in STD_LOGIC;    
           divider : in STD_LOGIC_VECTOR (31 downto 0) := x"FFFFFFFF";
           prescaler_output : out STD_LOGIC
         );
end Prescaler_code;

architecture Behavioral of Prescaler_code is
  signal internal_counter : unsigned (31 downto 0) := (others => '0');
  signal set_togle : unsigned (31 downto 0) := (others => '0');
  
begin
--set_togle <= to_unsigned(5000, 32);
set_togle <= unsigned(divider);

process(clk,internal_counter)
begin
prescaler_output <= '0';
  if rising_edge(clk) then
    internal_counter <= internal_counter +1;
        if internal_counter > set_togle then
        prescaler_output <= '1'; 
        end if;
         if internal_counter > set_togle * 2 then
         prescaler_output <= '0'; 
         internal_counter <=  to_unsigned(0, 32);
         end if;
  end if;
  
end process;

end Behavioral;
