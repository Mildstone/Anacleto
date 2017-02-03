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
      ERROR_COUNT : integer := 7
    );
    port (
       clk_in        : in  STD_LOGIC;
       ctrl_in       : in  STD_LOGIC_VECTOR(7 downto 0);
       head_in       : in  STD_LOGIC_VECTOR(4*64-1 downto 0);
       head_out      : out STD_LOGIC_VECTOR(4*64-1 downto 0);
       ctrl_strb     : out STD_LOGIC_VECTOR(7 downto 0);
       ctrl_out      : out STD_LOGIC_VECTOR(7 downto 0);
       load_head_out : out STD_LOGIC;
       index_out     : out integer;
       state_out     : out STD_LOGIC_VECTOR(7 downto 0);
       error_out     : out STD_LOGIC_VECTOR(ERROR_COUNT*8-1 downto 0);
       sample_in     : in  STD_LOGIC_VECTOR(63 downto 0)
    );
end  w7x_timing;


architecture Behavioral of w7x_timing is
    constant i_init         : integer := 0;
    constant i_trig         : integer := 1;
    constant i_clear        : integer := 2;
    constant i_reinit       : integer := 3;
    constant i_save         : integer := 4;
     -- summary of valid states                                 SGPWActE
    constant IDLE           : std_logic_vector(7 downto 0) := "00000110";--  6
    constant ARMED          : std_logic_vector(7 downto 0) := "00001110";-- 14
    constant WAITING_DELAY  : std_logic_vector(7 downto 0) := "00010110";-- 22
    constant WAITING_SAMPLE : std_logic_vector(7 downto 0) := "01110010";--114
    constant WAITING_LOW    : std_logic_vector(7 downto 0) := "01010010";-- 82
    constant WAITING_HIGH   : std_logic_vector(7 downto 0) := "11010010";--210
    constant WAITING_REPEAT : std_logic_vector(7 downto 0) := "00110010";-- 50
	-- signals
	signal init         : std_logic;
	signal trig         : std_logic;
	signal clear        : std_logic;
	signal reinit       : std_logic;
	signal save         : std_logic;
    signal state        : std_logic_vector(7 downto 0) := IDLE;
    signal error        : std_logic_vector(ERROR_COUNT*8-1 downto 0) := (others => '0');
	signal load_head    : std_logic := '0';
    signal saved_head   : std_logic_vector(4*64-1 downto 0);
    signal sample       : unsigned(63 downto 0);
    -- measure number of samples in sequence, i.e. len(times)
    --signal reset        : std_logic := '1'; -- start_cycle   =0, do_waiting_sample ++
    signal sample_count : integer := 0; -- start_cycle   =0, do_waiting_sample ++
    signal index_out_buf: integer := 0;
    signal sample_total : integer := 0;
    -- measure number of repetitions
    signal repeat_count : integer := 0; -- start_program =0, start_waiting_repeat ++
    signal repeat_total : integer := 0;
    -- measure high and low of signal
    signal period_ticks : unsigned(31 downto 0) := to_unsigned(0,32);
    signal high_total   : unsigned(31 downto 0) := to_unsigned(0,32);
    signal period_total : unsigned(31 downto 0) := to_unsigned(0,32);
    -- sequence counter
    signal cycle_ticks  : unsigned(63 downto 0) := to_unsigned(0,64);
    signal delay_total  : unsigned(63 downto 0) := to_unsigned(0,64);
    signal cycle_total  : unsigned(63 downto 0) := to_unsigned(0,64);
    
