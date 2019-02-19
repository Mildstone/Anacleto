
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

--library unisim;
--use unisim.vcomponents.all;

-------------------------------------------------------------------------------
entity trarec is
  generic(

    -- Master AXI Stream Data Width
    C_M_AXIS_DATA_WIDTH : integer range 32 to 256 := 32;
    
    -- Slave AXI Stream Data Width
    C_S_AXIS_DATA_WIDTH : integer range 32 to 256 := 32;
    
    -- Circular buffer size
    C_CBUF_SIZE: integer := 65536;
    
    --pre-post max value
    C_PRE_POST_MAX: integer := 65536
    
    );
  port (

    -- Global Ports
    aclk    : in std_logic;
    aresetn : in std_logic;

    -- Master Stream Ports
--  data port
    m_axis_tdata   : out std_logic_vector(C_M_AXIS_DATA_WIDTH-1 downto 0);
--  m_axis_tstrb   : out std_logic_vector((C_M_AXIS_DATA_WIDTH/8)-1 downto 0);
    m_axis_tvalid  : out std_logic;
    m_axis_tready  : in  std_logic;
--  m_axis_tlast   : out std_logic;

--  data port
    t_axis_tdata   : out std_logic_vector(C_M_AXIS_DATA_WIDTH-1 downto 0);
    t_axis_tvalid  : out std_logic;
    t_axis_tready  : in  std_logic;

    -- Slave Stream Ports
--  s_axis_aresetn : in  std_logic;
    s_axis_tdata   : in  std_logic_vector(C_S_AXIS_DATA_WIDTH-1 downto 0);
--  s_axis_tstrb   : in  std_logic_vector((C_S_AXIS_DATA_WIDTH/8)-1 downto 0);
    s_axis_tvalid  : in  std_logic;
    s_axis_tready  : out std_logic;
--  s_axis_tlast   : in  std_logic

   
--   circular buffer (block memory) Port A
    cbuf_addra: out std_logic_vector(C_S_AXIS_DATA_WIDTH-1 downto 0);
    cbuf_clka : out std_logic;
    cbuf_dina: out std_logic_vector(C_S_AXIS_DATA_WIDTH-1 downto 0);
    cbuf_douta: in std_logic_vector(C_S_AXIS_DATA_WIDTH-1 downto 0);
    cbuf_ena : out std_logic;  
    cbuf_rsta : out std_logic;  
    cbuf_wea : out std_logic_vector(3 downto 0);

--   circular buffer (block memory) Port B
    cbuf_addrb: out std_logic_vector(C_S_AXIS_DATA_WIDTH-1 downto 0);
    cbuf_clkb : out std_logic;
    cbuf_dinb: out std_logic_vector(C_S_AXIS_DATA_WIDTH-1 downto 0);
    cbuf_doutb: in std_logic_vector(C_S_AXIS_DATA_WIDTH-1 downto 0);
    cbuf_enb : out std_logic;  
    cbuf_rstb : out std_logic;  
    cbuf_web : out std_logic_vector(3 downto 0);

-- Configuration registers

-- pre_post_cfg: upper 16 bits: pre trigger samples, lower 16 bits: post trigger samples
    pre_post_cfg: in std_logic_vector(C_S_AXIS_DATA_WIDTH-1 downto 0);
    
--    
    mode_cfg: in std_logic_vector(C_S_AXIS_DATA_WIDTH-1 downto 0);
    command_cfg: in std_logic_vector(C_S_AXIS_DATA_WIDTH-1 downto 0);
-- trigger
    trigger_in: in std_logic;
 
 -- debug putpose
    out_state: out std_logic_vector(3 downto 0);   
    dbg_cbuf_in_addr: out std_logic_vector(C_S_AXIS_DATA_WIDTH-1 downto 0); 
    dbg_cbuf_curr_in_addr: out std_logic_vector(C_S_AXIS_DATA_WIDTH-1 downto 0); 
    dbg_cbuf_start_out_addr: out std_logic_vector(C_S_AXIS_DATA_WIDTH-1 downto 0); 
    out_count: out std_logic_vector(C_S_AXIS_DATA_WIDTH-1  downto 0);
    
    
--  Test LED    
    led_o : out std_logic;
    led1_o : out std_logic
    );

end trarec;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------



