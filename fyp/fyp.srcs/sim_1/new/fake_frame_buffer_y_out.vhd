library ieee;
use ieee.numeric_std.all;
library work;
use work.helper_tb.all;
use work.all;

entity fake_frame_buffer_y_out is
	generic (
		H, V: natural;
		ADDR_LENGTH: natural;
		PIXEL_LENGTH: natural;
		BMP_HEADER_LENGTH: natural;
		BMP_PATH: string
	);
	port (
		bmp_header: in character_array_t(0 to BMP_HEADER_LENGTH - 1);
		processed: in boolean;
		addr: in unsigned(ADDR_LENGTH - 1 downto 0);
		pixel: in unsigned(PIXEL_LENGTH - 1 downto 0);
		tx_ed: out boolean
	);
end entity;

architecture fake_frame_buffer_y_out_a of fake_frame_buffer_y_out is
	signal pixels: character_array_t(0 to H * V - 1);
begin
	assert addr < to_unsigned(H * V, addr'length) severity warning; -- May occur in the beginning.
	process (addr, pixel) begin -- Does not work for some reason, if 1) `process` is not used, or 2) `addr` is absent, or 3) `all` is used.
		pixels(to_integer(addr)) <= character'val(to_integer(pixel & X"0"));
	end process;
	
	bmp_writer_i: entity bmp_writer generic map (
		H => H,
		V => V,
		ADDR_LENGTH => ADDR_LENGTH,
		PIXEL_LENGTH => PIXEL_LENGTH,
		BMP_HEADER_LENGTH => BMP_HEADER_LENGTH,
		BMP_PATH => BMP_PATH
	) port map (
		bmp_header => bmp_header,
		processed => processed,
		pixels => pixels,
		tx_ed => tx_ed
	);
end architecture;
