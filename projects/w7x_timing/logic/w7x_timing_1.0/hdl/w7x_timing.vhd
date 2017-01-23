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
    generic(
      MAX_SAMPLES : integer := 16
    );
    port (
       clk   : in  STD_LOGIC;
       trig  : in  STD_LOGIC;
       init  : in  STD_LOGIC;
       bstate: out STD_LOGIC_VECTOR (0 to 5);
       delay : in  STD_LOGIC_VECTOR (63 downto 0);
       width : in  STD_LOGIC_VECTOR (31 downto 0);
       period: in  STD_LOGIC_VECTOR (31 downto 0);
       cycle : in  STD_LOGIC_VECTOR (63 downto 0);
       repeat: in  STD_LOGIC_VECTOR (31 downto 0);
       count : in  STD_LOGIC_VECTOR (31 downto 0);
       times : in  STD_LOGIC_VECTOR (MAX_SAMPLES*64-1 downto 0)
    );
end  w7x_timing;


architecture Behavioral of w7x_timing is
begin
  clock_gen:  process(clk, init, trig) is
    constant ZERO64         : unsigned(63 downto 0) := x"0000000000000000";
    constant ZERO32         : unsigned(31 downto 0) := x"00000000";
    constant INF64          : unsigned(63 downto 0) := x"FFFFFFFFFFFFFFFF";
    constant INF32          : unsigned(31 downto 0) := x"FFFFFFFF";
    --                                                     SG0PWA
    constant IDLE           : std_logic_vector(0 to 5) := "000000";
    constant ARMED          : std_logic_vector(0 to 5) := "000001";
    constant WAITING_DELAY  : std_logic_vector(0 to 5) := "000010";
    constant WAITING_SAMPLE : std_logic_vector(0 to 5) := "010110";
    constant WAITING_LOW    : std_logic_vector(0 to 5) := "010010";
    constant WAITING_HIGH   : std_logic_vector(0 to 5) := "110010";
    constant WAITING_REPEAT : std_logic_vector(0 to 5) := "000110";
    constant ERROR          : std_logic_vector(0 to 5) := "000111";
     
    variable state        : std_logic_vector(0 to 5) := IDLE;
    -- measure number of samples in sequence, i.e. len(times)
    variable sample_count : integer := 0;
    variable sample_total : integer := 0;
    -- measure number of repititions
    variable repeat_count : integer := 0;
    variable repeat_total : integer := 0;
    -- measure high and low of signal
    variable period_ticks : unsigned(31 downto 0) := ZERO32;
    variable high_total   : unsigned(31 downto 0) := ZERO32;
    variable period_total : unsigned(31 downto 0) := ZERO32;
    -- sequence counter
    variable cycle_ticks  : unsigned(63 downto 0) := ZERO64;
    variable delay_total  : unsigned(63 downto 0) := ZERO64;
    variable cycle_total  : unsigned(63 downto 0) := ZERO64;
    
    --used to read from times vector
    impure function samples(i : integer) return unsigned(63 downto 0) is
    begin
      return unsigned(times(i*64+63 downto i*64));
    end samples;

    procedure start_sample is
    begin
      period_ticks := ZERO32;
      sample_count := sample_count +1;
      state := WAITING_HIGH;
    end start_sample;

    procedure do_waiting_sample is
    variable curr_sample : unsigned(63 downto 0) := samples(sample_count);
    begin
      if cycle_ticks = curr_sample then
        start_sample;
      elsif cycle_ticks > curr_sample then
        state := ERROR;
      end if;
    end do_waiting_sample;

    procedure start_cycle is
    begin
      sample_count := 0;
      cycle_ticks  := ZERO64;
      repeat_count := repeat_count + 1;
      state := WAITING_SAMPLE;
      do_waiting_sample;
    end start_cycle;
    
    procedure do_waiting_repeat is
    begin
      if repeat_count < repeat_total then
        if cycle_ticks = cycle_total then
          start_cycle;
        elsif cycle_ticks > cycle_total then
          state := ERROR;
        end if;
      else
        state := ARMED;
      end if;
    end do_waiting_repeat;

    procedure do_waiting_low is
    begin
      if period_ticks = period_total then
        if sample_count < sample_total then
          state := WAITING_SAMPLE;
          do_waiting_sample;       
        else
          state := WAITING_REPEAT;
          do_waiting_repeat;
        end if;
     elsif period_ticks > period_total then
       state := ARMED;
     end if;
    end do_waiting_low;

    procedure do_waiting_high is
    begin
      if period_ticks = high_total then
        state := WAITING_LOW;
        do_waiting_low;
      elsif period_ticks > high_total then
       state := ARMED;
      end if;
    end do_waiting_high;

    procedure do_waiting_delay is
    begin
      if cycle_ticks = delay_total then
        start_cycle;
      elsif cycle_ticks > delay_total then
        state := ERROR;
      end if;
    end do_waiting_delay;

    procedure start_program is
    begin
      cycle_ticks := ZERO64;
      repeat_count := 0;
      state := WAITING_DELAY;
      do_waiting_delay;
    end start_program;

  begin
    high_total   := unsigned(width);
    period_total := unsigned(period);
    delay_total  := unsigned(delay);
    cycle_total  := unsigned(cycle);
    sample_total := to_integer(unsigned(count));
    repeat_total := to_integer(unsigned(repeat));
-- Copy passed times
    --for i in 0 to MAX_SAMPLES-1 loop   
    --  samples(i)  := unsigned(times(i*64+63 downto i*64));
    --end loop;
    if state = IDLE then
      if init = '1' then
        state := ARMED;
      end if;
    elsif init = '0' then
      state := IDLE;
    end if;
    if rising_edge(clk) then
      case state is
      when IDLE =>
      when ARMED => 
        if trig = '1' then
          start_program;
        end if;
      when WAITING_DELAY =>
        do_waiting_delay;
      when WAITING_SAMPLE =>
        do_waiting_sample;
      when WAITING_HIGH =>
        do_waiting_high;
      when WAITING_LOW =>
        do_waiting_low;
      when WAITING_REPEAT =>
        do_waiting_repeat;
      when others =>
        state := ERROR;
      end case;
      if state = IDLE or state = ARMED then
        cycle_ticks  := INF64;
        period_ticks := INF32;
        sample_count := 0;
      else
        cycle_ticks := cycle_ticks  + 1;
        period_ticks:= period_ticks + 1;
      end if;
    end if; -- rising_edge(clk)
    bstate <= state;
  end process clock_gen;

end Behavioral;
