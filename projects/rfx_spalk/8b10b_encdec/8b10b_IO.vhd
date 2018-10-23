library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity io_8b10b is
    generic(
      C_AXIS_TDATA_WIDTH	: integer	:= 32
    );
    port(
		rstn : in std_logic ;	-- Global asynchronous reset (AH)
		clk   : in std_logic ;	-- Master synchronous receive byte clock
    lclk  : in std_logic ;	-- Master synchronous receive byte clock
		S0_AXIS_TREADY  : out std_logic;
		S0_AXIS_TDATA   : in std_logic_vector(C_AXIS_TDATA_WIDTH-1 downto 0);
		S0_AXIS_TVALID  : in std_logic;
		M0_AXIS_TVALID  : out std_logic;
		M0_AXIS_TDATA   : out std_logic_vector(C_AXIS_TDATA_WIDTH-1 downto 0);
		M0_AXIS_TREADY  : in  std_logic;
		s_out : out std_logic;
		s_in : in std_logic
	 );
end io_8b10b;

architecture behavioral of io_8b10b is



  -- function called clogb2 that returns an integer which has the
  -- value of the ceiling of the log base 2.
	function clogb2 (bit_depth : integer) return integer is
	variable depth  : integer := bit_depth;
	  begin
	    if (depth = 0) then
	      return(0);
	    else
	      for clogb2 in 1 to bit_depth loop  -- Works for up to 32 bit integers
	        if(depth <= 1) then
	          return(clogb2);
	        else
	          depth := depth / 2;
	        end if;
	      end loop;
	    end if;
	end;
  -- number of words in input data
  constant WORD_NUM : integer := C_AXIS_TDATA_WIDTH/8;
  -- number of bits needed to represent word pos pointer
	constant WORD_LEN : integer := clogb2(word_num-1);

  signal rst : std_logic;
  signal qclk : std_logic;
  signal send_en : std_logic := '0';
  signal encd_en : std_logic := '0';
  signal encd_in, decd_out  : std_logic_vector(7 downto 0);
  signal encd_out, decd_in  : std_logic_vector(9 downto 0);
  signal encd_out_buffer : std_logic_vector(9 downto 0);
  signal K_in, K_out : std_logic := '0';

  signal K285 : std_logic := '0';

  type state is ( ST_IDLE, ST_K285, ST_DATA, ST_PAYLOAD, ST_UPDATE, ST_STORE);
  signal stm_read, stm_write : state := ST_IDLE;
  signal stm_data : state := ST_IDLE;

  signal encd_end : std_logic := '0';

  -- Special character code values
  constant K28d0 : std_logic_vector := "00011100"; -- Balanced
  constant K28d1 : std_logic_vector := "00111100"; -- Unbalanced comma
  constant K28d2 : std_logic_vector := "01011100"; -- Unbalanced
  constant K28d3 : std_logic_vector := "01111100"; -- Unbalanced
  constant K28d4 : std_logic_vector := "10011100"; -- Balanced
  constant K28d5 : std_logic_vector := "10111100"; -- Unbalanced comma
  constant K28d6 : std_logic_vector := "11011100"; -- Unbalanced
  constant K28d7 : std_logic_vector := "11111100"; -- Balanced comma
  constant K23d7 : std_logic_vector := "11110111"; -- Balanced
  constant K27d7 : std_logic_vector := "11111011"; -- Balanced
  constant K29d7 : std_logic_vector := "11111101"; -- Balanced
  constant K30d7 : std_logic_vector := "11111110"; -- Balanced

  subtype T_octet        is std_logic_vector(7 downto 0);
  subtype T_message_data is std_logic_vector( T_octet'length*2+C_AXIS_TDATA_WIDTH-1 downto 0);
  constant null_payload  : std_logic_vector( C_AXIS_TDATA_WIDTH-1 downto 0) := (others => '0');
  constant msg_data_null : T_message_data := K28d5 & "00000000" & null_payload;
  signal msg_data : T_message_data := msg_data_null;
  signal msg_data_dec : T_message_data := msg_data_null;

  -- By PK debug mean for printing std_logic
  function std_logic_vector_to_sting( v : std_logic_vector ) return string is
  variable s : string( 3 downto 1 );
  variable r : string( (v'left+1) downto (v'right+1) );
  begin
    for i in v'left downto v'right loop
      s := std_logic'image(v(i));
      r(i+1) := s(2);
    end loop;
    return r;
  end std_logic_vector_to_sting;

  function std_logic_to_sting( v : std_logic ) return string is
  variable s : string( 3 downto 1 );
  variable r : string( 1 downto 1 );
  begin
      s := std_logic'image(v);
      r(1) := s(2);
    return r;
  end std_logic_to_sting;


component enc_8b10b
port(
	RESET : in std_logic ;		-- Global asynchronous reset (active high)
	SBYTECLK : in std_logic ;	-- Master synchronous send byte clock
	KI : in std_logic ;			-- Control (K) input(active high)
	AI, BI, CI, DI, EI, FI, GI, HI : in std_logic ;	-- Unencoded input data
	JO, HO, GO, FO, IO, EO, DO, CO, BO, AO : out std_logic 	-- Encoded out
	);
end component;

component dec_8b10b
    port(
		RESET : in std_logic ;	-- Global asynchronous reset (AH)
		RBYTECLK : in std_logic ;	-- Master synchronous receive byte clock
		AI, BI, CI, DI, EI, II : in std_logic ;
		FI, GI, HI, JI : in std_logic ; -- Encoded input (LS..MS)
		KO : out std_logic ;	-- Control (K) character indicator (AH)
		HO, GO, FO, EO, DO, CO, BO, AO : out std_logic 	-- Decoded out (MS..LS)
	    );
end component;


-- RETURN OCTETS FROM T_message_data
type    T_message_data_octets is array (0 to WORD_NUM+2) of T_octet;
function octets (msg : T_message_data) return T_message_data_octets is
  variable octets : T_message_data_octets;
  constant wlen : integer := WORD_NUM + 2;
begin
  for i in 0 to wlen-1 loop
    octets(i) := msg( (wlen-i)*8-1 downto (wlen-i-1)*8 );
  end loop;
  return octets;
end;


-------------------------------------------------------------------------------
begin

rst <= not rstn;


axis_read_data : process(clk, rstn)
  variable octs : T_message_data_octets := octets(msg_data_null);
  variable pos : integer := 0;
  variable next_state : state := ST_IDLE;
begin
  if rstn = '0' then
    msg_data <= msg_data_null;
    send_en <= '0';
  elsif rising_edge(clk) then
    if S0_AXIS_TVALID = '1' then
      msg_data(C_AXIS_TDATA_WIDTH-1 downto 0) <= S0_AXIS_TDATA;
      octs := octets(msg_data);
      -- report "msg_data: " & std_logic_vector_to_sting(octs(0)) & " "
      --                     & std_logic_vector_to_sting(octs(1)) & " "
      --                     & std_logic_vector_to_sting(octs(2)) & " "
      --                     & std_logic_vector_to_sting(octs(3)) & " "
      --                     & std_logic_vector_to_sting(octs(4)) & " "
      --                     & std_logic_vector_to_sting(octs(5)) & " "
      --                     ;
    end if;
    -- VERY SIMPLE READ STATE MACHINE --
    next_state := stm_data;
    K_in <= '0';
    case( stm_data ) is
      when ST_IDLE =>
        send_en <= '1';
        pos := (WORD_NUM + 1);
        encd_in <= octs(0);
        next_state := ST_DATA;
      when ST_DATA =>
        if pos = 0 then
          K_in <= '1';
        end if;
        send_en <= '1';
        encd_in <= octs(pos);
        next_state := ST_DATA;
      when others =>
        next_state := ST_IDLE;
    end case;
    -- update state at word end
    if encd_end = '1' then
      pos := (pos + 1) rem (WORD_NUM + 2);
      stm_data <= next_state;
    end if;
  end if;
end process;


-- PROCESS: process_serial_out
process_serial_out: process (rstn,clk)
 variable pos : integer := 0;
 variable stm : state := ST_IDLE;
begin
 if rstn = '0' or send_en = '0' then
  stm   := ST_IDLE;
  s_out <= '0';
  pos   := 0;
 elsif rising_edge(clk) then
  if    pos = 8 then stm := ST_UPDATE;
  elsif pos = 9 then stm := ST_STORE;
  else               stm := ST_IDLE;
  end if;
  encd_en  <= '0';
  encd_end <= '0';
  case( stm ) is
    when ST_IDLE =>
    when ST_UPDATE =>
     encd_en <= '1';
    when ST_STORE =>
     encd_end <= '1';
     encd_out_buffer <= encd_out;
    when others =>
  end case;
  s_out <= encd_out_buffer(9 - pos);
  -- report "" & std_logic_to_sting(encd_out(pos));
  -- report "enc_i: " & std_logic_vector_to_sting(encd_in) & " "
  --      & "enc_o: " & std_logic_vector_to_sting(encd_out_buffer);
  pos := (pos + 1) rem 10;
 end if;



end process process_serial_out;






-- PROCESS: axis_write_data
axis_write_data: process (rstn,lclk)
  variable pos : integer := 0;
begin
 if rstn = '0' then
  -- init --
 elsif rising_edge(lclk) then
    if K_out = '1' and decd_out = K28d5 then
      pos := 0;
    else
      pos := pos + 1;
    end if;
    if pos = 10 then report "cmd code after k285: " & std_logic_vector_to_sting(decd_out); end if;
   -- report "msg_data: " & std_logic_vector_to_sting(decd_out);
 end if;
end process axis_write_data;


-- PROCESS: process_serial_in
process_serial_in: process (rstn,lclk)
 variable pos : integer := 0;
begin
 if rstn = '0' then
  decd_in <= (others => '0');
elsif falling_edge(lclk) then
  -- shift >> decd_in
  decd_in <= decd_in(8 downto 0) & s_in;
 end if;
end process process_serial_in;

-- PROCESS: find_K28_5
find_K28_5: process (rstn,lclk)
begin
 if rstn = '0' then
  k285 <= '0';
elsif rising_edge(lclk) then
  --if K_out = '1' and decd_out = "10111100" then
  if K_out = '1' and decd_out = K28d5 then
   k285 <= '1';
   report "K285";
  else
   k285 <= '0';
  end if;
 end if;
end process find_K28_5;

qclk_process : process(clk, rstn)
  variable pos : integer := 0;
begin
  if rstn = '0' then
    qclk <= '1';
    pos := 0;
  elsif falling_edge(clk) then
    if pos = 5 then
      qclk <= not qclk;
      pos := 0;
    end if;
    pos := pos+1;
  end if;
end process;

enc : enc_8b10b
port map (
       RESET => rst,
       SBYTECLK => qclk,
       KI => K_in,

       AI => encd_in(0),
       BI => encd_in(1),
       CI => encd_in(2),
       DI => encd_in(3),
       EI => encd_in(4),
       FI => encd_in(5),
       GI => encd_in(6),
       HI => encd_in(7),

     AO => encd_out(0),
	   BO => encd_out(1),
	   CO => encd_out(2),
	   DO => encd_out(3),
	   EO => encd_out(4),
	   IO => encd_out(5),
	   FO => encd_out(6),
	   GO => encd_out(7),
	   HO => encd_out(8),
	   JO => encd_out(9)
    );

dec : dec_8b10b
port map (
       RESET => rst,
	   RBYTECLK => clk,
	   KO => K_out,

       AI => decd_in(0),
       BI => decd_in(1),
       CI => decd_in(2),
       DI => decd_in(3),
       EI => decd_in(4),
       II => decd_in(5),
       FI => decd_in(6),
       GI => decd_in(7),
       HI => decd_in(8),
       JI => decd_in(9),

       AO => decd_out(0),
       BO => decd_out(1),
       CO => decd_out(2),
       DO => decd_out(3),
       EO => decd_out(4),
       FO => decd_out(5),
       GO => decd_out(6),
       HO => decd_out(7)
);

end behavioral;