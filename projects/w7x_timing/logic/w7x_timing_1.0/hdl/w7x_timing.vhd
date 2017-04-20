library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity w7x_timing is
    generic (
      ADDR_WIDTH  : integer := 15;
      DATA_WIDTH  : integer := 64;
      TIME_WIDTH  : integer := 40;
      HEAD_COUNT  : integer := 6
    );
    port (
       clk_in     : in  STD_LOGIC;
       trigger_in : in  STD_LOGIC;
       armed_in   : in  STD_LOGIC;
       clear_in   : in  STD_LOGIC;
       head_in    : in  STD_LOGIC_VECTOR(HEAD_COUNT*DATA_WIDTH-1 downto 0);
       sample_in  : in  STD_LOGIC_VECTOR(TIME_WIDTH-1 downto 0);
       index_out  : out UNSIGNED(ADDR_WIDTH-1 downto 0);
       state_out  : out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0)
    );
end  w7x_timing;


architecture Behavioral of w7x_timing is
    constant zero32     : unsigned(        32-1 downto 0) := to_unsigned(0,32);
    constant zeroaddr   : unsigned(ADDR_WIDTH-1 downto 0) := to_unsigned(0,ADDR_WIDTH);
    constant zerotime   : unsigned(TIME_WIDTH-1 downto 0) := to_unsigned(0,TIME_WIDTH);
    constant one32      : unsigned(        32-1 downto 0) := to_unsigned(1,32);
    constant oneaddr    : unsigned(ADDR_WIDTH-1 downto 0) := to_unsigned(1,ADDR_WIDTH);
    constant onetime    : unsigned(TIME_WIDTH-1 downto 0) := to_unsigned(1,TIME_WIDTH);
     -- summary of valid states                                SGPWActE
    constant IDLE           : std_logic_vector(7 downto 0) := "00000110";--  6
    constant ARMED          : std_logic_vector(7 downto 0) := "00001110";-- 14
    constant WAITING_DELAY  : std_logic_vector(7 downto 0) := "00010110";-- 22
    constant WAITING_SAMPLE : std_logic_vector(7 downto 0) := "01110010";--114
    constant WAITING_LOW    : std_logic_vector(7 downto 0) := "01010010";-- 82
    constant WAITING_HIGH   : std_logic_vector(7 downto 0) := "11010010";--210
    constant WAITING_REPEAT : std_logic_vector(7 downto 0) := "00110010";-- 50
    -- signals
    signal state        : std_logic_vector(7 downto 0) := IDLE;
    signal error        : std_logic_vector(DATA_WIDTH-1 downto 8) := (others => '0');   
    signal sample       : unsigned(TIME_WIDTH-1 downto 0);
    -- measure number of samples in sequence, i.e. len(times)
    signal sample_count : unsigned(ADDR_WIDTH-1 downto 0) := zeroaddr; -- start_cycle   =0, do_waiting_sample ++
    signal sample_total : unsigned(ADDR_WIDTH-1 downto 0);
    -- measure number of repetitions
    signal repeat_count : unsigned(31 downto 0) := zero32; -- start_program =0, start_waiting_repeat ++
    signal repeat_total : unsigned(31 downto 0);
    -- measure number of bursts
    signal burst_count  : unsigned(TIME_WIDTH-1 downto 0) := zerotime; -- start_program =0, start_waiting_repeat ++
    signal burst_total  : unsigned(TIME_WIDTH-1 downto 0);
    -- measure high and low of signal
    signal period_ticks : unsigned(31 downto 0) := zero32;
    signal high_total   : unsigned(31 downto 0);
    signal period_total : unsigned(31 downto 0);
    -- sequence counter
    signal cycle_ticks  : unsigned(TIME_WIDTH-1 downto 0) := zerotime;
    signal delay_total  : unsigned(TIME_WIDTH-1 downto 0);
    signal cycle_total  : unsigned(TIME_WIDTH-1 downto 0);
