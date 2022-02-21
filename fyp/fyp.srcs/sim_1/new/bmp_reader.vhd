use std.all;
use textio.all;
use work.all;
use helper_tb.all;

entity bmp_reader is
	generic (
		FILE_NAME: string
	);
	port (
		header: out character_array_t(0 to BMP_HEADER_LENGTH - 1);
		pixels: out character_array_t(0 to H * V - 1);
		ed: out boolean
	);
end entity;

architecture bmp_reader_a of bmp_reader is
	signal ed_2: boolean := false;
begin
	ed <= ed_2;
	process
		file bmp: file_t open read_mode is BMP_PATH_PREFIX & FILE_NAME;
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
		alias bh: character_array_t(header'range) is header;
		variable tmp: character;
	begin
		for i in bh'range loop
			read(bmp, bh(i));
		end loop;
		assert
			bh(0 to 1) = "BM" and
			to_natural(bh(2 to 5)) = BMP_HEADER_LENGTH + H * V * 3 and
			to_natural(bh(10 to 13)) = BMP_HEADER_LENGTH and
			to_natural(bh(14 to 17)) = 40 and
			to_natural(bh(18 to 21)) = H and
			to_natural(bh(22 to 25)) = V and
			to_natural_2(bh(26 to 27)) = 1 and
			to_natural_2(bh(28 to 29)) = 24 and
			to_natural(bh(30 to 33)) = 0 and
			to_natural(bh(34 to 37)) = H * V * 3 and
			to_natural(bh(46 to 49)) = 0 and
			to_natural(bh(50 to 53)) = 0 severity failure;
		for i in pixels'range loop
			read(bmp, pixels(i)); -- B.
			read(bmp, tmp); -- G.
			read(bmp, tmp); -- R.
		end loop;
		ed_2 <= true;
		file_close(bmp);
		wait;
	end process;
end architecture;
