library ieee;
use ieee.all;
use std_logic_1164.all;
use numeric_std.all;
use work.all;
use helper_tb.all;
use helper.all;
use work.all;use point.all;

entity tmp is
	port (
		reset, clk: in std_logic
	);
end entity;

architecture tmp_a of tmp is
	signal bmp_header: character_array_t(0 to BMP_HEADER_LENGTH - 1);
	signal ed, ed_2, processed, ed_3: boolean := false;
	signal addr_r_h, addr_r_v, addr_r, addr_w: unsigned(ADDR_LENGTH - 1 downto 0);
	signal pixel_r_h, pixel_r_v, pixel_r, pixel_w: unsigned(PIXEL_LENGTH - 1 downto 0);
	signal point_h, point_v: point_t;
	signal we_cnt_h, we_cnt_v, we_h, we_v, eof_h, eof_v, we_h_2, we_v_2, eof_h_2, eof_v_2, we_h_3: std_logic;
	signal point_begin_h, point_begin_v: point_t;
	signal cnt_h, cnt_v: unsigned(ADDR_LENGTH - 1 downto 0);
	signal point_13_h, point_31_h, point_13_v, point_31_v: point_t;
	signal extreme_points_h, extreme_points_v, extreme_points: extreme_points_t;
	signal we: std_logic;
	signal we_2: std_logic := '0';
	signal point_begin, point_a, point_o, point_o2: point_t;
	signal asdasd: integer;
begin
	fake_frame_buffer_in_h_i: entity fake_frame_buffer_in generic map (
		BMP_FILE_NAME => BMP_FILE_NAME_R,
		DELAY => BRAM_R_DELAY -- To mimic real block RAM.
	) port map (
		clk => clk,
		bmp_header => bmp_header,
		ed => ed,
		addr => addr_r_h,
		pixel => pixel_r_h
	);
	fake_frame_buffer_in_v_i: entity fake_frame_buffer_in generic map (
		BMP_FILE_NAME => BMP_FILE_NAME_R,
		DELAY => BRAM_R_DELAY
	) port map (
		clk => clk,
		bmp_header => open,
		ed => ed_2,
		addr => addr_r_v,
		pixel => pixel_r_v
	);
	
	frame_buffer_controller_h_i: entity frame_buffer_controller_x generic map (
		H => H,
		V => V,
		ADDR_LENGTH => ADDR_LENGTH
	) port map (
		reset => reset,
		clk => clk,
		addr => addr_r_h,
		h_cnt => point_h.h,
		v_cnt => point_h.v,
		we_cnt => we_cnt_h
	);
	frame_buffer_controller_v_i: entity frame_buffer_controller_y generic map (
		H => H,
		V => V,
		ADDR_LENGTH => ADDR_LENGTH
	) port map (
		reset => reset,
		clk => clk,
		addr => addr_r_v,
		h_cnt => point_v.h,
		v_cnt => point_v.v,
		we_cnt => we_cnt_v
	);
	
	aggregator_h_i: entity aggregator generic map (
		H => H,
		V => V,
		ADDR_LENGTH => ADDR_LENGTH
	) port map (
		reset => reset,
		clk => clk,
		point => point_h,
		we_cnt => we_cnt_h,
		pixel => pixel_r_h,
		point_begin => point_begin_h,
		cnt => cnt_h,
		we => we_h,
		eof => eof_h
	);
	aggregator_v_i: entity aggregator generic map (
		H => H,
		V => V,
		ADDR_LENGTH => ADDR_LENGTH
	) port map (
		reset => reset,
		clk => clk,
		point => point_v,
		we_cnt => we_cnt_v,
		pixel => pixel_r_v,
		point_begin => point_begin_v,
		cnt => cnt_v,
		we => we_v,
		eof => eof_v
	);
	
	scanner_h_i: entity scanner generic map (
		ADDR_LENGTH => ADDR_LENGTH,
		UNIT_MIN => UNIT_MIN,
		UNIT_MAX => UNIT_MAX
	) port map (
		reset => reset,
		clk => clk,
		point_begin => point_begin_h,
		cnt => cnt_h,
		we_cnt => we_h,
		point_13 => point_13_h,
		point_31 => point_31_h,
		we => we_h_2,
		eof_i => eof_h,
		eof_o => eof_h_2
	);
	scanner_v_i: entity scanner generic map (
		ADDR_LENGTH => ADDR_LENGTH,
		UNIT_MIN => UNIT_MIN,
		UNIT_MAX => UNIT_MAX
	) port map (
		reset => reset,
		clk => clk,
		point_begin => point_begin_v,
		cnt => cnt_v,
		we_cnt => we_v,
		point_13 => point_13_v,
		point_31 => point_31_v,
		we => we_v_2,
		eof_i => eof_v,
		eof_o => eof_v_2
	);
	
	filter_h_i: entity filter generic map (
		ADDR_LENGTH => ADDR_LENGTH
	) port map (
		reset => reset,
		clk => clk,
		point_13 => point_13_h,
		point_31 => point_31_h,
		we_cnt => we_h_2,
		extreme_points => extreme_points_h,
		eof => eof_h_2,
		we => we_h_3
	);
	
	filter_v_i: entity filter generic map (
		ADDR_LENGTH => ADDR_LENGTH
	) port map (
		reset => reset,
		clk => clk,
		point_13 => point_13_v,
		point_31 => point_31_v,
		we_cnt => we_v_2,
		extreme_points => extreme_points_v,
		eof => eof_v_2,
		we => open
	);
	
	extreme_points <= arb(extreme_points_h, extreme_points_v);
	
	calc_i: entity calc generic map (
		ADDR_LENGTH => ADDR_LENGTH
	) port map (
		reset => reset,
		clk => clk,
		extreme_points => extreme_points,
		we_cnt => we_h_3,
		point_a => point_a,
		point_o => point_o,
		point_o2 => point_o2,
		we => we
	);
	
	fake_frame_buffer_in_i: entity fake_frame_buffer_in generic map (
		BMP_FILE_NAME => BMP_FILE_NAME_R,
		DELAY => 0
	) port map (
		clk => clk,
		bmp_header => open,
		ed => open,
		addr => addr_r,
		pixel => pixel_r
	);
	
	fake_frame_buffer_out_i: entity fake_frame_buffer_out generic map (
		BMP_FILE_NAME => BMP_FILE_NAME_W
	) port map (
		bmp_header => bmp_header,
		processed => processed,
		we => we_2,
		addr => addr_w,
		pixel => pixel_w,
		ed => ed_3
	);
	
	process
		function to_addr(point: point_t) return unsigned is begin
			report ">> " & integer'image(to_integer(point.h)) & " " & integer'image(to_integer(point.v));
			return to_unsigned(natural(to_integer(point.v)) * H + natural(to_integer(point.h)), ADDR_LENGTH);
		end function;
		