architecture implementation of trarec is

    constant STATE_IDLE: integer := 1;
    constant STATE_ARMED: integer := 2;
    constant STATE_STREAM: integer := 3;
    constant STATE_RUNNING: integer := 4;
    constant STATE_TRIGGER_CHECK: integer := 5;
    constant STATE_TRIGGERED_WAIT_POST: integer := 6;

--Block memory states
   constant MEM_IDLE: integer := 1;
   constant MEM_START: integer := 2;
   constant MEM_PIPE: integer := 3;
   constant MEM_NO_PIPE: integer := 4;

-- Command register: bit 0: Arm; bit 1: Stop; bit 2: SW trigger
    signal arm_cmd: std_logic;
    signal stop_cmd: std_logic;
    signal trig_cmd: std_logic;
    signal is_up: std_logic;
    signal continuous: std_logic;
    signal trig_from_chana: std_logic;
    signal cbuf_in_addr : std_logic_vector (C_S_AXIS_DATA_WIDTH-1 downto 0) := (others => '0');         -- only updted during readout 
    signal cbuf_curr_in_addr : std_logic_vector (C_S_AXIS_DATA_WIDTH-1 downto 0) := (others => '0');    --always updated when new data arrive
    signal cbuf_start_out_addr : std_logic_vector (C_S_AXIS_DATA_WIDTH-1 downto 0)  := (others => '1');        --only updated when different from cbuf_in_addr       
    signal trig_level : std_logic_vector (15 downto 0) := (others => '0');
    signal curr_state : std_logic_vector (3 downto 0);
    signal trigger_time: std_logic_vector (63 downto 0) := (others => '0'); 
    signal trigger_time_mask: std_logic_vector (1 downto 0) := (others => '0');
begin
    dbg_cbuf_in_addr <= cbuf_in_addr;
    dbg_cbuf_curr_in_addr <= cbuf_curr_in_addr;
    dbg_cbuf_start_out_addr <= cbuf_start_out_addr;
    out_state <= curr_state;


    cbuf_clka <= aclk;
    cbuf_wea <= "1111";
    cbuf_rsta <= '0';
    --cbuf_dina <= s_axis_tdata;
    cbuf_clkb <= aclk;
    cbuf_web <= "0000";
    cbuf_rstb <= '0';
     
    arm_cmd <= command_cfg(0);
    stop_cmd <= command_cfg(1);
    trig_cmd <= command_cfg(2);
    is_up <= mode_cfg(2);
    trig_from_chana <= mode_cfg(1);
    continuous <= mode_cfg(0);
    trig_level <= mode_cfg(31 downto 16);
    
    --Handle cirbular buffer insertion/removal
    handle_cbuf: process(aclk)
        variable data: std_logic_vector(C_M_AXIS_DATA_WIDTH-1 downto 0);
        variable available: std_logic := '0';     --
        variable out_addr : integer range 0 to  C_PRE_POST_MAX := 0;     -- circular buffer read address
        variable in_addr : integer range 0 to  C_PRE_POST_MAX := 0;      -- circular buffer write address frozen by process handle_event 
        variable curr_in_addr : integer range 0 to  C_PRE_POST_MAX := 0; -- circular buffer current write adderss, always incremented when a new sample is available
        variable mem_state : integer range 0 to MEM_NO_PIPE := MEM_IDLE;


        begin
            if(falling_edge(aclk)) then
                if continuous = '1' and curr_state(2) = '1' then  -- if simple streaming and RUNNING
                    m_axis_tvalid <= s_axis_tvalid;
                    m_axis_tdata <= s_axis_tdata;
                    s_axis_tready <= m_axis_tready;
