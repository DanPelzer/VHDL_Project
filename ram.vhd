library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
	
use work.all;

entity ram is
  port (clk, ram_sel : in std_logic;
    read_memory, write_memory : in std_logic;
    databus : inout std_logic_vector(31 downto 0);
    addbus : in std_logic_vector(31 downto 0));
end ram;

architecture ramit of ram is
  type ram_arr is array(0 to 15) of std_logic_vector(31 downto 0);
  signal rams: ram_arr := (15=> x"0000FFEE", others => x"FFFFFFFF");
  
  begin
    databus <= rams(CONV_INTEGER(addbus(15 downto 0))) when read_memory='1' and ram_sel='1' else "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
    rams(CONV_INTEGER(addbus(15 downto 0))) <= databus(31 downto 0) when write_memory = '1' and ram_sel='1';
        
       -- end if;
     
  
end ramit;

