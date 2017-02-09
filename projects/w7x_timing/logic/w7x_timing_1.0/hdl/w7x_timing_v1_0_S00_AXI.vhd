library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity w7x_timing_v1_0_S00_AXI is
	generic (
      DATA_COUNT : integer := 16;
		-- S_AXI data bus parameters
      DATA_WIDTH : integer := 64;
      ADDR_WIDTH : integer := 15;
      AXI_ADDR_WIDTH : integer := 18
	);
	port (
     DATA_BUF      : inout STD_LOGIC_VECTOR(DATA_COUNT*DATA_WIDTH-1 downto 0);
     ADDR_OUT      : out   UNSIGNED(ADDR_WIDTH-1 downto 0);
     STRB_OUT      : out   STD_LOGIC_VECTOR((DATA_WIDTH/8)-1 downto 0);
     DATA_OUT      : out   STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
     RST_OUT       : out   STD_LOGIC;
      
     -- AXI ports
     S_AXI_CLK    : in  std_logic;
     S_AXI_RESETN : in  std_logic;
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
    signal axi_awaddr  : unsigned(ADDR_WIDTH-1 downto 0);
    --signal axi_awprot  : std_logic_vector(2 downto 0);
    signal axi_awready : std_logic;
    signal axi_wready  : std_logic;
    signal axi_wdata   : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal axi_wstrb   : std_logic_vector(DATA_WIDTH/8-1 downto 0);
    signal axi_bresp   : std_logic_vector(1 downto 0);
    signal axi_bvalid  : std_logic;
    signal axi_araddr  : unsigned(ADDR_WIDTH-1 downto 0);
    signal axi_arready : std_logic;
    signal axi_rdata   : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal axi_rresp   : std_logic_vector(1 downto 0);
    signal axi_rvalid  : std_logic;
    
    signal buf_read_ready  : std_logic;
    signal buf_write_ready : std_logic;
    signal rdata_buf    : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');

    function axi_addr2addr(addr : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0)) return unsigned(ADDR_WIDTH-1 downto 0) is
	-- local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
	-- ADDR_LSB is used for addressing 32/64 bit registers/memories
	-- ADDR_LSB = 2 for 32 bits (n downto 2)
	-- ADDR_LSB = 3 for 64 bits (n downto 3)
	--constant ADDR_LSB  : integer := (DATA_WIDTH/32)+ 1;
	--constant OPT_MEM_ADDR_BITS : integer := ADDR_WIDTH-ADDR_LSB;
    begin
      return unsigned(addr(AXI_ADDR_WIDTH-1 downto AXI_ADDR_WIDTH-ADDR_WIDTH));
    end axi_addr2addr;

    function addr2base(addr : unsigned) return integer is
    begin
      return to_integer(addr)*DATA_WIDTH;
    end addr2base;
    
begin
    DATA_OUT <= axi_wdata;
    ADDR_OUT <= unsigned(axi_awaddr);
    STRB_OUT <= axi_wstrb;
    RST_OUT  <= not S_AXI_RESETN;

