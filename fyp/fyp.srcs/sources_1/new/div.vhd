library ieee, vivado_sucks; use ieee.all, work.all;
use std_logic_1164.all, vivado_sucks.fixed_pkg.all, helper.all;

entity div is
	port (
		rst, clk: in std_logic;
		l, r: in vec_2_p.tp_t;
		re: in std_logic;
		o: out vec_2_p.tp_t;
		we: out std_logic
	);
end entity;

architecture div of div is
	signal l_abs, r_abs, o_abs: vec_2_p.tp_t;
	signal neg: std_logic;
	signal l_2, r_2: sfixed(vec_2_p.tp_t'length * 2 - 1 - 1 downto vec_2_p.tp_t'right);
	signal o_2: sfixed(vec_2_p.tp_t'length - 1 downto vec_2_p.tp_t'right);
	signal o_index: integer;
	type state_t is (Q_0, Q_1);
	signal state: state_t;
begin
	l_abs <= vec_2_p."abs"(l); r_abs <= vec_2_p."abs"(r);
	o_abs <= o_2(o'range);
	o <=
		o_abs when neg = '0'
		else vec_2_p."-"(o_abs);
	
	process (all) is
		variable l_tmp: sfixed(l_2'left + 1 downto l_2'right);
	begin
		if rising_edge(clk) then
			we <= '0'; -- Default value.
			if rst = '1' then
				state <= Q_0;
			elsif re = '1' and state = Q_0 then -- No interrupt other than `rst`.
				state <= Q_1;
				neg <= l(l'left) xor r(r'left);
				l_2 <= (others => '0');
				r_2 <= (others => '0');
				o_2 <= (others => '0');
				l_2(l_abs'length - 1 downto 0) <= l_abs;
				r_2(r_2'left downto r_2'left - r_abs'length + 1) <= r_abs;
				o_index <= o_2'left;
			elsif state = Q_1 then
				if r_2 <= l_2 then
					o_2(o_index) <= '1';
					l_tmp := l_2 - r_2;
					l_2 <= l_tmp(l_2'range);
				else
					o_2(o_index) <= '0';
				end if;
				if o_index - 1 < o_2'right then
					state <= Q_0;
					we <= '1';
				else
					r_2 <= shift_right(r_2, 1);
					o_index <= o_index - 1;
				end if;
			end if;
		end if;
	end process;
end architecture;
