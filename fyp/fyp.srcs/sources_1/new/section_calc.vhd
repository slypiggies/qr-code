-- https://web.archive.org/web/20220415024700/https://en.wikipedia.org/wiki/Section_formula#Internal_Divisions

library ieee; use ieee.all, work.all;
use std_logic_1164.all;

entity section_calc is
	port (
		rst, clk: in std_logic;
		pb, pe: in vec_2_p.vec_2_t; -- Point begin, end.
		m, n: in vec_2_p.tp_t; -- Ratio `m`:`n`.
		re: in std_logic;
		pi: out vec_2_p.vec_2_t; -- Point intermediate.
		we: out std_logic
	);
end entity;

architecture section_calc of section_calc is
	signal pi_2: vec_2_p.vec_2_t;
	signal mx2, nx1, my2, ny1: vec_2_p.tp_t;
	signal re_div_2, we_div_2: std_logic;
	signal state: std_logic;
begin
	div_2_i: entity div_2 port map (
		rst => rst, clk => clk,
		l => vec_2_p.to_vec_2_t(vec_2_p."+"(mx2, nx1), vec_2_p."+"(my2, ny1)),
		r => vec_2_p."+"(m, n),
		re => re_div_2,
		o => pi_2,
		we => we_div_2
	);
	
	process (all) is begin
		if rising_edge(clk) then
			we <= '0'; -- Default value.
			re_div_2 <= '0'; -- Default value.
			if rst = '1' then
				state <= '0';
			elsif re = '1' and state = '0' then -- No interrupt other than `rst`.
				state <= '1';
				mx2 <= vec_2_p."*"(m, pe.h);
				nx1 <= vec_2_p."*"(n, pb.h);
				my2 <= vec_2_p."*"(m, pe.v);
				ny1 <= vec_2_p."*"(n, pb.v);
				re_div_2 <= '1';
			elsif state = '1' and we_div_2 = '1' then
				state <= '0';
				pi <= pi_2;
				we <= '1';
			end if;
		end if;
	end process;
end architecture;
