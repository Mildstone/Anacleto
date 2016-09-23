library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rfx_pwmgen_v1_0 is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		sys_clk         : INTEGER := 125_000_000; --system clock frequency in Hz
        pwm_freq        : INTEGER := 100_000;    --PWM switching frequency in Hz
        bits_resolution : INTEGER := 8;          --bits of resolution setting the duty cycle
        phases          : INTEGER := 1;         --number of output pwms and phases
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 4
	);
	port (
		-- Users to add ports here
        clk       : IN  STD_LOGIC;                                    --system clock
        reset_n   : IN  STD_LOGIC;                                    --asynchronous reset
        pwm_out   : OUT STD_LOGIC_VECTOR(phases-1 DOWNTO 0);          --pwm outputs
        pwm_n_out : OUT STD_LOGIC_VECTOR(phases-1 DOWNTO 0);          --pwm inverse outputs
        led_o     : OUT std_logic;
        
        -- REG0, REG1, REG2, REG3: out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Slave Bus Interface S00_AXI
		s00_axi_aclk	: in std_logic;
		s00_axi_aresetn	: in std_logic;
		s00_axi_awaddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_awprot	: in std_logic_vector(2 downto 0);
		s00_axi_awvalid	: in std_logic;
		s00_axi_awready	: out std_logic;
		s00_axi_wdata	: in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_wstrb	: in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
		s00_axi_wvalid	: in std_logic;
		s00_axi_wready	: out std_logic;
		s00_axi_bresp	: out std_logic_vector(1 downto 0);
		s00_axi_bvalid	: out std_logic;
		s00_axi_bready	: in std_logic;
		s00_axi_araddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_arprot	: in std_logic_vector(2 downto 0);
		s00_axi_arvalid	: in std_logic;
		s00_axi_arready	: out std_logic;
		s00_axi_rdata	: out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_rresp	: out std_logic_vector(1 downto 0);
		s00_axi_rvalid	: out std_logic;
		s00_axi_rready	: in std_logic
	);
end rfx_pwmgen_v1_0;

architecture arch_imp of rfx_pwmgen_v1_0 is

    signal R0,R1,R2,R3: std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);  
	signal counter : std_logic_vector( 31 downto 0 );
    
	-- component declaration
	component rfx_pwmgen_v1_0_S00_AXI is
		generic (
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 4
		);
		port (
		S_AXI_ACLK	: in std_logic;
		S_AXI_ARESETN	: in std_logic;
		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		S_AXI_AWVALID	: in std_logic;
		S_AXI_AWREADY	: out std_logic;
		S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		S_AXI_WVALID	: in std_logic;
		S_AXI_WREADY	: out std_logic;
		S_AXI_BRESP	: out std_logic_vector(1 downto 0);
		S_AXI_BVALID	: out std_logic;
		S_AXI_BREADY	: in std_logic;
		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		S_AXI_ARVALID	: in std_logic;
		S_AXI_ARREADY	: out std_logic;
		S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_RRESP	: out std_logic_vector(1 downto 0);
		S_AXI_RVALID	: out std_logic;
		S_AXI_RREADY	: in std_logic;
		
		REG0 : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        REG1 : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        REG2 : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        REG3 : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0)
		);
	end component rfx_pwmgen_v1_0_S00_AXI;

    component pwm is
     GENERIC(
        sys_clk         : INTEGER := 50_000_000; --system clock frequency in Hz
        pwm_freq        : INTEGER := 100_000;    --PWM switching frequency in Hz
        bits_resolution : INTEGER := 8;          --bits of resolution setting the duty cycle
        phases          : INTEGER := 1);         --number of output pwms and phases
     PORT(
        clk       : IN  STD_LOGIC;                                    --system clock
        reset_n   : IN  STD_LOGIC;                                    --asynchronous reset
        ena       : IN  STD_LOGIC;                                    --latches in new duty cycle
        duty      : IN  STD_LOGIC_VECTOR(bits_resolution-1 DOWNTO 0); --duty cycle
        pwm_out   : OUT STD_LOGIC_VECTOR(phases-1 DOWNTO 0);          --pwm outputs
        pwm_n_out : OUT STD_LOGIC_VECTOR(phases-1 DOWNTO 0));         --pwm inverse outputs
    end component pwm;


begin

    

-- Instantiation of Axi Bus Interface S00_AXI
rfx_pwmgen_v1_0_S00_AXI_inst : rfx_pwmgen_v1_0_S00_AXI
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S00_AXI_ADDR_WIDTH
	)
	port map (
		S_AXI_ACLK	=> s00_axi_aclk,
		S_AXI_ARESETN	=> s00_axi_aresetn,
		S_AXI_AWADDR	=> s00_axi_awaddr,
		S_AXI_AWPROT	=> s00_axi_awprot,
		S_AXI_AWVALID	=> s00_axi_awvalid,
		S_AXI_AWREADY	=> s00_axi_awready,
		S_AXI_WDATA	=> s00_axi_wdata,
		S_AXI_WSTRB	=> s00_axi_wstrb,
		S_AXI_WVALID	=> s00_axi_wvalid,
		S_AXI_WREADY	=> s00_axi_wready,
		S_AXI_BRESP	=> s00_axi_bresp,
		S_AXI_BVALID	=> s00_axi_bvalid,
		S_AXI_BREADY	=> s00_axi_bready,
		S_AXI_ARADDR	=> s00_axi_araddr,
		S_AXI_ARPROT	=> s00_axi_arprot,
		S_AXI_ARVALID	=> s00_axi_arvalid,
		S_AXI_ARREADY	=> s00_axi_arready,
		S_AXI_RDATA	=> s00_axi_rdata,
		S_AXI_RRESP	=> s00_axi_rresp,
		S_AXI_RVALID	=> s00_axi_rvalid,
		S_AXI_RREADY	=> s00_axi_rready,
		
		REG0 => R0,
		REG1 => R1,
		REG2 => R2,
        REG3 => R3
	);

	-- Add user logic here
    pwm_inst : pwm
    generic map (
     sys_clk => sys_clk,
     pwm_freq => pwm_freq,
     bits_resolution => bits_resolution,
     phases => phases
    )
    port map (
     clk => clk,
     reset_n => reset_n,
     ena => R0(0),
     duty => R1(bits_resolution-1 downto 0),
     pwm_out => pwm_out,
     pwm_n_out => pwm_n_out
    );
	-- User logic ends



  -- led blink
--  process(clk)
--  begin
--    if rising_edge(clk) then
--        counter <= std_logic_vector(unsigned(counter) + 1);
    led_o <= R0(0);
--    end if;
--  end process;




end arch_imp;
