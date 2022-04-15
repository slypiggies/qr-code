library ieee; use ieee.all, work.all;
use std_logic_1164.all, helper.all, helper_tb.all;

use numeric_std.all;

entity tmp3 is
	port (rst, clk: in std_logic);
end entity;

architecture tmp3 of tmp3 is
	signal bmp_header: character_array_t(0 to BMP_HEADER_LEN - 1);
	signal ed_h_2, ed_v_2, processed, ed_2: boolean := false;
	signal addr_r_h, addr_r_v, addr_w: unsigned(ADDR_LEN - 1 downto 0);
	signal pixel_r_h, pixel_r_v, pixel_r, pixel_r2,pixel_r3,pixel_r4,pixel_r5, pixel_w: unsigned(PX_LEN - 1 downto 0);
	signal p_h, p_v, addr_o, addr_o2,addr_o3,addr_o4,addr_o5: vec_2_p.vec_2_t;
	signal px_h, px_v, px_r, px_r2,px_r3,px_r4,px_r5: px_t;
	signal ed, we_h, we_v, we_2: std_logic := '0';
	signal
		we_qr_inner_corners_finder,
		we_qr_outer_corners_finder,
		we_qr_point_a2_calc,
		we_qr_fine_tuner_pa,
		we_qr_fine_tuner_po,
		we_qr_fine_tuner_po2,
		we_qr_extractor,
		ed_qr_extractor
	: std_logic := '0';
	signal ep_h, ep_v, ep: vec_2_p.ep_t;
	signal pa, po, po2, pa_2, po_2, po2_2, pa2: vec_2_p.vec_2_t;
	signal dx_a, dy_a, dx_o, dy_o, dx_o2, dy_o2, dxa, dya, dxo, dyo, dxo2, dyo2, dxo_123,dyo2_123: vec_2_p.vec_2_t;
	signal re_i_fb_controller, re_i_fb_controller2, re_i_fb_controller3, re_i_fb_controller4: std_logic;
	signal diu,ghi: std_logic := '1';
	signal abc: integer:=0;
