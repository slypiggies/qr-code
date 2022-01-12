use std.textio.all;
library work;
use work.helper_tb.all;

entity bmp_reader is
	generic (
		H, V: natural;
		ADDR_LENGTH: natural;
		PIXEL_LENGTH: natural;
		HEADER_LENGTH: natural;
		PATH_PREFIX: string
	);
	port (
		header: out character_array_t(0 to HEADER_LENGTH - 1);
		pixels: out character_array_t(0 to H * V - 1);
		rx_ed: out boolean
	);
end entity;

architecture bmp_reader_a of bmp_reader is
	signal rx_ed_2: boolean := false;
begin
	assert H mod 4 = 0 severity failure;
	assert V mod 4 = 0 severity failure;
	
	rx_ed <= rx_ed_2;
	process
		file bmp: file_t open read_mode is PATH_PREFIX & "/in.bmp";
		function to_natural(bytes: character_array_t(0 to 3)) return natural is begin
			return
				character'pos(bytes(0)) +
				character'pos(bytes(1)) * 2 ** 8 +
				character'pos(bytes(2)) * 2 ** 16 +
				character'pos(bytes(3)) * 2 ** 24;
		end function;
		function to_natural_2(bytes: character_array_t(0 to 1)) return natural is begin
			return to_natural(bytes & character'val(0) & character'val(0));
		end function;
		variable tmp: character;
	begin
		for i in header'range loop
			read(bmp, header(i));
		end loop;
		assert
			header(0 to 1) = "BM" and
			to_natural(header(2 to 5)) = 54 + H * V * 3 and
			to_natural(header(10 to 13)) = 54 and
			to_natural(header(14 to 17)) = 40 and
			to_natural(header(18 to 21)) = H and
			to_natural(header(22 to 25)) = V and
			to_natural_2(header(26 to 27)) = 1 and
			to_natural_2(header(28 to 29)) = 24 and
			to_natural(header(30 to 33)) = 0 and
			to_natural(header(34 to 37)) = H * V * 3 and
			to_natural(header(46 to 49)) = 0 and
			to_natural(header(50 to 53)) = 0 severity failure;
		for i in pixels'range loop
			read(bmp, pixels(i)); -- B.
			read(bmp, tmp); -- G.
			read(bmp, tmp); -- R.
		end loop;
		rx_ed_2 <= true;
		file_close(bmp);
		wait;
	end process;
end architecture;
