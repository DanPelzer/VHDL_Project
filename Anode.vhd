library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity AnodeControl is
  port (clk 		:in std_logic;  
  	   counter_out	:out std_logic_vector (2 downto 0);
	   Anode		:out std_logic_vector (3 downto 0));
end AnodeControl;

architecture behav of AnodeControl is
	signal Anode_temp : std_logic_vector (3 downto 0) :="1111";
	signal counter : std_logic_vector (7 downto 0) := "11111111";
	signal counter_temp : std_logic_vector (2 downto 0);
begin
	Anode <= Anode_temp;
	counter_out <= counter(7) & counter(6) & counter(5);
	counter_temp <= counter(7) & counter(6) & counter(5);

	process (clk)
		begin
			if (clk'event and clk='1') then
				counter <= counter + 1;
			end if;
	end process;

	process (counter_temp(0), clk)
		begin
		if (clk'event and clk='1') then	
			if (counter_temp = "000") then
				Anode_temp <= "1110";
			elsif (counter_temp = "010") then
				Anode_temp <= "1101";
			elsif (counter_temp = "100") then
				Anode_temp <= "1011";
			elsif (counter_temp = "110") then
				Anode_temp <= "0111";
			else
				Anode_temp <= "1111";
			end if;
		end if;
	end process;

end behav;
