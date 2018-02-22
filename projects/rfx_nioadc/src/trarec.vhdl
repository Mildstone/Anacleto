
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
    C_S_AXIS_DATA_WIDTH : integer range 32 to 256 := 32
 
    );
  port (

    -- Global Ports
    aclk    : in std_logic;
    aresetn : in std_logic;

    -- Master Stream Ports
--  m_axis_aresetn : out std_logic;
    m_axis_tdata   : out std_logic_vector(C_M_AXIS_DATA_WIDTH-1 downto 0);
--  m_axis_tstrb   : out std_logic_vector((C_M_AXIS_DATA_WIDTH/8)-1 downto 0);
    m_axis_tvalid  : out std_logic;
    m_axis_tready  : in  std_logic;
--  m_axis_tlast   : out std_logic;

    -- Slave Stream Ports
--  s_axis_aresetn : in  std_logic;
    s_axis_tdata   : in  std_logic_vector(C_S_AXIS_DATA_WIDTH-1 downto 0);
--  s_axis_tstrb   : in  std_logic_vector((C_S_AXIS_DATA_WIDTH/8)-1 downto 0);
    s_axis_tvalid  : in  std_logic;
    s_axis_tready  : out std_logic;
--  s_axis_tlast   : in  std_logic
    
    led_o : out std_logic

    );

end trarec;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------


architecture implementation of trarec is


begin

  -- m_axis_tdata <= s_axis_tdata;
  -- m_axis_tvalid <= s_axis_tvalid;
  --  s_axis_tready <=  m_axis_tready;


      handle_bus: process(aclk)

      variable data: std_logic_vector(C_M_AXIS_DATA_WIDTH-1 downto 0);
      variable available: std_logic := '0';

      begin
        if aresetn = '1' then
            available := '0';
            s_axis_tready <= '0';
            m_axis_tvalid <= '0';
            m_axis_tdata <= (others => '0');
        else
            s_axis_tready <= '1';
            if(falling_edge(aclk)) then
                if available = '1' then
                    m_axis_tvalid <= '1';
                    available := '0';
                    m_axis_tdata <= data;
                else
                    m_axis_tvalid <= '0';
                end if;
            end if;              
            if (rising_edge(aclk)) then
                if s_axis_tvalid = '1' then
                    data := s_axis_tdata;
                    available := '1';
                end if;
            end if;
         end if;
       end process;
  
  
      
 

  led_o <= '1';

  

end implementation;

