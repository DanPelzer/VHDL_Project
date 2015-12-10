library ieee;
use ieee.std_logic_1164.all;                           
use ieee.std_logic_unsigned.all;

use work.common.all;

entity instruction_decoder is
   port ( clk,reset : in std_logic;
          databus : in std_logic_vector(31 downto 0);
          irld, rs1oe, rs2oe, rdoe : in std_logic;   
          ir : out std_logic_vector(31 downto 0);
          rbus : out nibble
          );
end instruction_decoder;

architecture behav of instruction_decoder is
   signal ir_reg : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
begin                                                          
   ir <= ir_reg;
   process (rdoe,rs2oe,rs1oe, ir_reg)
   begin
      if rdoe='1' then               
         rbus <= ir_reg(27 downto 24);
      elsif rs2oe='1' then
         rbus <= ir_reg(23 downto 20);
      elsif rs1oe='1' then
        rbus <= ir_reg(19 downto 16);
		else
		   rbus <= "0000";
      end if;
   end process;
   
---   rbus <= ir_reg(27 downto 24) when rdoe='1'
 ---          else ir_reg(23 downto 20) when rs2oe='1'
  --         else ir_reg(19 downto 16) when rs1oe='1'
  --         else rbus;
   process (reset,clk,irld,databus)
   begin
		if reset='1' then
			ir_reg<="00000000000000000000000000000000";
      elsif clk='1' and clk'event then
         if irld='1' then
            ir_reg <= databus; --x"91300001"; --databus;
         end if;
      end if;
   end process;
end behav;