---- AXI interface
    -- I/O Connections assignments
    S_AXI_AWREADY <= axi_awready;
    S_AXI_WREADY  <= axi_wready;
    S_AXI_BRESP   <= axi_bresp;
    S_AXI_BVALID  <= axi_bvalid;
    S_AXI_ARREADY <= axi_arready;
    S_AXI_RDATA   <= axi_rdata;
    S_AXI_RRESP   <= axi_rresp;
    S_AXI_RVALID  <= axi_rvalid;

	process (DATA_BUF, axi_araddr)
    begin
      if axi_araddr < DATA_LIMIT then
        rdata_buf <= DATA_BUF(addr2base(axi_araddr)+DATA_WIDTH-1 downto addr2base(axi_araddr));
	  else
	    rdata_buf <= (others => '0');
	  end if;
	end process; 

	process (S_AXI_CLK,S_AXI_RESETN,S_AXI_AWVALID,S_AXI_WVALID,S_AXI_AWADDR)
	begin
	  if rising_edge(S_AXI_CLK) then
	    axi_awready <= '0';
	    if S_AXI_RESETN = '0' then
	      axi_awaddr <= (others => '1');
	    elsif (S_AXI_AWVALID and S_AXI_WVALID and not axi_awready) = '1'  then
          axi_awready <= '1';
	      axi_awaddr <= axi_addr2addr(S_AXI_AWADDR);
	    end if;
	  end if;
	end process;

	process (S_AXI_CLK,S_AXI_RESETN,S_AXI_AWVALID,S_AXI_WVALID,S_AXI_WSTRB,S_AXI_WDATA)
	begin
	  if rising_edge(S_AXI_CLK) then
	    axi_wready <= '0';
	    if S_AXI_RESETN = '0' then
	      axi_wstrb <= (others => '0');
	    elsif (S_AXI_AWVALID and S_AXI_WVALID and not axi_wready) = '1'  then
	      axi_wready <= '1';
          axi_wstrb <= S_AXI_WSTRB;
          axi_wdata <= S_AXI_WDATA;
	    end if;
	  end if;
	end process;


	process (S_AXI_CLK, S_AXI_RESETN, axi_awready, S_AXI_AWVALID, axi_wready, S_AXI_WVALID, axi_bvalid, S_AXI_BREADY)
	begin
	  if rising_edge(S_AXI_CLK) then 
	    if S_AXI_RESETN = '0' then
	      axi_bvalid  <= '0';
	      axi_bresp   <= "00";
	    else
	      if (axi_awready = '1' and S_AXI_AWVALID = '1' and axi_wready = '1' and S_AXI_WVALID = '1' and axi_bvalid = '0'  ) then
	        axi_bvalid <= '1';
	        axi_bresp  <= "00";
	      elsif (S_AXI_BREADY = '1' and axi_bvalid = '1') then
	        axi_bvalid <= '0';
	      end if;
	    end if;
	  end if;
	end process;

	process (S_AXI_CLK,S_AXI_RESETN,axi_arready,S_AXI_ARVALID,S_AXI_ARADDR)
	begin
	  if rising_edge(S_AXI_CLK) then 
	    if S_AXI_RESETN = '0' then
	      axi_arready <= '0';
	      axi_araddr  <= (others => '1');
	    else
	      if (axi_arready = '0' and S_AXI_ARVALID = '1') then
	        axi_arready <= '1';
	        axi_araddr  <= axi_addr2addr(S_AXI_ARADDR);
	      else
	        axi_arready <= '0';
	      end if;
	    end if;
	  end if;
	end process;

	process (S_AXI_CLK,S_AXI_RESETN,axi_arready,S_AXI_ARVALID,axi_rvalid,S_AXI_RREADY)
	begin
	  if rising_edge(S_AXI_CLK) then
	    if S_AXI_RESETN = '0' then
	      axi_rvalid <= '0';
	      axi_rresp  <= "00";
	    else
	      if (axi_arready = '1' and S_AXI_ARVALID = '1' and axi_rvalid = '0') then
	        axi_rvalid <= '1';
	        axi_rresp  <= "00";
	      elsif (axi_rvalid = '1' and S_AXI_RREADY = '1') then
	        axi_rvalid <= '0';
	      end if;
	    end if;
	  end if;
	end process;

	buf_read_ready <= axi_arready and S_AXI_ARVALID and (not axi_rvalid) ;
	process( S_AXI_CLK, S_AXI_RESETN, buf_read_ready, rdata_buf) is
	begin
	  if (rising_edge (S_AXI_CLK)) then
	    if ( S_AXI_RESETN = '0' ) then
	      axi_rdata  <= (others => '0');
	    elsif (buf_read_ready = '1') then
	      axi_rdata <= rdata_buf;
	    end if;
	  end if;
	end process;
end arch_imp;
