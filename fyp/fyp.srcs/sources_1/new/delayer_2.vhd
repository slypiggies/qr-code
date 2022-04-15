library ieee; use ieee.all, work.all;
use std_logic_1164.all;

entity delayer_2 is
	generic (DELAY: positive);
	port (
		rst, clk: in std_logic;
		i, i_2: in integer; o, o_2: out integer;
		we: out std_logic
	);
end entity;

architecture delayer_2 of delayer_2 is begin
	delayer_3: entity delayer generic map (DELAY => DELAY) port map (
		rst => rst, clk => clk, i => i, o => o, we => we
	);
	delayer_4: entity delayer generic map (DELAY => DELAY) port map (
		rst => rst, clk => clk, i => i_2, o => o_2, we => open
	);
end architecture;
