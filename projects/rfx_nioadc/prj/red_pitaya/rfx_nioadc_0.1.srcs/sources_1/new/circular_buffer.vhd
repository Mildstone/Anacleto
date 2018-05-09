
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;


entity ring_fifo is
	generic(
		fifo_length	: integer:=8;
		data_width	: integer:=32);

	port(
		clk			: in std_logic;
		rst			: in std_logic;
		ren			: in std_logic;
		wen			: in std_logic;
		dataout		: out std_logic_vector(data_width-1 downto 0);
		datain		: in  std_logic_vector(data_width-1 downto 0);
		empty		: out std_logic;
		err			: out std_logic;
		full		: out std_logic);
	end ring_fifo;

architecture arc of ring_fifo is

	type memory_type is array (0 to fifo_length-1) of std_logic_vector(data_width-1 downto 0);

	signal memory	: memory_type := (others => (others => '0'));
	signal readptr,writeptr	: integer range 0 to fifo_length-1 := 1;
	signal rcycle,wcycle : std_logic := '0';
	signal full0	: std_logic := '0';
	signal empty0	: std_logic := '1';

begin
	full <= full0;
	empty <= empty0;
		
	fifo0: process(clk,rst)
	begin
		if rst='1' then
			readptr <= 0;
			writeptr <= 0;
			rcycle <= '0';
			wcycle <= '0';
			full0 <= '0';
			empty0 <= '1';
			err <= '0';
		elsif rising_edge(clk) then
			if (wen='1' and full0='0') then 
				memory(writeptr) <= datain ;
				if (writeptr=fifo_length-1) then
					wcycle <= not wcycle;
					writeptr <= 0;
				else
					writeptr <= writeptr+1;
				end if;
			end if;

			if (ren='1' and empty0='0') then 
				dataout <= memory(readptr);
				if (readptr=fifo_length-1) then
					rcycle <= not rcycle;
					readptr <= 0;
				else
					readptr <= readptr+1;
				end if;
			end if ;
			
				if ((writeptr + 1 = readptr)) or ((writeptr=fifo_length-1) and (readptr=0)) then
					full0 <= '1';
				else
					full0 <= '0';
				end if;
					
				if (readptr = writeptr) then
					empty0 <= '1';
				else
					empty0 <= '0';
				end if;
				
				if (empty0='1' and ren='1') or (full0='1' and wen='1') then
					err <= '1';
				else
					err <= '0';
				end if;
		end if; 
	end process;
end arc;
