library ieee;
use ieee.std_logic_1164.all;                           
use ieee.std_logic_unsigned.all;

entity io_module is
   port (
      ia : in std_logic;
      pri : in std_logic_vector(1 downto 0);
      io : out std_logic;
      dev_addr : in std_logic_vector(31 downto 0);
      addbus : inout std_logic_vector(31 downto 0)
      );
end io_module;

architecture behav of io_module is
begin
   addbus <= dev_addr when ia='1' else "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
   io <= '1' when pri>0 else '0';
end behav;