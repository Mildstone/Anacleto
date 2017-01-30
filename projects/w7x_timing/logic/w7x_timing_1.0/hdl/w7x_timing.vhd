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
    generic (
      TIME_WIDTH : integer := 40;
      ERROR_COUNT : integer := 7
    );
    port (
       clk_in    : in  STD_LOGIC;
       init_in   : in  STD_LOGIC;
       reinit_in : in  STD_LOGIC;
       trig_in   : in  STD_LOGIC;
       clear_in  : in  STD_LOGIC;
       state_out : out STD_LOGIC_VECTOR(7 downto 0);
       error_out : out STD_LOGIC_VECTOR(ERROR_COUNT*8-1 downto 0);
       index_out : out STD_LOGIC_VECTOR(31 downto 0);
       delay_in  : in  STD_LOGIC_VECTOR (TIME_WIDTH-1 downto 0);
       width_in  : in  STD_LOGIC_VECTOR(31 downto 0);
       period_in : in  STD_LOGIC_VECTOR(31 downto 0);
       cycle_in  : in  STD_LOGIC_VECTOR(TIME_WIDTH-1 downto 0);
       repeat_in : in  STD_LOGIC_VECTOR(31 downto 0);
       count_in  : in  STD_LOGIC_VECTOR(31 downto 0);
       sample_in : in  STD_LOGIC_VECTOR(TIME_WIDTH-1 downto 0)
    );
end  w7x_timing;


architecture Behavioral of w7x_timing is
    -- summary of valid states                                 SGPWActE
    constant IDLE           : std_logic_vector(7 downto 0) := "00000110";--  6
    constant ARMED          : std_logic_vector(7 downto 0) := "00001110";-- 14
    constant WAITING_DELAY  : std_logic_vector(7 downto 0) := "00010110";-- 22
    constant WAITING_SAMPLE : std_logic_vector(7 downto 0) := "01110010";--114
    constant WAITING_LOW    : std_logic_vector(7 downto 0) := "01010010";-- 82
    constant WAITING_HIGH   : std_logic_vector(7 downto 0) := "11010010";--210
    constant WAITING_REPEAT : std_logic_vector(7 downto 0) := "00110010";-- 50
		-- -- signals
    signal state        : std_logic_vector(7 downto 0) := IDLE;
    signal error        : std_logic_vector(ERROR_COUNT*8-1 downto 0) := (others => '0');
    -- measure number of samples in sequence, i.e. len(times)
    signal reset        : std_logic := '1'; -- start_cycle   =0, do_waiting_sample ++
    signal sample_count : integer := 0; -- start_cycle   =0, do_waiting_sample ++
    signal sample_total : integer := 0;
    -- measure number of repetitions
    signal repeat_count : integer := 0; -- start_program =0, start_waiting_repeat ++
    signal repeat_total : integer := 0;
    -- measure high and low of signal
    signal period_ticks : unsigned(31 downto 0) := (others => '0');
    signal high_total   : unsigned(31 downto 0) := (others => '0');
    signal period_total : unsigned(31 downto 0) := (others => '0');
    -- sequence counter
    signal cycle_ticks  : unsigned(TIME_WIDTH-1 downto 0) := (others => '0');
    signal delay_total  : unsigned(TIME_WIDTH-1 downto 0) := (others => '0');
    signal cycle_total  : unsigned(TIME_WIDTH-1 downto 0) := (others => '0');
    -- contains the next sample of interrest defined by index_out of the previous cycle
    signal curr_sample  : unsigned(TIME_WIDTH-1 downto 0) := (others => '0');
