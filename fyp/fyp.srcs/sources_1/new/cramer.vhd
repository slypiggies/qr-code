-- https://web.archive.org/web/20220413200651/https://en.wikipedia.org/wiki/Cramer%27s_rule#Explicit_formulas_for_small_systems

library ieee; use ieee.all, work.all;
use std_logic_1164.all;

entity cramer is
	port (
		rst, clk: in std_logic;
		a1, b1, c1, a2, b2, c2: vec_2_p.tp_t;
		re: in std_logic;
		x, y: out vec_2_p.tp_t;
		we: out std_logic
	);
end entity;

architecture cramer of cramer is
	type state_t is (Q_0, Q_1, Q_2);
	signal state: state_t;
	signal c1b2, b1c2, a1c2, c1a2, a1b2, b1a2: vec_2_p.tp_t;
	signal x_frac, y_frac: vec_2_p.vec_2_t; -- `h` represents the numerator, and `v` represents the denominator.
	signal re_div, we_div: std_logic;
begin
	div_x_i: entity div port map (
		rst => rst, clk => clk,
		l => x_frac.h, r => x_frac.v,
		re => re_div,
		o => x,
		we => we_div
	);
	div_y_i: entity div port map (
		rst => rst, clk => clk,
		l => y_frac.h, r => y_frac.v,
		re => re_div,
		o => y,
		we => open
	);
	
	process (all) is begin
		if rising_edge(clk) then
			we <= '0'; -- Default value.
			re_div <= '0'; -- Default value.
			if rst = '1' then
				state <= Q_0;
			elsif re = '1' and state = Q_0 then -- No interrupt other than `rst`.
				state <= Q_1;
				c1b2 <= vec_2_p."*"(c1, b2);
				b1c2 <= vec_2_p."*"(b1, c2);
				a1c2 <= vec_2_p."*"(a1, c2);
				c1a2 <= vec_2_p."*"(c1, a2);
				a1b2 <= vec_2_p."*"(a1, b2);
				b1a2 <= vec_2_p."*"(b1, a2);
			elsif state = Q_1 then
				state <= Q_2;
				x_frac <= vec_2_p.to_vec_2_t(vec_2_p."-"(c1b2, b1c2), vec_2_p."-"(a1b2, b1a2));
				y_frac <= vec_2_p.to_vec_2_t(vec_2_p."-"(a1c2, c1a2), vec_2_p."-"(a1b2, b1a2));
				re_div <= '1';
			elsif state = Q_2 and we_div = '1' then
				state <= Q_0;
				we <= '1';
			end if;
		end if;
	end process;
end architecture;
