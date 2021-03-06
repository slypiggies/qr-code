library ieee;
use ieee.all;
use numeric_std.all;
use work.all;
use helper_tb.all;
use helper.all;
use std_logic_1164.all;

entity fake_frame_buffer_out is
	generic (
		BMP_FILE_NAME: string
	);
	port (
		bmp_header: in character_array_t(0 to BMP_HEADER_LEN - 1);
		processed: in boolean;
		we: in std_logic;
		addr: in unsigned(ADDR_LEN - 1 downto 0);
		pixel: in unsigned(PX_LEN - 1 downto 0);
		ed: out boolean
	);
end entity;

architecture fake_frame_buffer_out_a of fake_frame_buffer_out is
	signal pixels: character_array_t(0 to H * V - 1) := (others => character'val(0));
begin
	assert not USE_RGB_565 severity failure;
	assert addr < to_unsigned(H * V, addr'length) severity warning; -- May occur in the beginning.
	process (we, addr, pixel) begin -- Does not work for some reason, if 1) `process` is not used, or 2) `addr` is absent, or 3) `all` is used.
		if we = '1' then
			pixels(to_integer(addr)) <= character'val(to_integer(pixel & (8 - pixel'length downto 1 => pixel(pixel'left))));
				-- `pixel(pixel'left)` instead of `'0'` is for when `pixel'length` is 1.
		end if;
	end process;
	
	bmp_writer_i: entity bmp_writer generic map (
		FILE_NAME => BMP_FILE_NAME
	) port map (
		header => bmp_header,
		processed => processed,
		pixels => pixels,
		ed => ed
	);
end architecture;
