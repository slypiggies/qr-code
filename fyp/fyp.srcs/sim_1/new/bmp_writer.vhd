use std.all;
use textio.all;
use work.all;
use helper_tb.all;
use helper.all;

entity bmp_writer is
	generic (
		FILE_NAME: string
	);
	port (
		header: in character_array_t(0 to BMP_HEADER_LEN - 1);
		processed: in boolean;
		pixels: in character_array_t(0 to H * V - 1);
		ed: out boolean
	);
end entity;

architecture bmp_writer_a of bmp_writer is
	signal ed_2: boolean := false;
begin
	assert H mod 4 = 0 severity failure;
	assert V mod 4 = 0 severity failure;
	
	ed <= ed_2;
	process
		file bmp: file_t;
	begin
		wait until processed;
		file_open(bmp, BMP_PATH & FILE_NAME & BMP_FILE_EXTENSION, write_mode);
		for i in header'range loop
			write(bmp, header(i));
		end loop;
		for i in pixels'range loop
			write(bmp, pixels(i));
			write(bmp, pixels(i));
			write(bmp, pixels(i));
		end loop;
		ed_2 <= true;
		file_close(bmp);
		wait;
	end process;
end architecture;
