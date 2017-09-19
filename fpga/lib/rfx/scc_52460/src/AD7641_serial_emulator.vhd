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

signal sclk_gen          : std_logic := '0';
signal enable            : std_logic := '0';
signal data_buffer       : std_logic_vector(31 downto 0) := (others => '0');
signal data_buffer_ready : std_logic := '1';

begin
 
 SCLK_out <= SCLK_gen and not data_buffer_ready;
 SDAT_out <= data_buffer(SERIAL_DATA_LEN) and not data_buffer_ready;

 main : process (clk, reset, CNVST_in)  
 begin
  if reset = '1' then
   enable <= '0';
  elsif rising_edge(clk) then
   if (CNVST_in = '1') then    
    enable <= '1';
   elsif enable = '1' and data_buffer_ready = '1' then
    enable <= '0';
   end if;
  end if;
 end process main;

 gen_SCLK : process (clk_ref, enable)
 begin 
  if enable = '0' then
   SCLK_gen <= '0';
  elsif rising_edge(clk_ref) then
   SCLK_gen <= not SCLK_gen;
  end if;
 end process; 

 gen_SDAT : process (clk_ref, enable)
  variable count : integer := 0;
  -- variable data  : std_logic := '0';
 begin   
  if enable = '0' then
   data_buffer <= data_in;
   count := 0;
  elsif rising_edge(clk_ref) then    
    if count < SERIAL_DATA_LEN then
     count := count+1;     
     data_buffer <= data_buffer(30 downto 0) & '0';
     data_buffer_ready <= '0';
    else 
     count := 0;     
     data_buffer_ready <= '1';
    end if;      
  end if;
 end process gen_SDAT;

end Behavioral;
