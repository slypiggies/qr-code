library ieee; use ieee.all, work.all;
use std_logic_1164.all;

entity interpolator_2 is
	port (
		rst, clk: in std_logic;
		l, r: in vec_2_p.tp_t;
		l_val, r_val: in vec_2_p.vec_2_t;
		target: in vec_2_p.tp_t;
		re: in std_logic;
		target_val: out vec_2_p.vec_2_t;
		we: out std_logic
	);
end entity;

architecture interpolator_2 of interpolator_2 is begin
	interpolator_h_i: entity interpolator port map (
		rst => rst, clk => clk,
		l => l, r => r,
		l_val => l_val.h, r_val => r_val.h,
		target => target,
		re => re,
		target_val => target_val.h,
		we => we
	);
	interpolator_v_i: entity interpolator port map (
		rst => rst, clk => clk,
		l => l, r => r,
		l_val => l_val.v, r_val => r_val.v,
		target => target,
		re => re,
		target_val => target_val.v,
		we => we
	);
end architecture;
