library ieee;
use ieee.std_logic_1164.all;                           
use ieee.std_logic_unsigned.all;

entity register_module is
   port (clk : in std_logic;
         r_w, tri : in std_logic;
         databus : inout std_logic_vector(31 downto 0);
         rbus : in std_logic_vector(3 downto 0);
			display16 : out std_logic_vector(15 downto 0)
         );
end register_module;

architecture behav of register_module is
   type register_file  is array (0 to 15) of std_logic_vector(31 downto 0);
   signal registers : register_file := (15=> x"0000FFEE", others => x"FFFFFFFF");

begin
	display16 <= registers(2)(15 downto 0);
   databus <= registers(CONV_INTEGER(rbus)) when tri='0' and r_w='1' else "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
   process (clk)
   begin
	--  databus_enable <= '0';
   if clk='1' and clk'event then
      if tri='0' and r_w='0' then
         registers(CONV_INTEGER(rbus)) <= databus;
      end if;
    end if;
--    if tri='0' and r_w='1' then
--         databus_value <= registers(CONV_INTEGER(rbus));
--         databus_enable <= '1';
--      else
--         databus_enable <= '0';
--			databus_value <= "00000000000000000000000000000000";
--      end if; 
   end process;      


end behav;