--                if continuous = '0' then  -- if simple streaming
--                    m_axis_tvalid <= s_axis_tvalid;
--                    m_axis_tdata <= (0 => curr_state(0), 1 => curr_state(1), 2 => curr_state(2), 3 => curr_state(3), others => '0');
--                    s_axis_tready <= m_axis_tready;
                else
                    s_axis_tready <= '1';
            -- Check if there are  samples to be read from circular buffer and sent to FIFO
                    if mem_state = MEM_PIPE or mem_state = MEM_NO_PIPE then
                        m_axis_tvalid <= '1';
                        m_axis_tdata <= cbuf_doutb;
                    else
                        m_axis_tvalid <= '0';
                    end if;
                end if;

                in_addr := to_integer(unsigned(cbuf_in_addr)); --cbuf_in_addr is the only address possibli changed outside this process
                if not (cbuf_start_out_addr = "11111111111111111111111111111111")  then --if it is has just been set
                    out_addr := to_integer(unsigned(cbuf_start_out_addr));
                end if;
                if in_addr /= out_addr then   --Data in circular buffer must be sent to FIFO
                    cbuf_addrb <= std_logic_vector(to_unsigned(out_addr, C_S_AXIS_DATA_WIDTH));
                    out_addr := out_addr + 1;
                    if out_addr = C_CBUF_SIZE  then
                        out_addr := 0;
                    end if;
                    cbuf_enb <= '1';
                    case mem_state is
                        when MEM_IDLE => 
                            mem_state := MEM_START;
                         when MEM_START => 
                            mem_state := MEM_PIPE;
                        when MEM_PIPE =>
                            mem_state := MEM_PIPE;
                        when MEM_NO_PIPE =>
                            mem_state := MEM_START;
                        when others =>
                    end case;
                 else    
                     case mem_state is
                         when MEM_IDLE => 
                             mem_state := MEM_IDLE;
                         when MEM_START => 
                             mem_state := MEM_NO_PIPE;
                         when MEM_PIPE =>
                             mem_state := MEM_NO_PIPE;
                         when MEM_NO_PIPE =>
                             mem_state := MEM_IDLE;
                             cbuf_enb <= '0';

                         when others =>
                    end case;
                end if;
                
                --write to circular buffer, performed every time a new sample is available in s_axis
                if available = '1' then
                     available := '0';
                     cbuf_addra <= std_logic_vector(to_unsigned(curr_in_addr, C_S_AXIS_DATA_WIDTH)); 
                     curr_in_addr := curr_in_addr + 1;
