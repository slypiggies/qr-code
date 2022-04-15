library ieee; use ieee.all, work.all;
use std_logic_1164.all, helper.all;

entity qr_extractor is
	port (
		rst, clk: in std_logic;
		pa, po, po2: in vec_2_p.vec_2_t;
		dxa, dya, dxo, dyo, dxo2, dyo2: in vec_2_p.vec_2_t;
		n: in positive;
		re: in std_logic;
		addr: out vec_2_p.vec_2_t;
		we: out std_logic;
		ed: out std_logic -- End of QR code.
	);
end entity;

architecture qr_extractor of qr_extractor is
	signal pa_save, dxa_save, dya_save, dxo_save, dyo2_save, pa2_save: vec_2_p.vec_2_t;
	signal n_save: positive;
	signal dao, dao2, dao_div, dao2_div: vec_2_p.vec_2_t;
	signal x_ddx, y_ddy, x_ddy, y_ddx: vec_2_p.vec_2_t; -- The sign does matter.
	signal x_ddx_div, y_ddy_div, x_ddy_div, y_ddx_div: vec_2_p.vec_2_t;
	type state_t is (Q_0, Q_1, Q_2, Q_3);
	signal state: state_t;
	signal re_div_2, we_div_2, re_qr_point_a2_calc, we_qr_point_a2_calc: std_logic;
	signal i, x, y, x_dx, y_dy, x_dy, y_dx: vec_2_p.vec_2_t;
begin
	div_2_dao_i: entity div_2 port map (
		rst => rst, clk => clk,
		l => dao, r => vec_2_p.to_tp_t(n_save),
		re => re_div_2,
		o => dao_div,
		we => we_div_2
	);
	div_2_dao2_i: entity div_2 port map (
		rst => rst, clk => clk,
		l => dao2, r => vec_2_p.to_tp_t(n_save),
		re => re_div_2,
		o => dao2_div,
		we => open
	);
	div_2_x_ddx_i: entity div_2 port map (
		rst => rst, clk => clk,
		l => x_ddx, r => vec_2_p.to_tp_t(n_save),
		re => re_div_2,
		o => x_ddx_div,
		we => open
	);
	div_2_y_ddy_i: entity div_2 port map (
		rst => rst, clk => clk,
		l => y_ddy, r => vec_2_p.to_tp_t(n_save),
		re => re_div_2,
		o => y_ddy_div,
		we => open
	);
	div_2_x_ddy_i: entity div_2 port map (
		rst => rst, clk => clk,
		l => x_ddy, r => vec_2_p.to_tp_t(n_save),
		re => re_div_2,
		o => x_ddy_div,
		we => open
	);
	div_2_y_ddx_i: entity div_2 port map (
		rst => rst, clk => clk,
		l => y_ddx, r => vec_2_p.to_tp_t(n_save),
		re => re_div_2,
		o => y_ddx_div,
		we => open
	);
	
	qr_point_a2_calc_i: entity qr_point_a2_calc port map (
		rst => rst, clk => clk,
		po => x, po2 => y,
		dyo => x_dy, dxo2 => y_dx,
		re => re_qr_point_a2_calc,
		pa2 => pa2_save,
		we => we_qr_point_a2_calc
	);
	
	process (all) is begin
		if rising_edge(clk) then
			we <= '0'; -- Default value.
			ed <= '0'; -- Default value.
			re_div_2 <= '0'; -- Default value.
			re_qr_point_a2_calc <= '0'; -- Default value.
			if rst = '1' then
				state <= Q_0;
			elsif re = '1' and state = Q_0 then -- No interrupt other than `rst`.
				state <= Q_1;
				pa_save <= pa;
				dxa_save <= dxa;
				dya_save <= dya;
				dxo_save <= dxo;
				dyo2_save <= dyo2;
				n_save <= mul_2(n);
				dao <= vec_2_p."-"(po, pa);
				dao2 <= vec_2_p."-"(po2, pa);
				x_ddx <= vec_2_p.shift_right(vec_2_p."-"(dxo, dxa), 1);
				y_ddy <= vec_2_p.shift_right(vec_2_p."-"(dyo2, dya), 1);
				x_ddy <= vec_2_p."-"(dyo, dya);
				y_ddx <= vec_2_p."-"(dxo2, dxa);
				re_div_2 <= '1';
				i <= vec_2_p.VEC_2_T_ZERO;
				x <= pa; y <= pa;
				x_dx <= vec_2_p.shift_right(dxa, 1); y_dy <= vec_2_p.shift_right(dya, 1);
				x_dy <= dya; y_dx <= dxa;
				re_qr_point_a2_calc <= '1';
			elsif state = Q_1 and we_div_2 = '1' then
				state <= Q_2;
			elsif state = Q_2 and we_qr_point_a2_calc = '1' then
				state <= Q_3;
				addr <= pa2_save;
				if mod_2(vec_2_p.to_integer(i.h)) = 1 and mod_2(vec_2_p.to_integer(i.v)) = 1 then
					we <= '1';
				end if;
			elsif state = Q_3 then
				if vec_2_p."="(i, vec_2_p.to_vec_2_t(n_save - 1, n_save - 1)) then
					state <= Q_0;
					ed <= '1';
				else
					state <= Q_2;
					i <= vec_2_p.inc_h(i, vec_2_p.to_vec_2_t(n_save, n_save));
					if vec_2_p."="(i.h, vec_2_p.to_tp_t(n_save - 1)) then
						x <= pa_save;
						x_dx <= vec_2_p.shift_right(dxa_save, 1);
						x_dy <= dya_save;
						y <= vec_2_p."+"(y, dao2_div);
						y_dy <= vec_2_p."+"(y_dy, y_ddy_div);
						y_dx <= vec_2_p."+"(y_dx, y_ddx_div);
					else
						x <= vec_2_p."+"(x, dao_div);
						x_dx <= vec_2_p."+"(x_dx, x_ddx_div);
						x_dy <= vec_2_p."+"(x_dy, x_ddy_div);
					end if;
					re_qr_point_a2_calc <= '1';
				end if;
			end if;
		end if;
	end process;
end architecture;
