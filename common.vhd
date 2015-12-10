library ieee;
use ieee.std_logic_1164.all;  

package common is

   subtype nibble is std_logic_vector(3 downto 0);

   constant not_opcode : std_logic_vector(3 downto 0) := "0010";       
   constant and_opcode : std_logic_vector(3 downto 0) := "0011";       
   constant or_opcode  : std_logic_vector(3 downto 0) := "0100";       
   constant add_opcode : std_logic_vector(3 downto 0) := "0101";       
   constant sub_opcode : std_logic_vector(3 downto 0) := "0110";       
   constant stm_opcode : std_logic_vector(3 downto 0) := "0111";       
   constant lod_opcode : std_logic_vector(3 downto 0) := "1000";       
   constant sto_opcode : std_logic_vector(3 downto 0) := "1001";       
   constant brn_opcode : std_logic_vector(3 downto 0) := "1100";       
   constant cal_opcode : std_logic_vector(3 downto 0) := "1101";       
   constant hop_opcode : std_logic_vector(3 downto 0) := "1110";       
   constant rtn_opcode : std_logic_vector(3 downto 0) := "1111";
   constant ior_opcode : std_logic_vector(3 downto 0) := "1010";
   
   constant gt_cond  : nibble := "0001"; -- Greater Than
   constant le_cond  : nibble := "0010"; -- Less Than Or Equal
   constant ge_cond  : nibble := "0011"; -- Greater Than or Equal
   constant lt_cond  : nibble := "0100"; -- Less Than
   constant hi_cond  : nibble := "0101"; -- Higher
   constant los_cond : nibble := "0110"; -- Lower or Same
   constant lo_cond  : nibble := "0111"; -- Lower
   constant his_cond : nibble := "1000"; -- Higher Or Same
   constant pl_cond  : nibble := "1001"; -- Plus
   constant mi_cond  : nibble := "1010"; -- Minus
   constant ne_cond  : nibble := "1011"; -- Not Equal
   constant eq_cond  : nibble := "1100"; -- Equal
   constant nv_cond  : nibble := "1101"; -- No Overflow
   constant v_cond   : nibble := "1110"; -- Overflow
   constant alw_cond : nibble := "1111"; -- Always  
   
   constant mode_imm_low            : nibble := "0000"; -- Low Immediate Mode
   constant mode_imm_low_indirect   : nibble := "0001"; -- Low Immediate Indirect 
   constant mode_imm_high           : nibble := "0010"; -- High Immediate 
   constant mode_imm_high_indirect  : nibble := "0011"; -- High Immediate Indirect
   constant mode_reg                : nibble := "0100"; -- Register Direct       
   constant mode_reg_indirect       : nibble := "0101"; -- Register Indirect
   constant mode_disp               : nibble := "0110"; -- Displacement
   constant mode_disp_indirect      : nibble := "0111"; -- Displacement Indirect
   constant mode_pc                 : nibble := "1000"; -- PC
   constant mode_pc_indirect        : nibble := "1001"; -- PC Indirect
   constant mode_pc_offset          : nibble := "1010"; -- PC Offset
   constant mode_pc_offset_indirect : nibble := "1011"; -- PC Offset Indirect
   
   constant reg0 : nibble := "0000";
   constant reg1 : nibble := "0001";
   constant reg2 : nibble := "0010";
   constant reg3 : nibble := "0011";
   constant reg4 : nibble := "0100";
   constant reg5 : nibble := "0101";
   constant reg6 : nibble := "0110";
   constant reg7 : nibble := "0111";
   constant reg8 : nibble := "1000";
   constant reg9 : nibble := "1001";
   constant regA : nibble := "1010";
   constant regB : nibble := "1011";
   constant regC : nibble := "1100";
   constant regD : nibble := "1101";
   constant regE : nibble := "1110";
   constant regF : nibble := "1111";
   
   function eval_cc (mode : in nibble; carry, zero, overflow, negative : in std_logic)
   return std_logic;

end package common;


package body common is
   function eval_cc (mode : in nibble; carry, zero, overflow, negative : in std_logic)
   return std_logic 
   is
      variable truth : std_logic := '0';
   begin                
      case mode is                       
         when gt_cond  => truth := not negative and not zero;
         when le_cond  => truth := negative and not zero;
         when ge_cond  => truth := not negative;
         when lt_cond  => truth := negative;
         when hi_cond  => truth := not negative and not zero; 
         when los_cond => truth := negative or zero;
         when lo_cond  => truth := negative;
         when his_cond => truth := not zero or not negative;
         when pl_cond  => truth := not negative and not zero;
         when mi_cond  => truth := negative;
         when ne_cond  => truth := not zero;
         when eq_cond  => truth := zero;
         when nv_cond  => truth := not overflow;
         when v_cond   => truth := overflow and carry;
         when alw_cond => truth := '1'; 
         when others => truth := '0';
      end case;
      return truth;
   end function eval_cc;
end package body;