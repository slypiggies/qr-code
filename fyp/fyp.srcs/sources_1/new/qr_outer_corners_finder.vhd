library ieee; use ieee.all, work.all;
use std_logic_1164.all, helper.all;

entity qr_outer_corners_finder is
	port (
		rst, clk: in std_logic;
		pa_i, po_i, po2_i: in vec_2_p.vec_2_t; -- Inner point A (upper-left), O (lower-left) and O2 (upper-right). A2 is discarded.
		re_qr_outer_corners_finder: in std_logic;
		addr_o: out vec_2_p.vec_2_t;
		addr_i: in vec_2_p.vec_2_t;
		px: in px_t;
		re_i_fb_controller: out std_logic;
		re_o_fb_controller: in std_logic;
		pa_o, po_o, po2_o: out vec_2_p.vec_2_t; -- Outer point A, O and O2.
		dxa, dya, dxo, dyo, dxo2, dyo2: out vec_2_p.vec_2_t; -- DX and DY at point A, O and O2.
		we: out std_logic
	);
end entity;

architecture qr_outer_corners_finder of qr_outer_corners_finder is
	signal pa_save, po_save, po2_save: vec_2_p.vec_2_t;
	signal p6: vec_2_p.vec_2_t_array_t(0 to 6 - 1); -- The 6 points are:
		-- outer A along x-axis, outer A along y-axis,
		-- outer O along x-axis, outer O,
		-- outer O2, and outer O2 along y-axis.
	signal p6_index: natural;
	signal pb, pe, ped: vec_2_p.vec_2_t;
	signal re_qr_edge_finder, we_qr_edge_finder: std_logic;
	function subtract_div_2(l, r: vec_2_p.vec_2_t) return vec_2_p.vec_2_t is begin
		return vec_2_p.shift_right(vec_2_p."-"(l, r), 1);
	end function;
	signal state: std_logic;
begin
	pa_o <= vec_2_p."+"(p6(0), vec_2_p."-"(p6(1), pa_save));
	po_o <= p6(3);
	po2_o <= p6(4);
	dxa <= subtract_div_2(pa_save, p6(0));
	dya <= subtract_div_2(pa_save, p6(1));
	dxo <= subtract_div_2(p6(2), po_save);
	dyo <= subtract_div_2(p6(2), p6(3));
	dxo2 <= subtract_div_2(p6(5), p6(4));
	dyo2 <= subtract_div_2(p6(5), po2_save); 
	
	process (all) is begin
		if p6_index = 0 then
			pb <= pa_save; pe <= po_save;
		elsif p6_index = 1 then
			pb <= pa_save; pe <= po2_save;
		elsif p6_index = 2 then
			pb <= po_save; pe <= pa_save;
		elsif p6_index = 3 then
			pb <= po_save; pe <= po2_save;
		elsif p6_index = 4 then
			pb <= po2_save; pe <= po_save;
		else
			pb <= po2_save; pe <= pa_save;
		end if;
	end process;
	qr_edge_finder_i: entity qr_edge_finder generic map (N => 3, DIR_MUL => -1) port map (
		rst => rst, clk => clk,
		pb => pb, pe => pe,
		re_qr_edge_finder => re_qr_edge_finder,
		addr_o => addr_o,
		addr_i => addr_i,
		px => px,
		re_i_fb_controller => re_i_fb_controller,
		re_o_fb_controller => re_o_fb_controller,
		ped => ped,
		we => we_qr_edge_finder
	);
	
	process (all) is begin
		if rising_edge(clk) then
			we <= '0'; -- Default value.
			re_qr_edge_finder <= '0'; -- Default value.
			if rst = '1' then
				state <= '0';
			elsif re_qr_outer_corners_finder = '1' and state = '0' then -- No interrupt other than `rst`.
				state <= '1';
				pa_save <= pa_i;
				po_save <= po_i;
				po2_save <= po2_i;
				p6_index <= 0;
				re_qr_edge_finder <= '1';
			elsif state = '1' then
				if we_qr_edge_finder = '1' then
					p6(p6_index) <= ped;
					if p6_index = 5 then
						state <= '0';
						we <= '1';
					else
						p6_index <= p6_index + 1;
						re_qr_edge_finder <= '1';
					end if;
				end if;
			end if;
		end if;
	end process;
end architecture;
