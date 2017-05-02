
library IEEE;
use IEEE.numeric_std.all;


entity prova is
 port (
  a : in integer;
  b : out integer
  );
end prova;

architecture Behavioral of prova is
begin
 b <= - a;
 
end Behavioral;
