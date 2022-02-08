use std.all;
use textio.all;
use work.all;
use helper_tb.all;

entity bmp_writer is
	generic (
		BMP_FILE: string
	);
	port (
		bmp_header: in character_array_t(0 to BMP_HEADER_LENGTH - 1);
		processed: in boolean;
		pixels: in character_array_t(0 to H * V - 1);
		tx_ed: out boolean
	);
end entity;

architecture bmp_writer_a of bmp_writer is
	signal tx_ed_2: boolean := false;
begin
	tx_ed <= tx_ed_2;
	process
		file bmp: file_t open write_mode is BMP_PATH_PREFIX & BMP_FILE;
	begin
		wait until processed;
		for i in bmp_header'range loop
			write(bmp, bmp_header(i));
		end loop;
		for i in pixels'range loop
			write(bmp, pixels(i));
			write(bmp, pixels(i));
			write(bmp, pixels(i));
		end loop;
		tx_ed_2 <= true;
		file_close(bmp);
		wait;
	end process;
end architecture;