begin
    -- set output
    index_out    <= sample_count when sample_count<sample_total else zeroaddr;
    state_out(7 downto 1) <= state(7 downto 1);
    state_out(0) <= not error(8+1);
    state_out(DATA_WIDTH-1 downto 8) <= error;

    -- set input
    sample       <= unsigned(sample_in(TIME_WIDTH-1 downto 0));
  buffer_input: process(clk_in,sample_in,head_in) begin
    if falling_edge(clk_in) then
      delay_total  <= unsigned(head_in(0*DATA_WIDTH+TIME_WIDTH-1 downto 0*DATA_WIDTH));
      high_total   <= unsigned(head_in(1*DATA_WIDTH+31           downto 1*DATA_WIDTH));
      period_total <= unsigned(head_in(1*DATA_WIDTH+31+32        downto 1*DATA_WIDTH+32));
      burst_total  <= unsigned(head_in(2*DATA_WIDTH+TIME_WIDTH-1 downto 2*DATA_WIDTH));
      cycle_total  <= unsigned(head_in(3*DATA_WIDTH+TIME_WIDTH-1 downto 3*DATA_WIDTH));
      repeat_total <= unsigned(head_in(4*DATA_WIDTH+31           downto 4*DATA_WIDTH));
      sample_total <= unsigned(head_in(5*DATA_WIDTH+ADDR_WIDTH-1 downto 5*DATA_WIDTH));
    end if;
  end process buffer_input;
  clock_gen:  process(clk_in, armed_in, trigger_in, clear_in, 
                      delay_total, high_total, period_total,
                      cycle_total, repeat_total,
                      sample_total, sample) is
    procedure inc_cycle is
    begin
      cycle_ticks <= cycle_ticks  + 1;
    end inc_cycle;
    
    procedure inc_period is
    begin
      period_ticks <= period_ticks + 1;
      inc_cycle;
    end inc_period;

    procedure start_sample(csample : unsigned) is
    -- resets period_ticks (1)
    -- increments sample_count
    begin
      sample_count <= csample + 1;
      state <= WAITING_HIGH;
      period_ticks <= one32;
    end start_sample;

    procedure start_armed is
    -- resets everything
    begin
      cycle_ticks  <= onetime;
      period_ticks <= one32;
      sample_count <= zeroaddr;
      repeat_count <= zero32;
      state <= ARMED;
    end start_armed;

    procedure do_rearm is
    begin
      start_armed;
    end do_rearm;        
    
    procedure do_error(cstat : std_logic_vector(7 downto 0)) is
    begin
      --error(ERROR_COUNT*8-1 downto 8) <= error(ERROR_COUNT*8-9 downto 0);
      error(15 downto 8)  <= cstat;
      error(23 downto 16) <= state;
      error(DATA_WIDTH-1 downto 24) <= std_logic_vector(cycle_ticks);
      do_rearm;
    end do_error;

    procedure do_waiting_sample is
    begin
      if cycle_ticks = sample then
        burst_count <= onetime;
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
        burst_count <= onetime;
        start_sample(zeroaddr);
      else
        sample_count <= zeroaddr;
        period_ticks <= zero32;
        state <= WAITING_SAMPLE;
      end if;
      cycle_ticks <= onetime;
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
        if burst_count = burst_total then
          start_waiting_sample;
        elsif burst_count > burst_total then
          do_error(WAITING_LOW);
        else
          burst_count <= burst_count + 1;
          start_sample(zeroaddr);
        end if;
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
      repeat_count <= one32;
      if delay_total = 0 then -- short cut if no delay
        start_cycle;
      else
        state <= WAITING_DELAY;
        cycle_ticks <= onetime;
       end if;
    end start_program;

  begin  -- main program
    if rising_edge(clk_in) then
      -- reset flags
      if clear_in = '1' then
        error <= (others => '0');
      end if;
      if error(8+1) = '0' then
        error(DATA_WIDTH-1 downto 24) <= std_logic_vector(cycle_ticks);
      end if;
      if armed_in = '0' then
        state <= IDLE;
      else
        case state is
          when ARMED => 
            if trigger_in = '1' then
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
      end if;
    end if; -- rising_edge(clk)
  end process clock_gen;
end Behavioral;