--		constant point_a2:point_t:=(h=>to_unsigned(302,ADDR_LENGTH),v=>to_unsigned(480-413,ADDR_LENGTH));
		constant point_a2:point_t:=(h=>to_unsigned(321,ADDR_LENGTH),v=>to_unsigned(480-390,ADDR_LENGTH));
		function idk(xx,yy:point_t;zz:integer)return point_t is variable xxh,xxv,yyh,yyv,wwh,wwv:integer;begin
			xxh:=to_integer(xx.h);xxv:=to_integer(xx.v);yyh:=to_integer(yy.h);yyv:=to_integer(yy.v);
			wwh:=yyh;wwv:=yyv;wwh:=wwh-xxh;wwv:=wwv-xxv;
			wwh:=wwh*zz/(33-4);wwv:=wwv*zz/(33-4);
			wwh:=wwh+xxh;wwv:=wwv+xxv;
			return (h=>to_unsigned(wwh,ADDR_LENGTH),v=>to_unsigned(wwv,ADDR_LENGTH));
		end function;
		function avg(xx,yy:point_t)return point_t is variable xxh,xxv,yyh,yyv,wwh,wwv:integer;begin
			xxh:=to_integer(xx.h);xxv:=to_integer(xx.v);yyh:=to_integer(yy.h);yyv:=to_integer(yy.v);
			wwh:=(xxh+yyh)/2;wwv:=(xxv+yyv)/2;
			return (h=>to_unsigned(wwh,ADDR_LENGTH),v=>to_unsigned(wwv,ADDR_LENGTH));
		end function;
		variable point_ao,point_o2a2,p1,p2:point_t;
	begin
		wait for 1 ps; -- Wait for reading the file.
		assert ed and ed_2 severity failure;
		wait until rising_edge(clk) and we = '1';
		
		we_2 <= '1';
		pixel_w <= (others => '1');
--		addr_w <= to_addr(extreme_points.min_h); wait for 1 ps;
--		addr_w <= to_addr(extreme_points.max_h); wait for 1 ps;
--		addr_w <= to_addr(extreme_points.min_v); wait for 1 ps;
--		addr_w <= to_addr(extreme_points.max_v); wait for 1 ps;
		
--		addr_w <= to_addr(point_a); wait for 1 ps;
--		addr_w <= to_addr(point_a2); wait for 1 ps; 
--		addr_w <= to_addr(point_o); wait for 1 ps;
--		addr_w <= to_addr(point_o2); wait for 1 ps;
	
		pixel_w<=(others=>'1');
		for jj in 0 to 640-1 loop for kk in 0 to 480-1 loop
			addr_w<=to_addr((h=>to_unsigned(jj,ADDR_LENGTH),v=>to_unsigned(kk,ADDR_LENGTH)));wait for 1 ps;
		end loop; end loop;

		for jj in 1-2 to 33-4+2 loop for kk in 1-2 to 33-4+2 loop
			point_ao:=idk(point_a,point_o,jj-1);point_o2a2:=idk(point_o2,point_a2,jj-1);
			p1:=idk(point_ao,point_o2a2,kk);
			point_ao:=idk(point_a,point_o,jj);point_o2a2:=idk(point_o2,point_a2,jj);
			p2:=idk(point_ao,point_o2a2,kk-1);
--			addr_w<=to_addr(avg(p1,p2));wait for 1 ps;
			addr_r<=to_addr(avg(p1,p2));wait for 1 ps;
			pixel_w<=pixel_r;addr_w<=to_addr((h=>to_unsigned(jj+1,ADDR_LENGTH),v=>to_unsigned(kk+1,ADDR_LENGTH)));wait for 1 ps;
--			addr_w <= to_addr(idk(point_a,point_o,jj)); wait for 1 ps;
--			addr_w <= to_addr(idk(point_o,point_a2,jj)); wait for 1 ps;
--			addr_w <= to_addr(idk(point_a2,point_o2,jj)); wait for 1 ps;
--			addr_w <= to_addr(idk(point_o2,point_a,jj)); wait for 1 ps;
		end loop; end loop;
		
		processed <= true;
		wait for 1 ps; -- Wait for writing the file.
		assert ed_3 severity failure;
		wait;
	end process;
end architecture;
