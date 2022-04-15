library ieee; use ieee.all, work.all;
use std_logic_1164.all;

entity div_2 is
	port (
		rst, clk: in std_logic;
		l: in vec_2_p.vec_2_t;
		r: in vec_2_p.tp_t;
		re: in std_logic;
		o: out vec_2_p.vec_2_t;
		we: out std_logic
	);
end entity;

architecture div_2 of div_2 is begin
	div_h_i: entity div port map (
		rst => rst, clk => clk,
		l => l.h, r => r,
		re => re,
		o => o.h,
		we => we
	);
	div_v_i: entity div port map (
		rst => rst, clk => clk,
		l => l.v, r => r,
		re => re,
		o => o.v,
		we => open
	);
end architecture;
