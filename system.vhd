library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.all;

entity system is
   port (clk: in std_logic;
		  DISP_SEL: inout std_logic_vector(0 to 3);
		  DISP_LED: out std_logic_vector(6 downto 0);
		  DISP_DOT: out std_logic;
		  LED: out std_logic			
		 );
end system;

architecture Behavioral of system is
	signal databus, addbus: std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
	signal priority : std_logic_vector(1 downto 0) := "00";
	signal read_memory, write_memory : std_logic := '0';
	signal int_ack, halt, reset : std_logic := '0';
	signal inc_w : std_logic := '0';
	signal rom_select : std_logic := '0';
	signal ram_select : std_logic := '0';
	signal display16 : std_logic_vector(15 downto 0) := x"ABCD";
	signal counter : std_logic_vector ( 2 downto 0);	
	component AnodeControl 
	port (clk	: in std_logic;  		--Complete syntax
			counter_out	:	out std_logic_vector (2 downto 0);
			Anode	:	out std_logic_vector (3 downto 0));
	end component;

	component LEDDisplay is
	  port(DISPLAY	: 	in std_logic_vector(15 downto 0);
			counter:	in std_logic_vector (2 downto 0);
			segment_a, segment_b, segment_c, segment_d, segment_e, segment_f, segment_g:	out std_logic);
	end component;
	
begin
	DISP_DOT <= '1';
   reset <= '0'; --KEY(0);

	LEDDisplay0: 	LEDDisplay  port map (display16, counter, DISP_LED(0) , DISP_LED(1) , DISP_LED(2)
	, DISP_LED(3),DISP_LED(4) ,DISP_LED(5),DISP_LED(6));
	ANDisplay:	AnodeControl port map (clk, counter, DISP_SEL);

   rom_select <= '1' when addbus(16)='0' and CONV_INTEGER(addbus(16 downto 0))<101 and read_memory='1' else '0';
  ram_select <= '1' when addbus(16) = '1' and (read_memory='1' or write_memory='1') else '0';

   LED <= halt;
			
   C0: entity mizzou_risc port map
	   (clk, reset, addbus, databus, priority, int_ack,
	    read_memory, write_memory, halt, inc_w, display16);
   C1: entity rom(program1) port map (rom_select, addbus(9 downto 2), databus);
   C2: entity ram(ramit) port map (clk,ram_select, read_memory, write_memory, addbus,databus);
   
end Behavioral;