--                     if(curr_in_addr = C_CBUF_SIZE - 1) then
                     if(curr_in_addr = C_CBUF_SIZE) then
                         curr_in_addr := 0;
                     end if;
                     cbuf_curr_in_addr <= std_logic_vector(to_unsigned(curr_in_addr, C_S_AXIS_DATA_WIDTH)); 
                     cbuf_ena <= '1';
                     cbuf_dina <= data;
                 else
                     cbuf_ena <= '0';
                 end if;
                 if trigger_time_mask(0) = '1' then
                     t_axis_tvalid <= '1';
                     t_axis_tdata <= trigger_time(31 downto 0);
                 else 
                     if trigger_time_mask(1) = '1' then
                        t_axis_tvalid <= '1';
                        t_axis_tdata <= trigger_time(63 downto 32);
                     else
                        t_axis_tvalid <= '0'; 
                     end if;
                 end if;
            end if;   
            -- check for new avilable sample from s_axis
            if (rising_edge(aclk)) then
                if s_axis_tvalid = '1' then
                    available := '1';
                    data := s_axis_tdata;
                end if;
            end if;
        end process;

        handle_state : process(aclk)
    --State Machine 
            variable state : integer range 0 to 16 := STATE_IDLE;
            variable selected_chan : integer;
            variable curr_count : integer := 0;
            variable out_address : integer := 0;
            begin
                if rising_edge(aclk) then
                    case state is
                        when STATE_IDLE => 
                            if arm_cmd = '1' then
                                state := STATE_ARMED;
                            end if;
                        when STATE_ARMED =>
                            if stop_cmd = '1' then
                                state := STATE_IDLE;
                            else
                                if trigger_in = '1' or trig_cmd = '1' then
                                    trigger_time <= (others => '0');
                                    state := STATE_RUNNING;
                                end if;
                            end if;
                        when STATE_RUNNING => 
                            if stop_cmd = '1' then
                                state := STATE_IDLE;
                            else
                                 if s_axis_tvalid = '1' and continuous = '0' then
                                    trigger_time <= std_logic_vector(unsigned(trigger_time)+1);
                                    if trig_from_chana = '1' then  -- chana -> lest significant 16 bytes
                                       selected_chan := to_integer(signed(s_axis_tdata(15 downto 0)));
                                    else
                                       selected_chan := to_integer(signed(s_axis_tdata(31 downto 16)));
                                    end if;
                                    if (is_up = '1' and selected_chan > to_integer(signed(trig_level))) or 
                                        (is_up = '0' and selected_chan < to_integer(signed(trig_level))) then
                                        state := STATE_TRIGGER_CHECK;
                                        curr_count := 0;
                                    end if; 
                                end if;  
                             end if;  
                        when STATE_TRIGGER_CHECK =>
                            if stop_cmd = '1' then
                                state := STATE_IDLE;
                            else
                                if s_axis_tvalid = '1' then
                                    trigger_time <= std_logic_vector(unsigned(trigger_time)+1);
                                    if trig_from_chana = '1' then  -- chana -> least significant 16 bytes
                                        selected_chan := to_integer(signed(s_axis_tdata(15 downto 0)));
                                    else
                                        selected_chan := to_integer(signed(s_axis_tdata(31 downto 16)));
                                    end if;
                                    if (is_up = '1' and selected_chan > to_integer(signed(trig_level))) or 
                                         (is_up = '0' and selected_chan < to_integer(signed(trig_level))) then
                                        if curr_count >= to_integer(unsigned(mode_cfg(15 downto 8))) then
                                            state := STATE_TRIGGERED_WAIT_POST;
                                            curr_count := to_integer(unsigned(mode_cfg(15 downto 8)));
                                            --compute c_out_addr
                                            out_address := to_integer(unsigned(cbuf_curr_in_addr));
                                            out_address := out_address - to_integer(unsigned(pre_post_cfg(31 downto 16)));
                                            out_address := out_address - curr_count; 
                                            --pre-trigger is referred to the first occurrence of trigger event
                                             if out_address < 0 then
                                                out_address := out_address + C_CBUF_SIZE;
                                             end if;
                                             cbuf_start_out_addr <= std_logic_vector(to_unsigned(out_address, C_S_AXIS_DATA_WIDTH));
                                             cbuf_in_addr <= cbuf_curr_in_addr;
                                             trigger_time_mask <= (others => '1');
                                        else
                                             curr_count := curr_count + 1;
                                        end if;
                                    else
                                        state := STATE_RUNNING;  --trigger condition not lasting enough
                                    end if; 
                                 end if;  
                            end if;  
                        when STATE_TRIGGERED_WAIT_POST =>
                            if trigger_time_mask(0) = '1' then
                                trigger_time_mask(0) <= '0';
                            else
                                if trigger_time_mask(1) = '1' then
                                    trigger_time_mask(1) <= '0';
                                end if;
                            end if;    
                            cbuf_start_out_addr <= (others => '1'); --all ones means invalid
                            if stop_cmd = '1' then
                                state := STATE_IDLE;
                            else
                               if s_axis_tvalid = '1' then
                                    trigger_time <= std_logic_vector(unsigned(trigger_time)+1);
                                    curr_count := curr_count + 1;
                                    cbuf_in_addr <= cbuf_curr_in_addr;
                                    if curr_count >= to_integer(unsigned(pre_post_cfg(15 downto 0))) then
                                        state := STATE_RUNNING; --finished post samples
                                    end if;
                                end if;
                            end if; 
                        when others =>
                            state := STATE_IDLE;                                 
                     end case;
                     curr_state <= std_logic_vector(to_unsigned(state, 4));
                     out_count <= std_logic_vector(to_unsigned(curr_count, C_S_AXIS_DATA_WIDTH));
                end if;
            end process;
            



--test upon trigger reception, produce the first three samples
--    test trigger: process(aclk)
--        variable triggered : std_logic := '0';
--        variable in_addr : integer := 0;
--        begin
--            if rising_edge(aclk) then
--                if trigger_in = '1' and triggered = '0' then
--                    triggered := '1';
--                    in_addr := to_integer(unsigned(cbuf_out_addr)) + 3;
--                    if in_addr >= C_CBUF_SIZE then
--                        in_addr := in_addr - C_CBUF_SIZE;
--                    end if;
--                    cbuf_in_addr <= std_logic_vector(to_unsigned(in_addr,  C_S_AXIS_DATA_WIDTH));
--                end if;
--                if trigger_in = '0' then
--                    triggered := '0';
--                end if;
--            end if;
--        end process;
            




  led_o <= '1';

  

end implementation;

