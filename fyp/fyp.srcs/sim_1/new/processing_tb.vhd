library ieee;
use ieee.all;
use std_logic_1164.all;
use numeric_std.all;
use work.all;
use helper.all;
use helper_tb.all;

entity processing_tb is
	port (
		reset, clk: in std_logic
	);
end entity;

architecture processing_tb_a of processing_tb is
	signal bmp_header: character_array_t(0 to BMP_HEADER_LENGTH - 1);
	signal ed, processed, ed_2: boolean := false;
	signal addr_r, addr_w: unsigned(ADDR_LENGTH - 1 downto 0);
	signal pixel_r, pixel_w: unsigned(PIXEL_LENGTH - 1 downto 0);
	signal we: std_logic;
begin
	assert H mod 4 = 0 severity failure;
	assert V mod 4 = 0 severity failure;
	assert not USE_RGB565 severity failure;
	
	fake_frame_buffer_y_in_i: entity fake_frame_buffer_y_in generic map (
		BMP_FILE_NAME => BMP_FILE_NAME_R
	) port map (
		bmp_header => bmp_header,
		ed => ed,
		addr => addr_r,
		pixel => pixel_r
	);
	
	sobel_i: entity sobel generic map (
		H => H,
		V => V,
		ADDR_LENGTH => ADDR_LENGTH
	) port map (
		reset => reset,
		clk => clk,
		addr_r => addr_r,
		addr_w => addr_w,
		pixel_r => pixel_r,
		pixel_w => pixel_w,
		we => we
	);
	
	fake_frame_buffer_y_out_i: entity fake_frame_buffer_y_out generic map (
		BMP_FILE_NAME => BMP_FILE_NAME_W
	) port map (
		bmp_header => bmp_header,
		processed => processed,
		addr => addr_w,
		pixel => pixel_w,
		ed => ed_2
	);
	
	process begin
		wait for 1 ps;
		assert ed severity failure;
		for i in 1 to H * V loop
			wait until we = '1';
			wait until we = '0';
		end loop;
		processed <= true;
		wait for 1 ps;
		assert ed_2 severity failure;
		wait;
	end process;
end architecture;
