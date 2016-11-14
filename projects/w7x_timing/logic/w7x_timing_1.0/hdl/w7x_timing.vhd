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
use IEEE.NUMERIC_STD.ALL;
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
           delay_l : in STD_LOGIC_VECTOR (31 downto 0);
           delay_h : in STD_LOGIC_VECTOR (31 downto 0);
           wid : in STD_LOGIC_VECTOR (31 downto 0);
           period : in STD_LOGIC_VECTOR (31 downto 0);
           cycle_l : in STD_LOGIC_VECTOR (31 downto 0);
           cycle_h : in STD_LOGIC_VECTOR (31 downto 0);
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
signal out_state: STD_LOGIC_VECTOR (31 downto 0);
signal times0 : STD_LOGIC_VECTOR(63 downto 0); 
signal times1 : STD_LOGIC_VECTOR(63 downto 0); 
signal times2 : STD_LOGIC_VECTOR(63 downto 0); 
signal out_long_counter : STD_LOGIC_VECTOR(63 downto 0); 
signal out_clock_count : STD_LOGIC_VECTOR(31 downto 0); 
begin
   
   clock_gen:  process(clk, init, trig) is
     constant IDLE : integer := 1;
     constant ARMED : integer := 2;
     constant TRIGGERED : integer := 3;
     constant RUNNING_CLOCK : integer := 4;
     constant RUNNING_SEQUENCE_UP : integer := 5;
     constant RUNNING_SEQUENCE_DOWN : integer := 6;
     constant WAITING_REPEAT : integer := 7;
     
     type LONG_ARRAY_TYPE is array(0 to 15) of unsigned(63 downto 0);
     variable times : LONG_ARRAY_TYPE;
     
     variable curr_wid : integer := to_integer(unsigned(wid));
     variable curr_period : integer := to_integer(unsigned(period));
--     variable curr_delay : integer := to_integer(unsigned(delay));
     variable curr_delay : unsigned(63 downto 0);
--     variable curr_cycle : integer := to_integer(unsigned(cycle));
     variable curr_cycle : unsigned(63 downto 0);
     variable curr_count : integer := to_integer(unsigned(count));
     variable curr_repeat : integer := to_integer(unsigned(repeat));
     variable state : integer := IDLE;
     variable wait_count : integer := 0;                      -- Used to count delay clocks
     variable counter : integer := 0;                         -- Used to generate clock
     variable long_counter : unsigned(63 downto 0) := x"0000000000000000";     -- Used for time count within burst
     variable clock_count : integer := 0;                     -- Used to count clocks within burst 
     variable repeat_count: integer := 0;                     -- Used to count bursts

 


     begin
 
       curr_wid := to_integer(unsigned(wid));
       curr_period := to_integer(unsigned(period));
       curr_delay := unsigned(delay_h & delay_l);
       curr_cycle := unsigned(cycle_h & cycle_l);
       curr_count := to_integer(unsigned(count));
       curr_repeat := to_integer(unsigned(repeat));
      