begin
	fake_frame_buffer_in_h_i: entity fake_frame_buffer_in generic map (
		BMP_FILE_NAME => BMP_FILENAME_R,
--		DELAY => BRAM_R_DELAY -- To mimic real block RAM.
		DELAY => 0
	) port map (
		clk => clk,
		bmp_header => bmp_header,
		ed => ed_h_2,
		addr => unsigned(vec_2_p.to_std_logic_vector(p_h)),
--		addr => addr_r_h,
		pixel => pixel_r_h
	);
	fake_frame_buffer_in_v_i: entity fake_frame_buffer_in generic map (
		BMP_FILE_NAME => BMP_FILENAME_R,
--		DELAY => BRAM_R_DELAY -- To mimic real block RAM.
		DELAY => 0
	) port map (
		clk => clk,
		bmp_header => open,
		ed => ed_v_2,
		addr => unsigned(vec_2_p.to_std_logic_vector(p_v)),
--		addr => addr_r_v,
		pixel => pixel_r_v
	);
	fake_frame_buffer_in_i: entity fake_frame_buffer_in generic map (
		BMP_FILE_NAME => BMP_FILENAME_R,
--		DELAY => BRAM_R_DELAY -- To mimic real block RAM.
		DELAY => 0
	) port map (
		clk => clk,
		bmp_header => open,
		ed => open,
		addr => maximum(minimum(unsigned(vec_2_p.to_std_logic_vector(addr_o)),640*480-1),0),
		pixel => pixel_r
	);
	fake_frame_buffer_in_i2: entity fake_frame_buffer_in generic map (
		BMP_FILE_NAME => BMP_FILENAME_R,
--		DELAY => BRAM_R_DELAY -- To mimic real block RAM.
		DELAY => 0
	) port map (
		clk => clk,
		bmp_header => open,
		ed => open,
		addr => maximum(minimum(unsigned(vec_2_p.to_std_logic_vector(addr_o2)),640*480-1),0),
		pixel => pixel_r2
	);
	fake_frame_buffer_in_i3: entity fake_frame_buffer_in generic map (
		BMP_FILE_NAME => BMP_FILENAME_R,
--		DELAY => BRAM_R_DELAY -- To mimic real block RAM.
		DELAY => 0
	) port map (
		clk => clk,
		bmp_header => open,
		ed => open,
		addr => maximum(minimum(unsigned(vec_2_p.to_std_logic_vector(addr_o3)),640*480-1),0),
		pixel => pixel_r3
	);
	fake_frame_buffer_in_i4: entity fake_frame_buffer_in generic map (
		BMP_FILE_NAME => BMP_FILENAME_R,
--		DELAY => BRAM_R_DELAY -- To mimic real block RAM.
		DELAY => 0
	) port map (
		clk => clk,
		bmp_header => open,
		ed => open,
		addr => maximum(minimum(unsigned(vec_2_p.to_std_logic_vector(addr_o4)),640*480-1),0),
		pixel => pixel_r4
	);
	fake_frame_buffer_in_extract: entity fake_frame_buffer_in generic map (
		BMP_FILE_NAME => BMP_FILENAME_R,
--		DELAY => BRAM_R_DELAY -- To mimic real block RAM.
		DELAY => 0
	) port map (
		clk => clk,
		bmp_header => open,
		ed => open,
		addr => maximum(minimum(unsigned(vec_2_p.to_std_logic_vector(addr_o5)),640*480-1),0),
		pixel => pixel_r5
	);
	px_h <= to_px_t(std_logic_vector(pixel_r_h));
	px_v <= to_px_t(std_logic_vector(pixel_r_v));
	px_r <= to_px_t(std_logic_vector(pixel_r));
	px_r2 <= to_px_t(std_logic_vector(pixel_r2));
	px_r3 <= to_px_t(std_logic_vector(pixel_r3));
	px_r4 <= to_px_t(std_logic_vector(pixel_r4));
	px_r5 <= to_px_t(std_logic_vector(pixel_r5));
	process (all) is
		variable p_h_new, p_v_new: vec_2_p.vec_2_t;
	begin
		if rising_edge(clk) then
			if rst = '1' then
				p_h <= vec_2_p.VEC_2_T_ZERO;
				p_v <= vec_2_p.VEC_2_T_ZERO;
			else
				p_h_new := vec_2_p.inc_h(p_h, vec_2_p.to_vec_2_t(H, V));
				p_v_new := vec_2_p.inc_v(p_v, vec_2_p.to_vec_2_t(H, V));
				p_h <= p_h_new;
				p_v <= p_v_new;
				if vec_2_p."="(p_h_new, vec_2_p.VEC_2_T_ZERO) and vec_2_p."="(p_v_new, vec_2_p.VEC_2_T_ZERO) then -- reminder:wrong
					ed <= '1';
				else
					ed <= '0';
				end if;
			end if;
		end if;
	end process;
	
	qr_preprocessor_h_i: entity qr_preprocessor generic map (
		UNIT_VEC => vec_2_p.H_CAP
	) port map (
		rst => rst, clk => clk,
		addr => p_h,
		px => px_h,
		re => '1',
		ed => ed,
		ep => ep_h,
		we => we_h
	);
	qr_preprocessor_v_i: entity qr_preprocessor generic map (
		UNIT_VEC => vec_2_p.V_CAP
	) port map (
		rst => rst, clk => clk,
		addr => p_v,
		px => px_v,
		re => '1',
		ed => ed,
		ep => ep_v,
		we => we_v
	);
	
	ep <= vec_2_p.arb(ep_h, ep_v);
	
	qr_inner_corners_finder_i: entity qr_inner_corners_finder port map (
		rst => rst, clk => clk,
		ep => ep,
		re => we_h and we_v,
		pa => pa, po => po, po2 => po2,
		we => we_qr_inner_corners_finder
	);
	
	qr_outer_corners_finder_i: entity qr_outer_corners_finder port map (
		rst => rst, clk => clk,
		pa_i => pa, po_i => po, po2_i => po2,
		re_qr_outer_corners_finder => we_qr_inner_corners_finder,
		addr_o => addr_o,
		addr_i => addr_o,
		px => px_r,
		re_i_fb_controller => re_i_fb_controller,
		re_o_fb_controller => re_i_fb_controller,
		pa_o => pa_2, po_o => po_2, po2_o => po2_2,
		dxa => dx_a, dya => dy_a, dxo => dx_o, dyo => dy_o, dxo2 => dx_o2, dyo2 => dy_o2,
		we => we_qr_outer_corners_finder
	);
	
	qr_fine_tuner_pa_i: entity qr_fine_tuner port map (
		rst => rst, clk => clk,
		po => pa_2, po2 => pa_2,
		dyo_i => dx_a, dxo2_i => dy_a,
		dxo => dy_a, dyo2 => dx_a,
		re_qr_fine_tuner => we_qr_outer_corners_finder,
		addr_o => addr_o2,
		addr_i => addr_o2,
		px => px_r2,
		re_i_fb_controller => re_i_fb_controller2,
		re_o_fb_controller => re_i_fb_controller2,
		dyo_o => dxa, dxo2_o => dya,
		we => we_qr_fine_tuner_pa
	);
	qr_fine_tuner_po_i: entity qr_fine_tuner port map (
		rst => rst, clk => clk,
		po => po_2, po2 => po_2,
		dyo_i => vec_2_p."-"(dx_o), dxo2_i => dy_o,
		dxo => dy_o, dyo2 => dx_o,
		re_qr_fine_tuner => we_qr_outer_corners_finder,
		addr_o => addr_o3,
		addr_i => addr_o3,
		px => px_r3,
		re_i_fb_controller => re_i_fb_controller3,
		re_o_fb_controller => re_i_fb_controller3,
		dyo_o => dxo_123, dxo2_o => dyo,
		we => we_qr_fine_tuner_po
	);dxo<=vec_2_p."-"(dxo_123);
	qr_fine_tuner_po2_i: entity qr_fine_tuner port map (
		rst => rst, clk => clk,
		po => po2_2, po2 => po2_2,
		dyo_i => dx_o2, dxo2_i => vec_2_p."-"(dy_o2),
		dxo => dy_o2, dyo2 => dx_o2,
		re_qr_fine_tuner => we_qr_outer_corners_finder,
		addr_o => addr_o4,
		addr_i => addr_o4,
		px => px_r4,
		re_i_fb_controller => re_i_fb_controller4,
		re_o_fb_controller => re_i_fb_controller4,
		dyo_o => dxo2, dxo2_o => dyo2_123,
		we => we_qr_fine_tuner_po2
	);dyo2<=vec_2_p."-"(dyo2_123);
	