begin
    -- set input
    delay_total  <= unsigned(delay_in);
    high_total   <= unsigned(width_in);
    period_total <= unsigned(period_in);
    cycle_total  <= unsigned(cycle_in);
    repeat_total <= to_integer(unsigned(repeat_in));
    sample_total <= to_integer(unsigned(count_in));
    curr_sample  <= unsigned(sample_in);
    state_out(7 downto 1)    <= state(7 downto 1);
    state_out(0) <= not error(1);
    error_out    <= error;

  clock_gen:  process(clk_in, init_in, trig_in,
                      delay_total,
                      period_ticks, high_total, period_total,
                      cycle_ticks, cycle_total,
                      repeat_total,
                      sample_total, sample_count, curr_sample) is
  
    procedure do_error is
    begin
      error(ERROR_COUNT*8-1 downto 8) <= error(ERROR_COUNT*8-9 downto 0);
      error(7 downto 0) <= state;
      state <= ARMED;
    end do_error;

    procedure inc_cycle is
    begin
      cycle_ticks <= cycle_ticks  + 1;
    end inc_cycle;
    
    procedure inc_period is
    begin
      period_ticks <= period_ticks + 1;
      inc_cycle;
    end inc_period;

    procedure start_sample is
    -- resets period_ticks (1)
    begin
      state <= WAITING_HIGH;
      period_ticks <= (0=> '1', others => '0');
    end start_sample;

    procedure do_waiting_sample is
    -- increments sample_count
    begin
      if cycle_ticks = curr_sample then
        sample_count <= sample_count + 1;
        start_sample;
        inc_cycle;
      elsif cycle_ticks > curr_sample then
        do_error;
      else
        state <= WAITING_SAMPLE;
        inc_cycle;
      end if;
    end do_waiting_sample;

    procedure start_cycle is
    -- resets sample_count (1:0)
    -- resets cycle_ticks  (1)
    begin
      if curr_sample = 0 then -- short cut if first sample is at 0
        sample_count <= 1;
        start_sample;
      else
        sample_count <= 0;
        period_ticks <= (others => '0');
        state <= WAITING_SAMPLE;
      end if;
      cycle_ticks <= (0=> '1', others => '0');
    end start_cycle;
    
    procedure do_waiting_repeat is
    begin
      if cycle_ticks = cycle_total then -- short cut if cycle_total just fits sequence
        start_cycle;
      elsif cycle_ticks > cycle_total then
        do_error;
      else
        state <= WAITING_REPEAT;
        inc_cycle;
      end if;
    end do_waiting_repeat;

    procedure start_armed is
    -- resets everything
    begin
      cycle_ticks  <= (others => '0');
      period_ticks <= (others => '0');
      sample_count <= 0;
      repeat_count <= 0;
      state <= ARMED;
    end start_armed;
		
    procedure start_waiting_repeat is
    -- increments repeat_count
    begin
      if repeat_count < repeat_total then
        repeat_count <= repeat_count + 1;
        do_waiting_repeat;
      else
        start_armed;
      end if;
    end start_waiting_repeat;

    procedure start_waiting_sample is
    begin
      if sample_count < sample_total then
        do_waiting_sample;       
      else
        start_waiting_repeat;
      end if;
    end start_waiting_sample;     

    procedure do_waiting_low is
    begin
      if period_ticks = period_total then
        start_waiting_sample;
      elsif period_ticks > period_total then
        do_error;
      else
        state <= WAITING_LOW;
        inc_period;
      end if;
    end do_waiting_low;

    procedure do_waiting_high is
    begin
      if period_ticks = high_total then
        state <= WAITING_LOW;
        inc_period;
      elsif period_ticks > high_total then
        do_error;
      else
        state <= WAITING_HIGH;
        inc_period;
      end if;
    end do_waiting_high;

    procedure do_waiting_delay is
    begin
      if cycle_ticks = delay_total then
        if repeat_total > 0 and sample_total > 0 then
          start_cycle;
        else
          start_armed;
        end if;
      elsif cycle_ticks > delay_total then
        do_error;
      else
        state <= WAITING_DELAY;
        inc_cycle;
      end if;
    end do_waiting_delay;

    procedure start_program is
    -- resets repeat_count (1)
    -- resets cycle_ticks (_:1)
    begin
      repeat_count <= 1;
      if delay_total = 0 then -- short cut if no delay
        start_cycle;
      else
        state <= WAITING_DELAY;
        cycle_ticks <= (0=> '1', others => '0');
       end if;
    end start_program;

  begin  -- main program

    if init_in = '0' then
      state <= IDLE;
    elsif rising_edge(clk_in) then
      case state is
        when ARMED => 
          if trig_in = '1' then
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
        when IDLE =>
          start_armed;
        when others =>
          do_error;
      end case;
      if sample_count<sample_total then
        index_out <= std_logic_vector(to_unsigned(sample_count,32));
      else
        index_out <= (others => '0');
      end if;
    end if; -- rising_edge(clk)
    if clear_in = '1' then
      error <= (others => '0');
    end if;
  end process clock_gen;
end Behavioral;
