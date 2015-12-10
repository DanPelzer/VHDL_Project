library ieee;
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;
use work.common.all;

entity alu is
   port (clk,reset : in std_logic;
         ld,ls1,ls2,ldr1, ldr2 : in std_logic;
         ealu, shcon : in std_logic;             
         opcode : in std_logic_vector(3 downto 0);
         databus: inout std_logic_vector(31 downto 0);
         nzvc : out std_logic_vector(3 downto 0)
         );                                    
end alu;

architecture behav of alu is 
   signal x_reg, y_reg, sh_reg : std_logic_vector(31 downto 0) :="00000000000000000000000000000000";
   signal result : std_logic_vector(32 downto 0) :="000000000000000000000000000000000";
   signal zero, overflow : std_logic;
begin   
   
   nzvc <= result(31) & zero & overflow & result(32); -- No need to disable

   zero <= '1' when result(31 downto 0) = "00000000000000000000000000000000" else '0';
   
   databus <= result(31 downto 0) when ldr2='1' else
              result(31 downto 0) when ldr1='1' else
              "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
                 
   process (reset,opcode,x_reg,y_reg,sh_reg)
      variable result_var : std_logic_vector(32 downto 0);
   begin
      overflow <= '0';
      case opcode is
         when add_opcode =>
            result_var := ('0' & x_reg) + ('0' & y_reg);
            if x_reg(31)='0' and y_reg(31)='0' and result_var(31)='1' then
               overflow <= '1';
            elsif x_reg(31)='1' and y_reg(31)='1' and result_var(31)='0' then
               overflow <= '1';
            end if;
            result <= result_var;
         when sub_opcode => -- FIXME OVERFLOW LOGIC
            result_var := (x_reg(31) & x_reg) - (y_reg(31) & y_reg);
            if x_reg(31)='0' and y_reg(31)='0' and result_var(32)='1' then
               overflow <= '1';
            elsif x_reg(31)='1' and y_reg(31)='1' and result_var(31)='0' then
               overflow <= '1';
            end if;
            result <= result_var;
         when not_opcode => result <= '0' & (x_reg xor "11111111111111111111111111111111");
         when and_opcode => result <= '0' & (x_reg and y_reg);
         when or_opcode  => result <= '0' & (x_reg or y_reg);
         when stm_opcode => result <= sh_reg(31) & sh_reg(30 downto 0) & '0';
         when others => result <= "000000000000000000000000000000000";       
      end case;
   end process;
   

   
   process (clk, reset)
   begin
		if reset='1' then
			x_reg<="00000000000000000000000000000000";
			y_reg<="00000000000000000000000000000000";
			sh_reg<="00000000000000000000000000000000";
      elsif clk='1' and clk'event then
         if shcon='1' and ld='1' then
            sh_reg <= databus;
         end if;
 --        if shcon='1' and sh='1' then
 --           sh_reg <= x_reg(30 downto 0) & "0";
 --           carry <= x_reg(31);
 --        end if;       
         if ealu='1' and ls1='1' then
            x_reg <= databus;
         end if;
         if ealu='1' and  ls2='1' then
            y_reg <= databus;
         end if;
      end if;
   end process;
   
end behav;
      