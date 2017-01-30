library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity w7x_timing_v1_0_S00_AXI is
	generic (
      READ_COUNT : integer := 1;
      HEAD_COUNT : integer := 5;
      DATA_COUNT : integer := 16;
		-- S_AXI data bus parameters
      DATA_WIDTH : integer := 64;
      ADDR_WIDTH : integer := 8
	);
	port (
     USR_CLK    : in  STD_LOGIC;
     DATA_INDEX : in  STD_LOGIC_VECTOR(31 downto 0);
     DATA_IN    : in  STD_LOGIC_VECTOR(READ_COUNT*DATA_WIDTH-1 downto 0);
     HEAD_OUT   : out STD_LOGIC_VECTOR(HEAD_COUNT*DATA_WIDTH-1 downto 0);		
     DATA_OUT   : out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
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
    constant READ_MIN  : integer := 0;
    constant READ_MAX  : integer := READ_MIN+READ_COUNT;
    constant HEAD_MIN  : integer := READ_MAX;
    constant HEAD_MAX  : integer := HEAD_MIN+HEAD_COUNT;
    constant DATA_MIN  : integer := HEAD_MAX;
    constant DATA_MAX  : integer := DATA_MIN+DATA_COUNT;
    
    constant READ_BASE : integer := READ_MIN*DATA_WIDTH;
    constant READ_HEAD : integer := READ_MAX*DATA_WIDTH-1;
    constant HEAD_BASE : integer := HEAD_MIN*DATA_WIDTH;
    constant HEAD_HEAD : integer := HEAD_MAX*DATA_WIDTH-1;
    constant DATA_BASE : integer := DATA_MIN*DATA_WIDTH;
    constant DATA_HEAD : integer := DATA_MAX*DATA_WIDTH-1;
    
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
    
	signal slv_buf      : std_logic_vector(DATA_HEAD downto 0) := (others => '0');
    signal slv_buf_rden : std_logic;
    signal slv_buf_wren : std_logic;
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
    
    function and_v(vec : std_logic_vector) return boolean is
      variable ans : std_logic := '1';
    begin
      for i in vec'range loop
        ans := ans and vec(i);
      end loop;
      return ans = '1';
    end and_v;

	type index_array    is array(1 to 2) of std_logic_vector(31 downto 0);
	type data_in_array  is array(0 to 2) of std_logic_vector(READ_COUNT*DATA_WIDTH-1 downto 0);
	type head_out_array is array(0 to 1) of std_logic_vector(HEAD_COUNT*DATA_WIDTH-1 downto 0); 
	type data_out_array is array(0 to 2) of std_logic_vector(DATA_WIDTH-1 downto 0); 
	signal index_buf    : index_array    := (others => (others => '0'));
	signal data_in_buf  : data_in_array  := (others => (others => '0'));
	signal head_out_buf : head_out_array := (others => (others => '0'));
	signal data_out_buf : data_out_array := (others => (others => '0'));

begin

----user   
    update_in: process(S_AXI_ACLK)
    variable idx, address  : integer;
    begin
      if (rising_edge(S_AXI_ACLK)) then
        -- buffer index
        index_buf(1) <= index_buf(2);
        -- feed data_out_buf with right index value
        idx := to_integer(unsigned(index_buf(1))) + DATA_MIN;
        if idx < DATA_MAX then
          address := idx2base(idx);
        else
          address := idx2base(0);
        end if;
        data_out_buf(2) <= slv_buf(address+DATA_WIDTH-1 downto address);
        -- buffer data_in
        data_in_buf(1)  <= data_in_buf(2);
        data_in_buf(0)  <= data_in_buf(1);
      end if;  
    end process update_in;

    -- two stage buf out
    update_out1: process(USR_CLK)
    begin
      if falling_edge(USR_CLK) then
         head_out_buf(1) <= slv_buf(HEAD_HEAD downto HEAD_BASE);
         data_out_buf(1) <= data_out_buf(2);
      end if;  
    end process update_out1;
    update_out2: process(USR_CLK,DATA_INDEX,DATA_IN)
    variable address  : integer;
    begin
      if rising_edge(USR_CLK) then
        index_buf(2) <= DATA_INDEX;
        data_in_buf(2)  <= DATA_IN;
        head_out_buf(0) <= head_out_buf(1);
        data_out_buf(0) <= data_out_buf(1);
      end if;  
    end process update_out2;
    HEAD_OUT <= head_out_buf(0);
    DATA_OUT <= data_out_buf(0);
    
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

	process (slv_buf, axi_araddr)
	variable idx : integer; 
    begin
      idx := axi_addr2idx(axi_araddr);
      if idx < DATA_MAX then
        rdata_buf <= slv_buf(idx2base(idx)+DATA_WIDTH-1 downto idx2base(idx));
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
	      axi_awaddr <= (others => '0');
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

	slv_buf_wren <= axi_wready and S_AXI_WVALID and axi_awready and S_AXI_AWVALID ;

	process (S_AXI_ACLK,S_AXI_ARESETN, axi_awaddr, slv_buf_wren, S_AXI_WSTRB, S_AXI_WDATA, data_in_buf(0))
	variable idx : integer; 
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
	      slv_buf <= (others => '0');
	    else
	      if (slv_buf_wren = '0') then
            slv_buf(READ_HEAD downto READ_BASE) <= data_in_buf(0);
          else
            idx := axi_addr2idx(axi_awaddr);
	        if (idx>=READ_MAX) and (idx<DATA_MAX) then
              for i in 0 to (DATA_WIDTH/8-1) loop
                if ( S_AXI_WSTRB(i) = '1' ) then
                  slv_buf(idx2base(idx)+i*8+7 downto idx2base(idx)+i*8) <= S_AXI_WDATA(i*8+7 downto i*8);
                end if;
              end loop;             
            end if;
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

	slv_buf_rden <= axi_arready and S_AXI_ARVALID and (not axi_rvalid) ;

	process( S_AXI_ACLK, S_AXI_ARESETN, slv_buf_rden, rdata_buf) is
	begin
	  if (rising_edge (S_AXI_ACLK)) then
	    if ( S_AXI_ARESETN = '0' ) then
	      axi_rdata  <= (others => '0');
	    elsif (slv_buf_rden = '1') then
	      axi_rdata <= rdata_buf;
	    end if;
	  end if;
	end process;
end arch_imp;
