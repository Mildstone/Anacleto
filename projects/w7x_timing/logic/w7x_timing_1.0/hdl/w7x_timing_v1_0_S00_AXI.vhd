library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity w7x_timing_v1_0_S00_AXI is
	generic (
      DATA_COUNT : integer := 16;
		-- S_AXI data bus parameters
      DATA_WIDTH : integer := 64;
      ADDR_WIDTH : integer := 8
	);
	port (
     DATA_BUF      : inout STD_LOGIC_VECTOR(DATA_COUNT*DATA_WIDTH-1 downto 0);
     IDX_OUT       : out   INTEGER;
     STRB_OUT      : out   STD_LOGIC_VECTOR((DATA_WIDTH/8)-1 downto 0);
     DATA_OUT      : out   STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
     RST_OUT       : out   STD_LOGIC;
      
     -- AXI ports
     S_AXI_ACLK    : in  std_logic;
     S_AXI_ARESETN : in  std_logic;
     S_AXI_AWADDR  : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
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
     S_AXI_ARADDR  : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
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
    
    -- AXI4LITE signals
    signal axi_awaddr  : std_logic_vector(ADDR_WIDTH-1 downto 0);
    --signal axi_awprot  : std_logic_vector(2 downto 0);
    signal axi_awready : std_logic;
    signal axi_wready  : std_logic;
    signal axi_bresp   : std_logic_vector(1 downto 0);
    signal axi_bvalid  : std_logic;
    signal axi_araddr  : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal axi_arready : std_logic;
    signal axi_rdata   : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal axi_rresp   : std_logic_vector(1 downto 0);
    signal axi_rvalid  : std_logic;
    
    signal buf_read_ready  : std_logic;
    signal buf_write_ready : std_logic;
    signal rdata_buf    : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');

    function axi_addr2idx(addr : std_logic_vector(DATA_WIDTH-1 downto 0)) return integer is
	-- local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
	-- ADDR_LSB is used for addressing 32/64 bit registers/memories
	-- ADDR_LSB = 2 for 32 bits (n downto 2)
	-- ADDR_LSB = 3 for 64 bits (n downto 3)
	constant ADDR_LSB  : integer := (DATA_WIDTH/32)+ 1;
	constant OPT_MEM_ADDR_BITS : integer := ADDR_WIDTH-ADDR_LSB;
    begin
      return to_integer(unsigned(addr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB)));
    end axi_addr2idx;

    function idx2base(idx : integer) return integer is
    begin
      return idx*DATA_WIDTH;
    end idx2base;
    
begin
    DATA_OUT <= S_AXI_WDATA;
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
	variable idx : integer; 
    begin
      idx := axi_addr2idx(axi_araddr);
      if idx < DATA_COUNT then
        rdata_buf <= DATA_BUF(idx2base(idx)+DATA_WIDTH-1 downto idx2base(idx));
	  else
	    rdata_buf <= (others => '0');
	  end if;
	end process; 

	process (S_AXI_ACLK,S_AXI_ARESETN,S_AXI_AWVALID,S_AXI_WVALID)
	begin
	  if rising_edge(S_AXI_ACLK) then
	    axi_awready <= '0';
	    if (S_AXI_ARESETN = '1' and axi_awready = '0' and S_AXI_AWVALID = '1' and S_AXI_WVALID = '1') then
          axi_awready <= '1';
	    end if;
	  end if;
	end process;

	process (S_AXI_ACLK,S_AXI_ARESETN,S_AXI_AWVALID,S_AXI_WVALID,S_AXI_AWADDR)
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
	      axi_awaddr <= (others => '1');
	    else
	      if (axi_awready = '0' and S_AXI_AWVALID = '1' and S_AXI_WVALID = '1') then
	        axi_awaddr <= S_AXI_AWADDR;
	      end if;
	    end if;
	  end if;
	end process;

	process (S_AXI_ACLK,S_AXI_ARESETN,S_AXI_AWVALID,S_AXI_WVALID)
	begin
	  if rising_edge(S_AXI_ACLK) then
	    axi_wready <= '0';
	    if (S_AXI_ARESETN = '1' and axi_wready = '0' and S_AXI_WVALID = '1' and S_AXI_AWVALID = '1') then
	      axi_wready <= '1';
	    end if;
	  end if;
	end process;

	buf_write_ready <= axi_wready and S_AXI_WVALID and axi_awready and S_AXI_AWVALID ;
	process (S_AXI_ACLK,S_AXI_ARESETN, axi_awaddr, buf_write_ready, S_AXI_WSTRB, S_AXI_WDATA)
	variable idx : integer;
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
	      RST_OUT <= '1';
	    else
	      RST_OUT <= '0';
	      if (buf_write_ready = '1') then
            IDX_OUT  <= axi_addr2idx(axi_awaddr);
            STRB_OUT <= S_AXI_WSTRB;
          else
            IDX_OUT  <= -1;
            STRB_OUT <= (others => '0');
          end if;
	    end if;
	  end if;
	end process;

	process (S_AXI_ACLK, S_AXI_ARESETN, axi_awready, S_AXI_AWVALID, axi_wready, S_AXI_WVALID, axi_bvalid, S_AXI_BREADY)
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
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

	process (S_AXI_ACLK,S_AXI_ARESETN,axi_arready,S_AXI_ARVALID,S_AXI_ARADDR)
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
	      axi_arready <= '0';
	      axi_araddr  <= (others => '1');
	    else
	      if (axi_arready = '0' and S_AXI_ARVALID = '1') then
	        axi_arready <= '1';
	        axi_araddr  <= S_AXI_ARADDR;
	      else
	        axi_arready <= '0';
	      end if;
	    end if;
	  end if;
	end process;

	process (S_AXI_ACLK,S_AXI_ARESETN,axi_arready,S_AXI_ARVALID,axi_rvalid,S_AXI_RREADY)
	begin
	  if rising_edge(S_AXI_ACLK) then
	    if S_AXI_ARESETN = '0' then
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
	process( S_AXI_ACLK, S_AXI_ARESETN, buf_read_ready, rdata_buf) is
	begin
	  if (rising_edge (S_AXI_ACLK)) then
	    if ( S_AXI_ARESETN = '0' ) then
	      axi_rdata  <= (others => '0');
	    elsif (buf_read_ready = '1') then
	      axi_rdata <= rdata_buf;
	    end if;
	  end if;
	end process;
end arch_imp;
