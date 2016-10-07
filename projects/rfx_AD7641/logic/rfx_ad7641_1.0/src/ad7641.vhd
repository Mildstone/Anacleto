----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/03/2016 05:00:30 PM
-- Design Name: 
-- Module Name: ad7641 - Behavioral
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

entity ad7641 is
port (adc_cnvst       : out std_logic;        -- conversion start to adc
      adc_sclk        : in std_logic;         -- clock from adc
      adc_dout        : in std_logic;         -- data from adc
      conversion_start : in std_logic;      -- internal interface 
      data_ready      : out std_logic;        -- transitions on new data
      data            : out std_logic_vector(17 downto 0));
end entity ad7641;

architecture behavioural of ad7641 is

signal shift_in : std_logic_vector(17 downto 0);
signal ready : std_logic;

begin


-- Daten seriell ?bernehmen, wenn sync aktiv.
process (adc_sclk) is
begin
    if rising_edge(adc_sclk) then
        if adc_sync = '1' then
            shift_in <= shift_in(16 downto 0) & adc_dout;
        end if;
    end if;
    data <= shift_in;
    adc_cnvst <= True;
    data_ready <= ready;
    conversion_start <= False; 
end process;

process( adc_start ) is
begin
    if rising_edge(conversion_start) then
        data_ready <= not ready;
        adc_cnvst <=  False;
     end if;
end process;


---- Nach dem Transfer wird Sync low gezogen, dann reichen wir die Daten
---- weiter.
--process (adc_sync) is
--begin
--    if falling_edge(adc_sync) then
--        data <= shift_in;
--        ready <= not ready;
--    end if;
--end process;

end architecture;