-- Copy passed times       
       times(0) := unsigned(seq_0_h & seq_0_l);
       times(1) := unsigned(seq_1_h & seq_1_l);
       times(2) := unsigned(seq_2_h & seq_2_l);
       times(3) := unsigned(seq_3_h & seq_3_l);
       times(4) := unsigned(seq_4_h & seq_4_l);
       times(5) := unsigned(seq_5_h & seq_5_l);
       times(6) := unsigned(seq_6_h & seq_6_l);
       times(7) := unsigned(seq_7_h & seq_7_l);
       times(8) := unsigned(seq_8_h & seq_8_l);
       times(9) := unsigned(seq_9_h & seq_9_l);
       times(10) := unsigned(seq_10_h & seq_10_l);
       times(11) := unsigned(seq_11_h & seq_11_l);
       times(12) := unsigned(seq_12_h & seq_12_l);
       times(13) := unsigned(seq_13_h & seq_13_l);
       times(14) := unsigned(seq_14_h & seq_14_l);
       times(15) := unsigned(seq_15_h & seq_15_l);
       
       times0 <= std_logic_vector(times(0));
       times1 <= std_logic_vector(times(1));
       times2 <= std_logic_vector(times(2));
       out_long_counter <= std_logic_vector(long_counter);
       out_clock_count <= std_logic_vector(to_unsigned(clock_count, 32));
       out_state <= std_logic_vector(to_unsigned(state, 32));
       
       if rising_edge(clk) then 
         case state is
             when IDLE => 
               if init = '1' then 
                 state := ARMED;
                 sig <= '0';
                 gate <= '0';
               end if;
             when ARMED =>
               if init = '0' then
                 state := IDLE; 
                 sig <= '0';
                 gate <= '0';
               elsif trig = '1' then
                 wait_count := 0;
                 if wait_count = curr_delay then --In case delay == 0
                   if times(0) = times(1) then    --Same value for first two times means clock generation
                     state := RUNNING_CLOCK;
                     sig <= '1';
                     clock_count := 0;
                   else
                     if times(0) = 0 then
                       sig <= '1';
                       state := RUNNING_SEQUENCE_UP;
                       clock_count := 1;
                     else
                       sig <= '0';
                       state := RUNNING_SEQUENCE_DOWN;
                       clock_count := 0;
                     end if;
                   end if;
                   gate <= '1';
                   counter := 0;
                   long_counter := x"0000000000000000";
                   repeat_count := 0;
                 else
                   state := TRIGGERED;  
                 end if;
               end if;
             when TRIGGERED =>
               if init = '0' then
                 state := IDLE;
                 sig <= '0';
                 gate <= '0';
               else
                 wait_count := wait_count + 1;
                 if wait_count = curr_delay then 
                   if times(0) = times(1) then    --Same value for first two times means clock generation
                     state := RUNNING_CLOCK;
                     sig <= '1';
                     clock_count := 0;
                   else
                      if times(0) = 0 then
                       sig <= '1';
                       clock_count := 1;
                       state := RUNNING_SEQUENCE_UP;
                     else
                       clock_count := 0;
                       sig <= '0';
                       state := RUNNING_SEQUENCE_DOWN;
                     end if;
                   end if;
                   counter := 0;
                   long_counter := x"0000000000000000";
                   repeat_count := 0;
                   gate <= '1';
                 end if;
               end if;
             when RUNNING_CLOCK =>
               if init = '0' then
                 state := IDLE;
                 sig <= '0';
                 gate <= '0';
               else
                 long_counter := long_counter + 1;
                 counter := counter + 1;
                 if counter = curr_period then   --End of current clock period
                   sig <= '1';
                   counter := 0;
                 elsif counter = curr_wid then  --End of width ticks (when output is high)
                   sig <= '0';
                   clock_count := clock_count + 1;
                   if clock_count >= curr_count then  --End of clocks within burst
                     state := WAITING_REPEAT;
                   end if;
                 end if;
               end if;
             when WAITING_REPEAT =>
               if init = '0' then
                 state := IDLE;
                 sig <= '0';
                 gate <= '0';
               else
                 long_counter := long_counter + 1;
                 if long_counter >= curr_cycle then     --End of current burst
                   repeat_count := repeat_count + 1;
                   if repeat_count >= curr_repeat then   --Finished generating bursts
                     state := IDLE;
                     sig <= '0';
                     gate <= '0';
                   else  
                     if times(0) = times(1) then    --Same value for first two times means clock generation
                       state := RUNNING_CLOCK;
                       sig <= '1';
                       clock_count := 0;
                     else
                       counter := 0;
                       if times(0) = 0 then
                         sig <= '1';
                         state := RUNNING_SEQUENCE_UP;
                         clock_count := 1;
                       else
                         sig <= '0';
                         state := RUNNING_SEQUENCE_DOWN;
                         clock_count := 0;
                       end if;
                     end if;
                     counter := 0;
                     long_counter := x"0000000000000000";
                  end if;
                 end if;
               end if;
             when RUNNING_SEQUENCE_UP =>
               counter := counter + 1;
               if counter = curr_wid then
                 sig <= '0';
                 if clock_count = curr_count then  
                   state := WAITING_REPEAT;
                 else
                   state := RUNNING_SEQUENCE_DOWN;
                 end if;
               end if;
               long_counter := long_counter + 1;
             when RUNNING_SEQUENCE_DOWN =>
               long_counter := long_counter + 1;
               if long_counter = times(clock_count) then
                 sig <= '1';
                 counter := 0;
                 state := RUNNING_SEQUENCE_UP;
                 clock_count := clock_count + 1;
               end if;   
 --              long_counter := long_counter + 1;
              
             when others =>        --Should never happen
               state := IDLE;
               sig <= '0';
               gate <= '0';
            
           end case;
         end if;
      
      end process clock_gen; 

 
  
end Behavioral;
