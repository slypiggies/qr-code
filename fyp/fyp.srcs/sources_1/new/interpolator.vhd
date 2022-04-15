library ieee; use ieee.all, work.all;
use std_logic_1164.all;

entity interpolator is
	port (
		rst, clk: in std_logic;
		l, r: in vec_2_p.tp_t;
		l_val, r_val: in vec_2_p.tp_t;
		target: in vec_2_p.tp_t;
		re: in std_logic;
		target_val: out vec_2_p.tp_t;
		we: out std_logic
	);
end entity;

architecture interpolator of interpolator is
	signal l_val_save, target_save: vec_2_p.tp_t;
	signal o: vec_2_p.tp_t;
	signal re_div, we_div: std_logic;
	type state_t is (Q_0, Q_1, Q_2);
	signal state: state_t;
	signal delta: vec_2_p.tp_t;
begin
	div_i: entity div port map (
		rst => rst, clk => clk,
		l => vec_2_p."-"(r_val, l_val),
		r => vec_2_p."-"(r, l),
		re => re_div,
		o => o,
		we => we_div
	);
	
	process (all) is begin
		if rising_edge(clk) then
			we <= '0'; -- Default value.
			re_div <= '0'; -- Default value.
			if rst = '1' then
				state <= Q_0;
			elsif re = '1' and state = Q_0 then -- No interrupt other than `rst`.
				state <= Q_1;
				l_val_save <= l_val;
				target_save <= target;
				re_div <= '1';
			elsif state = Q_1 and we_div = '1' then
				state <= Q_2;
				delta <= vec_2_p."*"(o, vec_2_p."-"(target_save, l));
			elsif state = Q_2 then
				state <= Q_0;
				target_val <= vec_2_p."+"(l_val_save, delta);
				we <= '1';
			end if;
		end if;
	end process;
end architecture;
