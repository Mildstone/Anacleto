----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/18/2016 09:55:06 AM
-- Design Name: 
-- Module Name: TestTiming - Behavioral
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

entity TestTiming is
    Port ( clk : in STD_LOGIC;
           trig : in STD_LOGIC;
           out_clk : out STD_LOGIC;
           out_trig : out STD_LOGIC;
           out_sig : out STD_LOGIC;
           out_gate : out STD_LOGIC);
end TestTiming;




architecture Behavioral of TestTiming is
  signal init: STD_LOGIC := '1';
  signal delay: STD_LOGIC_VECTOR (31 downto 0) := x"00000000";
  signal wid: STD_LOGIC_VECTOR (31 downto 0) := x"00000000";
  signal period: STD_LOGIC_VECTOR (31 downto 0) := x"00000000";
  signal cycle: STD_LOGIC_VECTOR (31 downto 0) := x"00000000";
  signal repeat: STD_LOGIC_VECTOR (31 downto 0) := x"00000000";
  signal count: STD_LOGIC_VECTOR (31 downto 0) := x"00000000";
  signal seq_0_l  : STD_LOGIC_VECTOR (31 downto 0) := x"00000000";
  signal seq_0_h  : STD_LOGIC_VECTOR (31 downto 0) := x"00000000";
  signal seq_1_l  : STD_LOGIC_VECTOR (31 downto 0) := x"00000000";
  signal seq_1_h  : STD_LOGIC_VECTOR (31 downto 0) := x"00000000";
  signal seq_2_l  : STD_LOGIC_VECTOR (31 downto 0) := x"00000000";
  signal seq_2_h  : STD_LOGIC_VECTOR (31 downto 0) := x"00000000";
  signal seq_3_l  : STD_LOGIC_VECTOR (31 downto 0) := x"00000000";
  signal seq_3_h  : STD_LOGIC_VECTOR (31 downto 0) := x"00000000";
  signal seq_4_l  : STD_LOGIC_VECTOR (31 downto 0) := x"00000000";
  signal seq_4_h  : STD_LOGIC_VECTOR (31 downto 0) := x"00000000";
  signal seq_5_l  : STD_LOGIC_VECTOR (31 downto 0) := x"00000000";
  signal seq_5_h  : STD_LOGIC_VECTOR (31 downto 0) := x"00000000";
  signal seq_6_l  : STD_LOGIC_VECTOR (31 downto 0) := x"00000000";
  signal seq_6_h  : STD_LOGIC_VECTOR (31 downto 0) := x"00000000";
  signal seq_7_l  : STD_LOGIC_VECTOR (31 downto 0) := x"00000000";
  signal seq_7_h  : STD_LOGIC_VECTOR (31 downto 0) := x"00000000";
  signal seq_8_l  : STD_LOGIC_VECTOR (31 downto 0) := x"00000000";
  signal seq_8_h  : STD_LOGIC_VECTOR (31 downto 0) := x"00000000";
  signal seq_9_l  : STD_LOGIC_VECTOR (31 downto 0) := x"00000000";
  signal seq_9_h  : STD_LOGIC_VECTOR (31 downto 0) := x"00000000";
  signal seq_10_l  : STD_LOGIC_VECTOR (31 downto 0) := x"00000000";
  signal seq_10_h  : STD_LOGIC_VECTOR (31 downto 0) := x"00000000";
  signal seq_11_l  : STD_LOGIC_VECTOR (31 downto 0) := x"00000000";
  signal seq_11_h  : STD_LOGIC_VECTOR (31 downto 0) := x"00000000";
  signal seq_12_l  : STD_LOGIC_VECTOR (31 downto 0) := x"00000000";
  signal seq_12_h  : STD_LOGIC_VECTOR (31 downto 0) := x"00000000";
  signal seq_13_l  : STD_LOGIC_VECTOR (31 downto 0) := x"00000000";
  signal seq_13_h  : STD_LOGIC_VECTOR (31 downto 0) := x"00000000";
  signal seq_14_l  : STD_LOGIC_VECTOR (31 downto 0) := x"00000000";
  signal seq_14_h  : STD_LOGIC_VECTOR (31 downto 0) := x"00000000";
  signal seq_15_l  : STD_LOGIC_VECTOR (31 downto 0) := x"00000000";
  signal seq_15_h  : STD_LOGIC_VECTOR (31 downto 0) := x"00000000";
 
  component w7x_timing is
  port ( clk : in STD_LOGIC;
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
         

  end component w7x_timing;

 
 
  
 begin
    timing_module : w7x_timing
    port map(clk => clk, trig => trig, sig => out_sig, gate => out_gate, init => init, 
        delay => delay, wid => wid, period => period, cycle => cycle, repeat => repeat, count => count,
        seq_0_l => seq_0_l, seq_0_h => seq_0_h,seq_1_l => seq_1_l, seq_1_h => seq_1_h, 
        seq_2_l => seq_2_l, seq_2_h => seq_2_h,seq_3_l => seq_3_l, seq_3_h => seq_3_h, 
        seq_4_l => seq_4_l, seq_4_h => seq_4_h,seq_5_l => seq_5_l, seq_5_h => seq_5_h, 
        seq_6_l => seq_6_l, seq_6_h => seq_6_h,seq_7_l => seq_7_l, seq_7_h => seq_7_h, 
        seq_8_l => seq_8_l, seq_8_h => seq_8_h,seq_9_l => seq_9_l, seq_9_h => seq_9_h, 
        seq_10_l => seq_10_l, seq_10_h => seq_10_h,seq_11_l => seq_11_l, seq_11_h => seq_11_h, 
        seq_12_l => seq_12_l, seq_12_h => seq_12_h,seq_13_l => seq_13_l, seq_13_h => seq_13_h, 
        seq_14_l => seq_14_l, seq_14_h => seq_14_h,seq_15_l => seq_15_l, seq_15_h => seq_15_h); 
   
   
 end Behavioral;
 
  