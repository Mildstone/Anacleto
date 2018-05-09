library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;
--use IEEE.STD_LOGIC_ARITH.ALL;

--library unisim;
--use unisim.vcomponents.all;

-------------------------------------------------------------------------------
entity trarec_tb1 is
  generic(

    -- Master AXI Stream Data Width
    C_M_AXIS_DATA_WIDTH : integer range 32 to 256 := 32;

    -- Slave AXI Stream Data Width
    C_S_AXIS_DATA_WIDTH : integer range 32 to 256 := 32

    );
  port (

    -- Global Ports
    aclk    : out std_logic;
    
    -- registers
    pre_post_cfg : out std_logic_vector(C_M_AXIS_DATA_WIDTH-1 downto 0);
    command_cfg : out std_logic_vector(C_M_AXIS_DATA_WIDTH-1 downto 0);
    mode_cfg : out std_logic_vector(C_M_AXIS_DATA_WIDTH-1 downto 0);
    
    
    

    -- Master Stream Ports--  m_axis_aresetn : out std_logic;
    s_axis_tdata   : out std_logic_vector(C_M_AXIS_DATA_WIDTH-1 downto 0);
    s_axis_tvalid  : out std_logic;
    s_axis_tready  : in  std_logic;
    trigger : out std_logic

    );

end trarec_tb1;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------


architecture implementation of trarec_tb1 is
    constant c_CLK_PERIOD : time := 10 ns;
    
    signal tready      : std_logic      := '1';
    signal in_aclk      : std_logic      := '0';
    signal valid    : std_logic      := '0';
    signal tdata   : std_logic_vector(C_M_AXIS_DATA_WIDTH-1 downto 0) := (0 => '1', others => '0');



begin
    aclk <= in_aclk;
    s_axis_tdata <= tdata;
    s_axis_tvalid <= valid;
    
    
    command_cfg <= (0 => '1', others => '0');  --arm soon
    mode_cfg <= (1 => '1', 2 => '1', 9 => '1', 20 => '1', others => '0');  --trig level : 16, 2 samples for trigger, up, from chana
    pre_post_cfg <= (3 => '1', 18 => '1', others => '0');  --8 post trigger samples, 4 pre trigger samples
    
    
    in_aclk <= not in_aclk after c_CLK_PERIOD/2;
    aclk <= in_aclk;
    stimulus: process (in_aclk)
        variable v_Count : natural range 0 to 20 := 0;
        variable tot_count : integer := 0;
          begin
            if falling_edge(in_aclk) then
                tot_count := tot_count + 1;
                if tot_count > 5 and tot_count < 7 then
                    trigger <= '1';
                else
                    trigger <= '0';
                end if;
  
                if tot_Count  >  5 and (tot_Count mod 3 = 0 or tot_Count mod 5 = 0) then 
                    v_Count := v_Count + 1;           -- Variable
                    if v_Count > 20 then
                        v_Count := 0;
                    end if;
                    valid <= '1';
                    tdata <= std_logic_vector(to_unsigned(v_Count, C_M_AXIS_DATA_WIDTH));
                else
                    valid <= '0';
               end if;
            end if;
     end process stimulus;

end implementation;
