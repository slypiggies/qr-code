library ieee;
use ieee.all;
use numeric_std.all;
use work.all;
use helper_tb.all;
use helper.all;

entity fake_frame_buffer_y_in is
	generic (
		BMP_FILE: string
	);
	port (
		bmp_header: out character_array_t(0 to BMP_HEADER_LENGTH - 1);
		rx_ed: out boolean;
		addr: in unsigned(ADDR_LENGTH - 1 downto 0);
		pixel: out unsigned(PIXEL_LENGTH - 1 downto 0)
	);
end entity;

architecture fake_frame_buffer_y_in_a of fake_frame_buffer_y_in is
	signal pixels: character_array_t(0 to H * V - 1);
	signal pixel_2: unsigned(7 downto 0);
begin
	assert addr < to_unsigned(H * V, addr'length) severity warning; -- May occur in the beginning.
	pixel_2 <= to_unsigned(character'pos(pixels(to_integer(addr))), pixel_2'length); 
	pixel <= pixel_2(pixel_2'left downto pixel_2'left - PIXEL_LENGTH + 1);
	
	bmp_reader_i: entity bmp_reader generic map (
		BMP_FILE => BMP_FILE
	) port map (
		bmp_header => bmp_header,
		pixels => pixels,
		rx_ed => rx_ed
	);
end architecture;