begin
    -- set input
	init   <= ctrl_in(i_init);
    trig   <= ctrl_in(i_trig);
    clear  <= ctrl_in(i_clear);
    reinit <= ctrl_in(i_reinit);
    save   <= ctrl_in(i_save);
    sample       <=            unsigned(sample_in);
    delay_total  <=            unsigned(head_in(0*64+63 downto 0*64));
    high_total   <=            unsigned(head_in(1*64+31 downto 1*64));
    period_total <=            unsigned(head_in(1*64+63 downto 1*64+32));
    cycle_total  <=            unsigned(head_in(2*64+63 downto 2*64));
    repeat_total <= to_integer(unsigned(head_in(3*64+31 downto 3*64)));
    sample_total <= to_integer(unsigned(head_in(3*64+63 downto 3*64+32)));
    state_out(7 downto 1) <= state(7 downto 1);
    state_out(0) <= not error(1);
    error_out    <= error;  
    head_out      <= saved_head;
    load_head_out <= load_head;
  sample_check:process(sample_count,sample_total) is
  begin
    if sample_count<sample_total then
      index_out <= sample_count;
    else
      index_out <= 0;
    end if;
  end process;

  clock_gen:  process(clk_in, init, trig, clear, reinit,
                      delay_total,
                      period_ticks, high_total, period_total,
                      cycle_ticks, cycle_total,
                      repeat_total,
                      sample_total, sample_count, sample) is

    procedure unset(i : integer) is
    begin
      ctrl_out(i)  <= '0';
      ctrl_strb(i) <= '1';
    end unset;
    procedure set(i : integer) is
    begin
      ctrl_out(i)  <= '1';
      ctrl_strb(i) <= '1';
    end set;
    
    procedure inc_cycle is
    begin
      cycle_ticks <= cycle_ticks  + 1;
    end inc_cycle;
    
    procedure inc_period is
    begin
      period_ticks <= period_ticks + 1;
      inc_cycle;
    end inc_period;

    procedure start_sample(csample : integer) is
    -- resets period_ticks (1)
    -- increments sample_count
    begin
      sample_count <= csample + 1;
      state <= WAITING_HIGH;
      period_ticks <= (0=> '1', others => '0');
    end start_sample;

    procedure start_armed is
    -- resets everything
    begin
      cycle_ticks  <= to_unsigned(1,64);
      period_ticks <= to_unsigned(1,32);
      sample_count <= 0;
      repeat_count <= 0;
      state <= ARMED;
    end start_armed;

    procedure do_rearm is
    begin
      if reinit = '1' then
        load_head <= '1';
      end if;
      start_armed;
    end do_rearm;		
    
    procedure do_error(cstat : std_logic_vector(7 downto 0)) is
    begin
      --error(ERROR_COUNT*8-1 downto 8) <= error(ERROR_COUNT*8-9 downto 0);
      error( 7 downto 0)  <= cstat;
      error(15 downto 8)  <= state;
      error(55 downto 16) <= std_logic_vector(to_unsigned(to_integer(cycle_ticks),40));
      do_rearm;
    end do_error;

    procedure do_waiting_sample is
    begin
      if cycle_ticks = sample then
        start_sample(sample_count);
        inc_cycle;
      elsif cycle_ticks > sample then
        do_error(WAITING_SAMPLE);
      else
        state <= WAITING_SAMPLE;
        inc_cycle;
      end if;
    end do_waiting_sample;

    procedure start_cycle is
    -- resets sample_count (1:0)
    -- resets cycle_ticks  (1)
    begin
      if sample = 0 then -- short cut if first sample is at 0
        start_sample(0);
      else
        sample_count <= 0;
        period_ticks <= to_unsigned(0,32);
        state <= WAITING_SAMPLE;
      end if;
      cycle_ticks <= to_unsigned(1,64);
    end start_cycle;
    
    procedure do_waiting_repeat is
    begin
      if cycle_ticks = cycle_total then -- short cut if cycle_total just fits sequence
        start_cycle;
      elsif cycle_ticks > cycle_total then
        do_error(WAITING_REPEAT);
      else
        state <= WAITING_REPEAT;
        inc_cycle;
      end if;
    end do_waiting_repeat;

    procedure start_waiting_repeat is
    -- increments repeat_count
    begin
      if repeat_count < repeat_total then
        repeat_count <= repeat_count + 1;
        do_waiting_repeat;
      else
        do_rearm;
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
        do_error(WAITING_LOW);
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
        do_error(WAITING_HIGH);
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
          do_rearm;
        end if;
      elsif cycle_ticks > delay_total then
        do_error(WAITING_DELAY);
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
        cycle_ticks <= to_unsigned(1,64);
       end if;
    end start_program;

  begin  -- main program
    load_head <= '0';
    ctrl_out  <= (others => '0');
    ctrl_strb <= (others => '0');
    if init = '0' then
      state <= IDLE;
    elsif rising_edge(clk_in) then
      case state is
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
        when IDLE =>
          do_rearm;
        when others =>
          do_error(IDLE);
      end case;
      -- reset flags
      if trig = '1' then
        unset(i_trig);
      end if;
      if clear = '1' then    
        unset(i_clear);
        error <= (others => '0');
      end if;
      if save = '1' then    
        unset(i_save);
        saved_head <= head_in;
      end if;
    end if; -- rising_edge(clk)
  end process clock_gen;
end Behavioral;
