library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;
--use IEEE.STD_LOGIC_ARITH.ALL;

--library unisim;
--use unisim.vcomponents.all;

-------------------------------------------------------------------------------
entity trarec_tb is
  generic(

    -- Master AXI Stream Data Width
    C_M_AXIS_DATA_WIDTH : integer range 32 to 256 := 32;

    -- Slave AXI Stream Data Width
    C_S_AXIS_DATA_WIDTH : integer range 32 to 256 := 32

    );
  port (

    -- Global Ports
    aclk    : out std_logic;

    -- Master Stream Ports--  m_axis_aresetn : out std_logic;
    axis_tdata   : out std_logic_vector(C_M_AXIS_DATA_WIDTH-1 downto 0);
    axis_tvalid  : out std_logic;
    axis_tready  : in  std_logic

    );

end trarec_tb;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------


architecture implementation of trarec_tb is
    constant c_CLK_PERIOD : time := 10 ns;
    component trarec is
       port (

        -- Global Ports
        aclk    : in std_logic;
        aresetn : in std_logic;

        -- Master Stream Ports
        m_axis_tdata   : out std_logic_vector(C_M_AXIS_DATA_WIDTH-1 downto 0);
        m_axis_tvalid  : out std_logic;
        m_axis_tready  : in  std_logic;

        -- Slave Stream Ports
        s_axis_tdata   : in  std_logic_vector(C_S_AXIS_DATA_WIDTH-1 downto 0) := (others => '0');
        s_axis_tvalid  : in  std_logic;
        s_axis_tready  : out std_logic;

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
    

--  Test LED    
        led_o : out std_logic;
        led1_o : out std_logic
        );

    end component trarec;

    signal in_aresetn :  std_logic := '0';
    signal in_tready      : std_logic      := '1';
    signal in_aclk      : std_logic      := '0';
    signal in_tvalid    : std_logic      := '0';
    signal in_tdata   : std_logic_vector(C_M_AXIS_DATA_WIDTH-1 downto 0) := (0 => '1', 1=>'1', others => '0');

    signal addra   : std_logic_vector(C_M_AXIS_DATA_WIDTH-1 downto 0) := (others => '0');
    signal dina   : std_logic_vector(C_M_AXIS_DATA_WIDTH-1 downto 0) := (others => '1');
    signal douta   : std_logic_vector(C_M_AXIS_DATA_WIDTH-1 downto 0) := (others => '1');
    signal ena : std_logic := '0';
    signal rsta : std_logic := '0';
    signal wea : std_logic_vector(3 downto 0) := (others => '1');
    
    signal addrb   : std_logic_vector(C_M_AXIS_DATA_WIDTH-1 downto 0) := (others => '0');
    signal dinb   : std_logic_vector(C_M_AXIS_DATA_WIDTH-1 downto 0) := (others => '1');
    signal doutb   : std_logic_vector(C_M_AXIS_DATA_WIDTH-1 downto 0) := (others => '1');
    signal enb : std_logic := '0';
    signal rstb : std_logic := '0';
    signal web : std_logic_vector(3 downto 0) := (others => '1');
    
    signal pre_post_reg: std_logic_vector(C_S_AXIS_DATA_WIDTH-1 downto 0) := (others => '0');
    signal mode_reg: std_logic_vector(C_S_AXIS_DATA_WIDTH-1 downto 0) := (others => '0');
    signal command_reg:  std_logic_vector(C_S_AXIS_DATA_WIDTH-1 downto 0) := (others => '0');
    
    signal trigger : std_logic := '0'; 



begin

    trarec_inst : trarec
       port map (
         aclk    => in_aclk,
         aresetn => in_aresetn,
         m_axis_tdata => axis_tdata,
         m_axis_tvalid => axis_tvalid,
         m_axis_tready => in_tready,
         s_axis_tdata => in_tdata,
         s_axis_tvalid => in_tvalid,
         s_axis_tready => in_tready,

         cbuf_addra => addra,
--         cbuf_clka   => in_aclk,
         cbuf_dina => dina,
         cbuf_douta => douta,
         cbuf_ena => ena,
         cbuf_rsta => rsta,
         cbuf_wea => wea,
          
--         cbuf_addrb => addrb,
--         cbuf_clkb   => in_aclk,
         cbuf_dinb => dinb,
         cbuf_doutb => doutb,
         cbuf_enb => enb,
         cbuf_rstb => rstb,
         cbuf_web => web,

         pre_post_cfg => pre_post_reg,
         mode_cfg => mode_reg,
         command_cfg => command_reg,
         
         trigger_in => trigger
    
    );

 
    in_aresetn <= '0';

    in_aclk <= not in_aclk after c_CLK_PERIOD/2;
    aclk <= in_aclk;
    stimulus: process (in_aclk)
        variable v_Count : natural range 0 to 20 := 0;
         begin
            if falling_edge(in_aclk) then
                v_Count := v_Count + 1;           -- Variable
                 if v_Count = 20 then
                    v_Count := 0;
                    in_tdata <= (0 => '1', 1=>'1', others => '0');
               end if;
                if v_Count  >  5 and (v_Count mod 3 = 0) then 
                    in_tvalid <= '1';
                    in_tdata <= std_logic_vector(signed(in_tdata) -  1);
                else
                    in_tvalid <= '0';
                 end if;
            end if;
     end process stimulus;

end implementation;
