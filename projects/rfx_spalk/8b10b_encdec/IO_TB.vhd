library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all; --  Imports the standard textio package.

entity IO_TB is
generic ( IO_TB_WIDTH : integer := 32 );
end IO_TB;

architecture behavioral of IO_TB is

 -- signals --
 constant half_period : integer := 20; -- ns
 signal TB_rsn : std_logic := '0';
 signal TB_clk : std_logic := '0'; -- make sure you initialise!
 signal test_data   : std_logic_vector(IO_TB_WIDTH-1 downto 0) := (others => '0');
 signal test_tvalid : std_logic := '0';
 signal test_out_data      : std_logic_vector(IO_TB_WIDTH-1 downto 0);
 signal test_out_tvalid    : std_logic;
 signal sdat : std_logic;

 component io_8b10b
 generic (
   C_AXIS_TDATA_WIDTH : integer
 );
 port (
   rstn           : in  std_logic;
   clk            : in  std_logic;
   lclk           : in  std_logic;
   S0_AXIS_TREADY : out std_logic;
   S0_AXIS_TDATA  : in  std_logic_vector(C_AXIS_TDATA_WIDTH-1 downto 0);
   S0_AXIS_TVALID : in  std_logic;
   M0_AXIS_TVALID : out std_logic;
   M0_AXIS_TDATA  : out std_logic_vector(C_AXIS_TDATA_WIDTH-1 downto 0);
   M0_AXIS_TREADY : in  std_logic;
   s_out          : out std_logic;
   s_in           : in  std_logic
 );
 end component io_8b10b;


begin

 TB_rsn <= '1' after 100 ns;
 TB_clk <= not TB_clk after 20 ns;

 -- PROCESS: generate_test_data
 generate_test_data: process
 begin
  test_tvalid <= '1';
  wait for 10 us;
  test_data <= std_logic_vector(unsigned(test_data) + 1);
  report "test_data: " & integer'image(to_integer(unsigned(test_data)));
 end process generate_test_data;

-- test_tvalid <= '1';

-- -- PROCESS: tdat
-- tdat: process (TB_rsn,TB_clk)
-- begin
-- if TB_rsn = '0' then
-- report "TB_RESET";
-- elsif rising_edge(TB_clk) then
-- report "[tb_clk] test_data = " &
--  integer'image(to_integer(unsigned(test_data)));
-- end if;
-- end process tdat;





 io_8b10b_i : io_8b10b
 generic map (
   C_AXIS_TDATA_WIDTH => IO_TB_WIDTH
 )
 port map (
   rstn           => TB_rsn,
   clk            => TB_clk,
   lclk            => TB_clk,
   --   S0_AXIS_TREADY =>
   S0_AXIS_TDATA  => test_data,
   S0_AXIS_TVALID => test_tvalid,
   M0_AXIS_TDATA  => test_out_data,
   M0_AXIS_TVALID => test_out_tvalid,
   M0_AXIS_TREADY => '1',
   s_out          => sdat,
   s_in           => sdat
 );



end behavioral;
