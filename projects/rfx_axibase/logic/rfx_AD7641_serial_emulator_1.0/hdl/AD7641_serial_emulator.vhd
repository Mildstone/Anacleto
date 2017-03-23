----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/22/2017 04:40:22 PM
-- Design Name: 
-- Module Name: AD7641_serial_emulator - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity AD7641_serial_emulator is
    Generic (
     SERIAL_DATA_LEN : integer := 18
    );
    Port ( reset    : in STD_LOGIC;
           clk      : in STD_LOGIC;
           clk_ref  : in STD_LOGIC;
           CNVST_in : in STD_LOGIC;
           SCLK_out : out STD_LOGIC;
           SDAT_out : out STD_LOGIC;
           data_in  : in STD_LOGIC_VECTOR (31 downto 0));
end AD7641_serial_emulator;

architecture Behavioral of AD7641_serial_emulator is


signal enable : std_logic := '0';
signal data_buffer : std_logic_vector(31 downto 0) := (others => '0');
signal data_buffer_ready : std_logic := '1';

begin
 
 SCLK_out <= clk_ref and not data_buffer_ready after 20ns;

 main : process (clk, reset, CNVST_in)  
 begin
  if reset = '1' then
   enable <= '0';
  elsif rising_edge(clk) then
   if (CNVST_in = '1') and data_buffer_ready = '1' then
    data_buffer <= data_in;
    enable <= '1';
   elsif enable = '1' and data_buffer_ready = '1' then
    enable <= '0';
   end if;
  end if;
 end process main;

 

 gen_SDAT : process (clk_ref, reset)
  variable pos : integer := 0;
--  variable ena : std_logic := '0';
 begin  
  if reset = '1' then
   SDAT_out <= '0';
   pos := 0;
  elsif rising_edge(clk_ref) and enable = '1' then   
    SDAT_out <= data_buffer(pos);
    pos := (pos+1) mod SERIAL_DATA_LEN;   
    if pos = 0 then     
     data_buffer_ready <= '1';
    else
     data_buffer_ready <= '0';
    end if;      
  end if;
 end process gen_SDAT;

end Behavioral;
