library ieee;
use ieee.all;
use std_logic_1164.all;
use numeric_std.all;
use work.all;
use helper_tb.all;

entity delayer_tb is
	port (
		reset, clk: in std_logic
	);
end entity;

architecture delayer_tb_a of delayer_tb is
	signal i, o: unsigned(LENGTH_S - 1 downto 0);
	signal we: std_logic;
	signal j: natural := 0;
begin
	delayer_i: entity delayer generic map (
		DELAY => DELAY_S,
		LENGTH => LENGTH_S
	) port map (
		reset => reset,
		clk => clk,
		i => i,
		o => o,
		we => we
	);
	
	process begin
		i <= to_unsigned(REG_S(j), i'length);
		if j = REG_S'length - 1 then
			j <= 0;
		else
			j <= j + 1;
		end if;
		wait until rising_edge(clk);
	end process; 
end architecture;
