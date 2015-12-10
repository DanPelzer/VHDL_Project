library ieee;
use ieee.std_logic_1164.all;  
use ieee.std_logic_unsigned.all;

use work.common.all;

entity memory_module is
   port (clk,reset   : in std_logic;
         ia, fetch, mmoe, pswld, rel, abst, rsnest,npc : in std_logic;
         nzvc, mode : in std_logic_vector(3 downto 0);
         opcode : in std_logic_vector(3 downto 0);
         immediate : in std_logic_vector(15 downto 0);
         displacement : in std_logic_vector(21 downto 0);
         addbus, databus : inout std_logic_vector(31 downto 0);
         read : out std_logic;
         write : out std_logic;
         psw : out std_logic_vector(3 downto 0);
		 inc_w : in std_logic;
	rdoe, rs1oe : in std_logic
         );
end memory_module;

architecture behav of memory_module is
   signal addbus_value, databus_value : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
   signal enable_addbus, enable_databus: std_logic := '0';
   signal pc : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
   signal psw_internal : std_logic_vector(3 downto 0) := "0000";
   type pc_reg_store_type is array (0 to 3) of std_logic_vector(31 downto 0);
   type psw_reg_store_type is array (0 to 3) of std_logic_vector(3 downto 0);
	signal pc_store : pc_reg_store_type;
   signal psw_store : psw_reg_store_type;
	signal rsdep : integer range 0 to 4 := 0; -- : std_logic_vector(1 downto 0) := "00";
   signal read_internal, write_internal : std_logic := '0';
   signal displacement32, addbus_value2 : std_logic_vector(31 downto 0);