--	qr_fine_tuner_i: entity qr_fine_tuner port map (
--		rst => rst, clk => clk,
--		po => po_2, po2 => po2_2,
--		dyo_i => dy_o, dxo2_i => dx_o2,
--		dxo => dx_o, dyo2 => dy_o2,
--		re_qr_fine_tuner => we_qr_outer_corners_finder,
--		addr_o => addr_o2,
--		addr_i => addr_o2,
--		px => px_r2,
--		re_i_fb_controller => re_i_fb_controller2,
--		re_o_fb_controller => re_i_fb_controller2,
--		dyo_o => dyo, dxo2_o => dxo2,
--		we => we_qr_fine_tuner
--	);
	
	-- TODO: bug: need to save fine-tuned stuff somewhere, because `we` is only 1 cycle
	qr_extractor_i: entity qr_extractor port map (
		rst => rst, clk => clk,
		pa => pa_2, po => po_2, po2 => po2_2,
		dxa => dxa, dya => dya,
		dxo => dxo, dyo => dyo,
		dxo2 => dxo2, dyo2 => dyo2,
		n => 33,
		re => ghi,
		addr => pa2,
		we => we_qr_extractor,
		ed => ed_qr_extractor
	);
	
--	qr_point_a2_calc_i: entity qr_point_a2_calc port map (
--		rst => rst, clk => clk,
--		po => po_2, po2 => po2_2,
--		dyo => dyo, dxo2 => dxo2,
--		re => we_qr_fine_tuner,
--		pa2 => pa2,
--		we => we_qr_point_a2_calc
--	);
	
--	px_r <= PX_T_BL when vec_2_p.to_natural(addr_o) mod 4 = 0 or vec_2_p.to_natural(addr_o) mod 4 = 1 else PX_T_WH;
--	process is begin wait for 20 ns; diu <= '0'; wait; end process;
--	qr_edge_finder_i: entity qr_edge_finder generic map (N => 2) port map (
--		rst => rst, clk => clk,
--		pb => vec_2_p.to_vec_2_t(40, 40), pe => vec_2_p.to_vec_2_t(10, 10),
--		addr_offset => vec_2_p.to_vec_2_t(2, -1),
--		re_qr_edge_finder => diu,
--		addr_o => addr_o,
--		addr_i => addr_o,
--		px => px_r,
--		re_i_fb_controller => re_i_fb_controller,
--		re_o_fb_controller => re_i_fb_controller,
--		ped => open,
--		we => open
--	);
	
	fake_frame_buffer_out_i: entity fake_frame_buffer_out generic map (
		BMP_FILE_NAME => BMP_FILENAME_W
	) port map (
		bmp_header => bmp_header,
		processed => processed,
		we => we_2,
		addr => addr_w,
		pixel => pixel_w,
		ed => ed_2
	);
	
--	bresenham_i: entity bresenham generic map (DIR_MUL => -1) port map (
--		rst => rst, clk => clk,
--		pb => vec_2_p.to_vec_2_t(11, 5),
--		pe => vec_2_p.to_vec_2_t(1, 1),
--		re => '1',
--		pi => open,
--		we => open
--	);
	
--	div_i: entity div port map (
--		rst => rst, clk => clk,
--		l => vec_2_p.to_tp_t(-146.25), r => vec_2_p.to_tp_t(234),
--		re => '1',
--		o => open,
--		we => open
--	);
	
--	section_calc_i: entity section_calc port map (
--		rst => rst, clk => clk,
--		pb => vec_2_p.to_vec_2_t(2, 11),
--		pe => vec_2_p.to_vec_2_t(8, 5),
--		m => vec_2_p.to_tp_t(2),
--		n => vec_2_p.to_tp_t(1),
--		re => '1',
--		pi => open,
--		we => open
--	);
	
