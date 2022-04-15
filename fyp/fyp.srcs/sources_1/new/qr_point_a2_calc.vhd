library ieee; use ieee.all, work.all;
use std_logic_1164.all;

entity qr_point_a2_calc is
	port (
		rst, clk: in std_logic;
		po, po2: in vec_2_p.vec_2_t;
		dyo, dxo2: in vec_2_p.vec_2_t;
		re: in std_logic;
		pa2: out vec_2_p.vec_2_t;
		we: out std_logic
	);
end entity;

architecture qr_point_a2_calc of qr_point_a2_calc is
	signal po_save, dyo_save: vec_2_p.vec_2_t;
	type state_t is (Q_0, Q_1, Q_2);
	signal state: state_t;
	signal x: vec_2_p.tp_t;
	signal we_cramer: std_logic;
	signal doa2: vec_2_p.vec_2_t;
begin
	cramer_i: entity cramer port map (
		rst => rst, clk => clk,
		a1 => dyo.h,
		b1 => vec_2_p."-"(dxo2.h),
		c1 => vec_2_p."-"(po2.h, po.h),
		a2 => dyo.v,
		b2 => vec_2_p."-"(dxo2.v),
		c2 => vec_2_p."-"(po2.v, po.v),
		re => re,
		x => x, y => open,
		we => we_cramer
	);
	
	process (all) is begin
		if rising_edge(clk) then
			we <= '0'; -- Default value.
			if rst = '1' then
				state <= Q_0;
			elsif re = '1' and state = Q_0 then -- No interrupt other than `rst`.
				state <= Q_1;
				po_save <= po;
				dyo_save <= dyo;
			elsif state = Q_1 and we_cramer = '1' then
				state <= Q_2;
				doa2 <= vec_2_p."*"(dyo_save, x);
			elsif state = Q_2 then
				state <= Q_0;
				pa2 <= vec_2_p."+"(po_save, doa2);
				we <= '1';
			end if;
		end if;
	end process;
end architecture;
