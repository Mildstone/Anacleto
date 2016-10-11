----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/10/2016 12:37:32 PM
-- Design Name: 
-- Module Name: w7x_timing - Behavioral
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

entity w7x_timing is
    Port ( clk : in STD_LOGIC;
           trig : in STD_LOGIC;
           sig  : out STD_LOGIC;
           gate : out STD_LOGIC;
           init : in STD_LOGIC;
           delay : in STD_LOGIC_VECTOR (31 downto 0);
           wid : in STD_LOGIC_VECTOR (31 downto 0);
           period : in STD_LOGIC_VECTOR (31 downto 0);
           cycle : in STD_LOGIC_VECTOR (31 downto 0);
           repeat : in STD_LOGIC_VECTOR (31 downto 0);
           count : in STD_LOGIC_VECTOR (31 downto 0);
           seq_0_l : in STD_LOGIC_VECTOR (31 downto 0);
           seq_0_h : in STD_LOGIC_VECTOR (31 downto 0);
           seq_1_l : in STD_LOGIC_VECTOR (31 downto 0);
           seq_1_h : in STD_LOGIC_VECTOR (31 downto 0);
           seq_2_l : in STD_LOGIC_VECTOR (31 downto 0);
           seq_2_h : in STD_LOGIC_VECTOR (31 downto 0);
           seq_3_l : in STD_LOGIC_VECTOR (31 downto 0);
           seq_3_h : in STD_LOGIC_VECTOR (31 downto 0);
           seq_4_l : in STD_LOGIC_VECTOR (31 downto 0);
           seq_4_h : in STD_LOGIC_VECTOR (31 downto 0);
           seq_5_l : in STD_LOGIC_VECTOR (31 downto 0);
           seq_5_h : in STD_LOGIC_VECTOR (31 downto 0);
           seq_6_l : in STD_LOGIC_VECTOR (31 downto 0);
           seq_6_h : in STD_LOGIC_VECTOR (31 downto 0);
           seq_7_l : in STD_LOGIC_VECTOR (31 downto 0);
           seq_7_h : in STD_LOGIC_VECTOR (31 downto 0);
           seq_8_l : in STD_LOGIC_VECTOR (31 downto 0);
           seq_8_h : in STD_LOGIC_VECTOR (31 downto 0);
           seq_9_l : in STD_LOGIC_VECTOR (31 downto 0);
           seq_9_h : in STD_LOGIC_VECTOR (31 downto 0);
           seq_10_l : in STD_LOGIC_VECTOR (31 downto 0);
           seq_10_h : in STD_LOGIC_VECTOR (31 downto 0);
           seq_11_l : in STD_LOGIC_VECTOR (31 downto 0);
           seq_11_h : in STD_LOGIC_VECTOR (31 downto 0);
           seq_12_l : in STD_LOGIC_VECTOR (31 downto 0);
           seq_12_h : in STD_LOGIC_VECTOR (31 downto 0);
           seq_13_l : in STD_LOGIC_VECTOR (31 downto 0);
           seq_13_h : in STD_LOGIC_VECTOR (31 downto 0);
           seq_14_l : in STD_LOGIC_VECTOR (31 downto 0);
           seq_14_h : in STD_LOGIC_VECTOR (31 downto 0);
           seq_15_l : in STD_LOGIC_VECTOR (31 downto 0);
           seq_15_h : in STD_LOGIC_VECTOR (31 downto 0));
           
end  w7x_timing;

architecture Behavioral of w7x_timing is
signal buf: STD_LOGIC_VECTOR (31 downto 0);
begin
   buf <= seq_0_l;
   gate <= buf(0); 

end Behavioral;