--	interpolator_i: entity interpolator port map (
--		rst => rst, clk => clk,
--		l => vec_2_p.to_tp_t(7),
--		r => vec_2_p.to_tp_t(3),
--		l_val => vec_2_p.to_tp_t(15),
--		r_val => vec_2_p.to_tp_t(35),
--		target => vec_2_p.to_tp_t(6),
--		re => '1',
--		target_val => open,
--		we => open
--	);
	
	--n=33
	
	process (clk) is variable def:integer; begin
		if rising_edge(clk) then
			def:=0;
			if we_qr_fine_tuner_pa='1' then def:=def+1; end if;
			if we_qr_fine_tuner_po='1' then def:=def+1; end if;
			if we_qr_fine_tuner_po2='1' then def:=def+1; end if;
			abc<=abc+def;
		end if;
	end process;
	ghi<='1' when abc=3 else '0';
	
	process is begin
		wait for 1 ps; -- Wait for reading the file.
		assert ed_h_2 and ed_v_2 severity failure;
		wait until rising_edge(clk) and abc=3;
		report ">> !";
		we_2 <= '1';
		pixel_w <= (others => '1');
--		for i in 0 to 639 loop
--			for j in 0 to 479 loop
--				addr_w<=to_unsigned(j*640+i,addr_w'length);wait for 1 ps;
--			end loop;
--		end loop;
		
		for i in 1 to 33 loop
			for j in 1 to 33 loop
				wait until rising_edge(clk) and we_qr_extractor = '1';
--				addr_o5<=pa2; wait for 1 ps;
--				pixel_w<=pixel_r5;
--				addr_w <= to_unsigned(i*640+j, addr_w'length); wait for 1 ps;
				addr_w <= to_unsigned(vec_2_p.to_natural(pa2), addr_w'length); wait for 1 ps;
			end loop;
		end loop;
		
--		addr_w <= to_unsigned(vec_2_p.to_natural(pa), addr_w'length); wait for 1 ps;
--		addr_w <= to_unsigned(vec_2_p.to_natural(po), addr_w'length); wait for 1 ps;
--		addr_w <= to_unsigned(vec_2_p.to_natural(po2), addr_w'length); wait for 1 ps;
		
--		report ">> !!";
--		addr_w <= to_unsigned(vec_2_p.to_natural(pa_2), addr_w'length); wait for 1 ps;
--		addr_w <= to_unsigned(vec_2_p.to_natural(vec_2_p."+"(pa_2, dxa)), addr_w'length); wait for 1 ps;
--		addr_w <= to_unsigned(vec_2_p.to_natural(vec_2_p."+"(pa_2, dya)), addr_w'length); wait for 1 ps;
		
--		report ">> !!!";
--		addr_w <= to_unsigned(vec_2_p.to_natural(po_2), addr_w'length); wait for 1 ps;
--		addr_w <= to_unsigned(vec_2_p.to_natural(vec_2_p."+"(po_2, dxo)), addr_w'length); wait for 1 ps;
--		addr_w <= to_unsigned(vec_2_p.to_natural(vec_2_p."+"(po_2, dyo)), addr_w'length); wait for 1 ps;
----		for i in 1 to 25 loop
----		addr_w <= to_unsigned(vec_2_p.to_natural(vec_2_p."+"(po_2, vec_2_p."*"(dyo, i))), addr_w'length); wait for 1 ps;
----		end loop;
----		addr_w <= to_unsigned(vec_2_p.to_natural(vec_2_p."+"(po_2, vec_2_p."*"(vec_2_p."-"(vec_2_p.to_vec_2_t(459,480-218), po_2), 5))), addr_w'length); wait for 1 ps;
		
--		report ">> !!!!";
--		addr_w <= to_unsigned(vec_2_p.to_natural(po2_2), addr_w'length); wait for 1 ps;
--		addr_w <= to_unsigned(vec_2_p.to_natural(vec_2_p."+"(po2_2, dxo2)), addr_w'length); wait for 1 ps;
--		addr_w <= to_unsigned(vec_2_p.to_natural(vec_2_p."+"(po2_2, dyo2)), addr_w'length); wait for 1 ps;
----		for i in 1 to 25 loop
----		addr_w <= to_unsigned(vec_2_p.to_natural(vec_2_p."+"(po2_2, vec_2_p."*"(dxo2, i))), addr_w'length); wait for 1 ps;
----		end loop;
		
----		report ">> !!!!!";
----		addr_w <= to_unsigned(vec_2_p.to_natural(pa2), addr_w'length); wait for 1 ps;
		
		processed <= true;
		wait for 1 ps; -- Wait for writing the file.
		assert ed_2 severity failure;
		report ">> RAP";
		wait;
	end process;
end architecture;