begin                                                    
   displacement32(21 downto 0) <= displacement;
   displacement32(31 downto 22) <= (31 downto 22 => displacement(21));
   
   psw <= psw_internal(3 downto 0);
   addbus <= addbus_value when enable_addbus='1' else "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
   databus <= databus_value when enable_databus='1' else "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
   read <= read_internal;
   write <= write_internal;   

	process (clk)
	begin
        if clk='0' and clk'event then
        if mmoe='1' and opcode=lod_opcode then
           case mode is
              when "0000" => -- Immediate
                databus_value <= "0000000000000000" & immediate;
              when "0001" => -- Immediate Indirect
                 addbus_value2 <= "0000000000000000" & immediate;   
              when "0010" => -- Immediate High
                 databus_value <= immediate & "0000000000000000";
              when "0011" => -- Immediate High Indirect
                 addbus_value2 <=  immediate & "0000000000000000";   
              when "0100" => -- Register Direct
			           databus_value <= databus;
              when "0101" => -- Register Indirect
                 addbus_value2 <= databus;
              when "0110" => -- Displacement
                 databus_value <= databus+immediate;
              when "0111" => -- Displacement Indirect
                 addbus_value2 <= databus+immediate;
              when "1000" => -- PC
                 databus_value <=  pc;   
              when "1001" => -- PC Indirect
                 addbus_value2 <=  pc;   
              when "1010" => -- PC Offset
                 databus_value <=  pc+immediate;                 
              when "1011" => -- PCOffset Indiret
			        addbus_value2 <=  pc+immediate;   
		      when others => null;
           end case;
        end if;
        if mmoe='1' and opcode=sto_opcode then 
            case mode is
               when "0000" => -- Immediate
                  -- illegal
               when "0001" => -- Immediate Indirect
                  addbus_value2 <= "0000000000000000" & immediate;   
               when "0010" => -- Immediate High
                  -- illegal
               when "0011" => -- Immediate High Indirect
                  addbus_value2 <=  immediate & "0000000000000000";   
               when "0100" => -- Register Direct
			         databus_value <= databus;
               when "0101" => -- Register Indirect
                  addbus_value2 <= databus;
               when "0110" => -- Displacement
                  -- illegal
               when "0111" => -- Displacement Indirect
                  addbus_value2 <= databus+immediate;
               when "1000" => -- PC
                  -- illegal         
               when "1001" => -- PC Indirect
                  addbus_value2 <=  pc;   
               when "1010" => -- PC Offset
                  -- illegal                 
               when "1011" => -- PCOffset Indiret
                  addbus_value2 <=  pc+immediate;   
               when others => null;
            end case;
	end if;
		    if mmoe = '1' and opcode = stm_opcode and rdoe = '1' and inc_w = '0' then 
			databus_value <= databus_value + 4; -- increment databus value by 4
		    end if;
		    if mmoe = '1' and opcode = stm_opcode and rs1oe = '1' and inc_w = '0' then 
		    databus_value <= databus_value + 4; -- increment databus value by 4
		   end if;
			if mmoe = '1' and opcode = stm_opcode and rdoe = '1' and inc_w = '1' then 
			addbus_value2 <= databus; -- put the incremented address on the addbus
			end if;
			if mmoe = '1' and opcode = stm_opcode and rs1oe = '1' and inc_w = '1' then
			addbus_value2 <= databus; -- put the incremented address on the addbus			
			end if;
			end if;
		end process;	
   
	process (clk,reset)
   begin
     if reset='1' then
       pc<="00000000000000000000000000000000";
       rsdep<=0;
       pc_store<= ( x"00000000",
                    x"00000000",
                    x"00000000",
                    x"00000000");
       psw_store<=( b"0000",
                    b"0000",
                    b"0000",
                    b"0000");
       
     else
      if clk='1' and clk'event then
		 enable_addbus <= '0'; enable_databus <= '0'; read_internal <= '0'; write_internal <= '0';
		 		 if ia='1' then
			 pc <= addbus+4;
			addbus_value <=addbus;
			enable_addbus <= '1';
			 pc_store(rsdep) <= pc;
            rsdep <= rsdep+ 1;
            psw_store(rsdep) <= psw_internal;
            read_internal <= '1';
          elsif fetch='1' then
		   	addbus_value <= pc;
            pc <= pc + 4;
				enable_addbus <= '1';
            read_internal <= '1';
	     end if;
		 if mmoe='1' and opcode=lod_opcode then 
			  addbus_value <= addbus_value2;
              case mode is
              when "0000" => -- Immediate
                 enable_databus <= '1';
              when "0001" => -- Immediate Indirect
                 enable_addbus <= '1';
					       read_internal <= '1';
              when "0010" => -- Immediate High
                 enable_databus <= '1';
              when "0011" => -- Immediate High Indirect
                 enable_addbus <= '1';
					       read_internal <= '1';
              when "0100" => -- Register Direct
			           enable_databus <= '1';
              when "0101" => -- Register Indirect
                 enable_addbus <= '1';
				         read_internal <= '1';
              when "0110" => -- Displacement
                 enable_databus <= '1';
              when "0111" => -- Displacement Indirect
                 enable_addbus <= '1';
					       read_internal <= '1';
              when "1000" => -- PC
                 enable_databus <= '1';
              when "1001" => -- PC Indirect
                enable_addbus <= '1';
					      read_internal <= '1';
              when "1010" => -- PC Offset
                 enable_databus <= '1';              
              when "1011" => -- PCOffset Indiret
			           enable_addbus <= '1';
					       read_internal <= '1';
		      when others => null;
           end case;
        end if;


       if mmoe='1' and opcode=sto_opcode then
            addbus_value <= addbus_value2;		 
            case mode is
               when "0000" => -- Immediate
                  -- illegal
               when "0001" => -- Immediate Indirect
                  enable_addbus <= '1';
                  write_internal <= '1';				
               when "0010" => -- Immediate High
                  -- illegal
               when "0011" => -- Immediate High Indirect
                  enable_addbus <= '1';  
                  write_internal <= '1';
					when "0100" => -- Register Direct
			         enable_databus <= '1';
               when "0101" => -- Register Indirect
			         enable_addbus <= '1';
			   	     write_internal <= '1';
               when "0110" => -- Displacement
                  -- illegal
               when "0111" => -- Displacement Indirect
			   enable_addbus <= '1';	
			   write_internal <= '1';
               when "1000" => -- PC
                  -- illegal         
               when "1001" => -- PC Indirect
                  enable_addbus <= '1';  
               when "1010" => -- PC Offset
                  -- illegal                 
               when "1011" => -- PCOffset Indiret
                  enable_addbus <= '1'; 
               when others => null;
            end case;
		   end if;

		  if rel='1' and ia='0' then
            pc <= pc + displacement32;
            end if;
         if abst='1' and ia='0' then
            pc <= displacement & "0000000000";
            end if;
         if rsnest='1' then
            pc_store(rsdep) <= pc;
            rsdep <= rsdep+ 1;
            psw_store(rsdep) <= psw_internal;
            end if;
         if npc='1' and ia='0' then
            pc<= pc_store(rsdep-1) + displacement;
            psw_internal <= psw_store(rsdep-1);
            rsdep <= rsdep-1;
            end if;
         if pswld='1' then
            psw_internal <= nzvc;
            end if;
		 if mmoe = '1' and opcode = stm_opcode and rdoe = '1' and inc_w = '0' then 
			enable_databus <= '1';
			end if;
		if mmoe = '1' and opcode = stm_opcode and rs1oe = '1' and inc_w = '0' then 
			enable_databus <= '1';
			end if;
		if mmoe = '1' and opcode = stm_opcode and rdoe = '1' and inc_w = '1' then 
			addbus_value <= addbus_value2;
			addbus_value(16) <= '1'; -- set ram select
			enable_addbus <= '1';
				write_internal <= '1';
		end if;
		if mmoe = '1' and opcode = stm_opcode and rs1oe = '1' and inc_w = '1' then 
			addbus_value <= addbus_value2;
			addbus_value(16) <= '1'; -- set ram select
			enable_addbus <= '1';
			write_internal <= '1';
		end if;		
	   end if;
	   end if;
   end process;
end behav;