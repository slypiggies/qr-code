library ieee; use ieee.all, work.all;
use std_logic_1164.all, helper.all;

entity qr_fine_tuner is
	port (
		rst, clk: in std_logic;
		po, po2: in vec_2_p.vec_2_t; -- Point O (lower-left) and O2 (upper-right). Point A is not needed, and A2 will be calculated shortly...
		dyo_i, dxo2_i: in vec_2_p.vec_2_t; -- DY at point O and DX at O2. Others don't need to be fixed.
		dxo, dyo2: in vec_2_p.vec_2_t; -- Don't need to be fixed, but still needed for the fine-tuning.
		re_qr_fine_tuner: in std_logic;
		addr_o: out vec_2_p.vec_2_t;
		addr_i: in vec_2_p.vec_2_t;
		px: in px_t;
		re_i_fb_controller: out std_logic;
		re_o_fb_controller: in std_logic;
		dyo_o, dxo2_o: out vec_2_p.vec_2_t;
		we: out std_logic
	);
end entity;

architecture qr_fine_tuner of qr_fine_tuner is
	signal po_save, po2_save, dxo_save, dyo2_save: vec_2_p.vec_2_t;
	constant MUL: real := 6.0; -- `7` is the side length of the outer marker squares.
	signal dyo_save, dxo2_save, dyo_new, dxo2_new: vec_2_p.vec_2_t; -- All multiplied by `MUL`.
	signal dyo_2, dxo2_2: vec_2_p.vec_2_t;
	signal re_i_fb_controller_2: std_logic;
	signal p4: vec_2_p.vec_2_t_array_t(0 to 4 - 1); -- The fine-tuned points, each having 2 candidates.
	signal c4: integer_vector(0 to 4 - 1);
	signal i: natural; -- Index of `p4` and `c4`.
	signal pb, pe, addr_offset, ped: vec_2_p.vec_2_t;
	signal re_qr_edge_finder, we_qr_edge_finder, re_div_2, we_div_2: std_logic;
	type state_t is (Q_0, Q_1, Q_2, Q_3);
	signal state: state_t;
begin
	re_i_fb_controller <= re_i_fb_controller_2;
	process (all) is begin
		if i = 0 or i = 1 then
			pb <= po_save;
			pe <= vec_2_p."+"(po_save, dxo_save) when i = 0 else vec_2_p."-"(po_save, dxo_save);
			addr_offset <= dyo_save;
		else
			pb <= po2_save;
			pe <= vec_2_p."+"(po2_save, dyo2_save) when i = 2 else vec_2_p."-"(po2_save, dyo2_save);
			addr_offset <= dxo2_save;
		end if;
	end process;
	qr_edge_finder_i: entity qr_edge_finder port map (
		rst => rst, clk => clk,
		pb => pb, pe => pe,
		addr_offset => addr_offset,
		re_qr_edge_finder => re_qr_edge_finder,
		addr_o => addr_o,
		addr_i => addr_i,
		px => px,
		re_i_fb_controller => re_i_fb_controller_2,
		re_o_fb_controller => re_o_fb_controller,
		ped => ped,
		we => we_qr_edge_finder
	);
	
	div_2_dyo_i: entity div_2 port map (
		rst => rst, clk => clk,
		l => dyo_new,
		r => vec_2_p.to_tp_t(MUL),
		re => re_div_2,
		o => dyo_2,
		we => we_div_2
	);
	div_2_dxo2_i: entity div_2 port map (
		rst => rst, clk => clk,
		l => dxo2_new,
		r => vec_2_p.to_tp_t(MUL),
		re => re_div_2,
		o => dxo2_2,
		we => open
	);
	
	process (all) is
		variable p4_won: vec_2_p.vec_2_t_array_t(0 to 2 - 1); -- The won candidates.
	begin
		if rising_edge(clk) then
			we <= '0'; -- Default value.
			re_qr_edge_finder <= '0'; -- Default value.
			re_div_2 <= '0'; -- Default value.
			if rst = '1' then
				state <= Q_0;
			elsif re_qr_fine_tuner = '1' and state = Q_0 then -- No interrupt other than `rst`.
				state <= Q_1;
				po_save <= po;
				po2_save <= po2;
				dyo_save <= vec_2_p."*"(dyo_i, MUL);
				dxo2_save <= vec_2_p."*"(dxo2_i, MUL);
				dxo_save <= dxo;
				dyo2_save <= dyo2;
				c4 <= (others => 0);
				i <= 0;
				re_qr_edge_finder <= '1';
			elsif state = Q_1 and re_i_fb_controller_2 = '1' then -- `qr_edge_finder_i` has started.
				state <= Q_2;
			elsif state = Q_2 then
				if we_qr_edge_finder = '1' or re_i_fb_controller_2 = '0' then
					p4(i) <= ped;
					if i = 3 then
						state <= Q_3;
						p4_won(0) := p4(0) when c4(0) < c4(1) else p4(1);
						p4_won(1) := p4(2) when c4(2) < c4(3) else ped; -- The last candidate will be missed otherwise.
						dyo_new <= vec_2_p."-"(p4_won(0), po_save);
						dxo2_new <= vec_2_p."-"(p4_won(1), po2_save);
						re_div_2 <= '1';
					else
						state <= Q_1;
						i <= i + 1;
						re_qr_edge_finder <= '1';
					end if;
				else
					c4(i) <= c4(i) + 1;
				end if;
			elsif state = Q_3 and we_div_2 = '1' then
				state <= Q_0;
				dyo_o <= dyo_2;
				dxo2_o <= dxo2_2;
				we <= '1';
			end if;
		end if;
	end process;
end architecture;
