library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity w7x_timing_v1_0_S00_AXI is
    generic (
      DATA_COUNT   : integer := 16;
        -- S_AXI data bus parameters
      DATA_WIDTH     : integer := 64;
      ADDR_WIDTH     : integer := 15;
      AXI_ADDR_WIDTH : integer := 18
    );
    port (
     ADDR_OUT      : out   UNSIGNED(ADDR_WIDTH-1 downto 0);
     DATA_IN       : in    STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
     DATA_OUT      : out   STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
     STRB_OUT      : out   STD_LOGIC_VECTOR((DATA_WIDTH/8)-1 downto 0);
     EN_OUT        : out   STD_LOGIC;
     WE_OUT        : out   STD_LOGIC;
      
     -- AXI ports
     S_AXI_CLK     : in  std_logic;
     S_AXI_RESETN  : in  std_logic;
     S_AXI_AWADDR  : in  std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
     S_AXI_AWPROT  : in  std_logic_vector(2 downto 0);
     S_AXI_AWVALID : in  std_logic;
     S_AXI_AWREADY : out std_logic;
     S_AXI_WDATA   : in  std_logic_vector(DATA_WIDTH-1 downto 0);
     S_AXI_WSTRB   : in  std_logic_vector((DATA_WIDTH/8)-1 downto 0);
     S_AXI_WVALID  : in  std_logic;
     S_AXI_WREADY  : out std_logic;
     S_AXI_BRESP   : out std_logic_vector(1 downto 0);
     S_AXI_BVALID  : out std_logic;
     S_AXI_BREADY  : in  std_logic;
     S_AXI_ARADDR  : in  std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
     S_AXI_ARPROT  : in  std_logic_vector(2 downto 0);
     S_AXI_ARVALID : in  std_logic;
     S_AXI_ARREADY : out std_logic;
     S_AXI_RDATA   : out std_logic_vector(DATA_WIDTH-1 downto 0);
     S_AXI_RRESP   : out std_logic_vector(1 downto 0);
     S_AXI_RVALID  : out std_logic;
     S_AXI_RREADY  : in  std_logic
    );
end w7x_timing_v1_0_S00_AXI;

architecture arch_imp of w7x_timing_v1_0_S00_AXI is
    constant DATA_LIMIT : unsigned(ADDR_WIDTH-1 downto 0) := to_unsigned(DATA_COUNT,ADDR_WIDTH);
    -- AXI4LITE signals
    signal axi_aaddr   : unsigned(ADDR_WIDTH-1 downto 0);
    signal axi_awready : std_logic := '1';
    signal axi_wready  : std_logic := '1';
    signal axi_wdata   : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal axi_wstrb   : std_logic_vector(DATA_WIDTH/8-1 downto 0);
    signal axi_bvalid  : std_logic := '0';
    signal axi_arready : std_logic := '1';
    signal axi_rdata   : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal axi_rvalid  : std_logic := '0';
    signal bram_en     : std_logic := '0';

    function axi_addr2addr(addr : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0)) return unsigned is
    -- local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
    -- ADDR_LSB is used for addressing 32/64 bit registers/memories
    -- ADDR_LSB = 2 for 32 bits (n downto 2)
    -- ADDR_LSB = 3 for 64 bits (n downto 3)
    --constant ADDR_LSB  : integer := (DATA_WIDTH/32)+ 1;
    --constant OPT_MEM_ADDR_BITS : integer := ADDR_WIDTH-ADDR_LSB;
    begin
      return unsigned(addr(AXI_ADDR_WIDTH-1 downto AXI_ADDR_WIDTH-ADDR_WIDTH));
    end axi_addr2addr;

begin
    ADDR_OUT <= unsigned(axi_aaddr);
    DATA_OUT <= axi_wdata;
    STRB_OUT <= axi_wstrb;
    EN_OUT   <= S_AXI_AWVALID or S_AXI_ARVALID or bram_en;
    WE_OUT   <= not axi_wready;
---- AXI interface
    -- I/O Connections assignments
    S_AXI_AWREADY <= axi_awready;
    S_AXI_WREADY  <= axi_wready;
    S_AXI_BRESP   <= "00";
    S_AXI_BVALID  <= axi_bvalid;
    S_AXI_ARREADY <= axi_arready;
    S_AXI_RDATA   <= axi_rdata;
    S_AXI_RRESP   <= "00";
    S_AXI_RVALID  <= axi_rvalid;

    process (S_AXI_CLK,S_AXI_RESETN,
             S_AXI_AWVALID,S_AXI_WVALID,S_AXI_AWADDR,S_AXI_WSTRB,S_AXI_WDATA, S_AXI_BREADY,
             S_AXI_ARADDR, S_AXI_RREADY,
             DATA_IN)

    procedure check is begin
      if (S_AXI_RESETN and not axi_wready) = '0' then
        axi_wdata   <= (others => '0');
        axi_wstrb   <= (others => '0');
      end if;
      if (S_AXI_RESETN and axi_rvalid) = '0' then
        axi_rdata   <= (others => '0');
      end if;
      if (S_AXI_RESETN and not (axi_awready and axi_arready)) = '0' then
        axi_aaddr   <= (others => '1');
        bram_en     <= '0';
      end if;
    end check;

-- ready """"""\____/""""
-- valid _____/""""""\___

    procedure wgo_idle0 is begin
      axi_awready <= '1';
      axi_wready  <= '1';
      axi_bvalid  <= '0';
    end wgo_idle0;
    procedure wgo_awready1 is begin
      bram_en     <= '1';
      axi_awready <= '0';
      axi_aaddr   <= axi_addr2addr(S_AXI_AWADDR);
    end wgo_awready1;
    procedure wgo_wready2 is begin
      axi_wready  <= '0';
      axi_wstrb   <= S_AXI_WSTRB;
      axi_wdata   <= S_AXI_WDATA;
    end wgo_wready2;
    procedure wgo_bvalid3 is begin
      axi_bvalid <= '1';
    end wgo_bvalid3;

    procedure rgo_idle0 is begin
      axi_arready <= '1';
      axi_rvalid  <= '0';
    end rgo_idle0;
    procedure rgo_arready1 is begin
      bram_en     <= '1';
      axi_arready <= '0';
      axi_aaddr   <= axi_addr2addr(S_AXI_ARADDR);
    end rgo_arready1;
    procedure rgo_rvalid2 is begin
      axi_arready <= '1';
      axi_rvalid  <= '1';
      axi_rdata  <= DATA_IN;
    end rgo_rvalid2;

    begin
      if rising_edge(S_AXI_CLK) then
        check;
        if S_AXI_RESETN = '0' then
          wgo_idle0;
          rgo_idle0;
        -- writing
        elsif axi_awready = '0' then
          if axi_wready = '0' then
            if axi_bvalid = '0' then
              wgo_bvalid3;
            elsif S_AXI_BREADY = '1' then
              wgo_idle0;
            end if;
          elsif S_AXI_WVALID = '1' then
            wgo_wready2;
          end if;
        elsif (S_AXI_AWVALID and axi_arready) = '1'  then
          rgo_idle0;
          wgo_awready1;
        -- reading
        elsif axi_arready = '0' then
          if axi_rvalid = '0' then
            rgo_rvalid2;
          elsif S_AXI_RREADY  = '1' then
            rgo_idle0;              
          end if;        
        elsif (S_AXI_ARVALID and axi_awready) = '1' then
          wgo_idle0;
          rgo_arready1;
        end if;
      end if;
    end process;
end arch_imp;
