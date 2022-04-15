library ieee;
use ieee.all;
use std_logic_1164.all;
use numeric_std.all;
use work.all;
use helper_tb.all;
use helper.all;

entity fake_frame_buffer_in is
	generic (
		BMP_FILE_NAME: string;
		DELAY: natural
	);
	port (
		clk: in std_logic;
		bmp_header: out character_array_t(0 to BMP_HEADER_LEN - 1);
		ed: out boolean;
		addr: in unsigned(ADDR_LEN - 1 downto 0);
		pixel: out unsigned(PX_LEN - 1 downto 0)
	);
end entity;

architecture fake_frame_buffer_in_a of fake_frame_buffer_in is
	constant ENABLE_DELAYER: boolean := DELAY > 0;
	signal pixels: character_array_t(0 to H * V - 1);
	signal pixel_2: unsigned(7 downto 0);
	signal pixel_3: unsigned(pixel'range);
begin
	assert not USE_RGB_565 severity failure;
	assert addr < to_unsigned(H * V, addr'length) severity warning; -- May occur in the beginning.
	pixel_2 <= to_unsigned(character'pos(pixels(to_integer(addr))), pixel_2'length); 
	pixel_3 <= pixel_2(pixel_2'left downto pixel_2'left - pixel'length + 1);
	
	ENABLE_DELAYER_if: if ENABLE_DELAYER generate
		delayer_i: entity delayer generic map (
			DELAY => DELAY
		) port map (
			rst => '0',
			clk => clk,
			i => to_integer(pixel_3),
			to_unsigned(o) => pixel,
			we => open
		);
	end generate;
	not_ENABLE_DELAYER_if: if not ENABLE_DELAYER generate
		pixel <= pixel_3;
	end generate;
	
	bmp_reader_i: entity bmp_reader generic map (
		FILE_NAME => BMP_FILE_NAME
	) port map (
		header => bmp_header,
		pixels => pixels,
		ed => ed
	);
end architecture;
