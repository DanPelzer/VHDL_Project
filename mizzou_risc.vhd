library ieee;

use ieee.std_logic_1164.all;

use work.all;
entity mizzou_risc is

   port (clk, reset : in std_logic;
         addbus : inout std_logic_vector(31 downto 0) := "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
         databus : inout std_logic_vector(31 downto 0) := "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
         priority : in std_logic_vector(1 downto 0);
         int_ack : out std_logic := '0';
         read_memory : out std_logic := '0';
         write_memory : out std_logic := '0';
         halt : out std_logic := '0';
	 inc_w : out std_logic := '0';
	 display16 : out std_logic_vector(15 downto 0)
         );
end mizzou_risc;

architecture struct of mizzou_risc is
   signal immediate : std_logic_vector(15 downto 0);
   signal displacement : std_logic_vector(21 downto 0);
   signal io : std_logic;
   signal psw : std_logic_vector(3 downto 0);
   signal fetch, ia, irld, ldr1, ldr2, ls1, ls2, mmoe, pswld, rdoe, r_w, rs1oe, rs2oe: std_logic := '0';    
   signal tri: std_logic;
   signal ir : std_logic_vector(31 downto 0);                                 
   signal rbus : std_logic_vector(3 downto 0);
   constant dev_addr : std_logic_vector(31 downto 0) := "00000000000000000000000000000100";
   signal ld, ealu, shcon : std_logic := '0'; 
   signal nzvc, mode, condition_code, opcode : std_logic_vector (3 downto 0) := "0000"; 
   signal rel, rsnest, abst, npc : std_logic;
   signal inc1,inc2 : std_logic_vector (3 downto 0); -- 
   signal inc_wi : std_logic;
   --signal inc_wi : std_logic := '0';
 --  signal rsdep : std_logic_vector(1 downto 0);
   signal halti: std_logic;
begin
--   display <= ir;
--	read_memory <= read_memory_i or ia;
   halt <= halti;
   inc_w <= inc_wi;
	--inc_wi <= inc_w;
   int_ack <= ia;
   opcode <= ir(31 downto 28);
   condition_code <= ir(27 downto 24);
   mode <= ir(23 downto 20);
   inc1 <= ir(15 downto 12); -- Rd
   inc2 <= ir(11 downto 8); -- Rs
   immediate <= ir (15 downto 0);
   displacement <= ir(21 downto 0);
   C0: entity memory_module port map (clk, reset, ia, fetch, mmoe, pswld, rel, abst, rsnest, npc, nzvc,
                                      mode, opcode, immediate, displacement, addbus,
                                      databus, read_memory, write_memory, psw, inc_wi,rdoe, rs1oe);
   C1: entity instruction_decoder port map (clk, reset, databus, irld, rs1oe, rs2oe, rdoe, ir, rbus);
   C2: entity io_module port map (ia, priority, io, dev_addr, addbus);  
   C3: entity register_module port map (clk, r_w, tri, databus, rbus, display16);
   C4: entity alu port map (clk,reset,ld,ls1,ls2,ldr1,ldr2,ealu,shcon,opcode,databus,nzvc);   
   C5: entity controller port map (clk, io, opcode, condition_code, psw, reset, halti,
         ealu, shcon, fetch, ia, irld, ldr1, ldr2, ld, ls1, ls2, mmoe, pswld, rdoe, r_w, rs1oe, rs2oe, tri,
         rel, rsnest, abst, npc,inc1,inc2,inc_wi);  
end struct;                      