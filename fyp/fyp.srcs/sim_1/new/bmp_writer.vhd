use std.textio.all;
library work;
use work.helper_tb.all;

entity bmp_writer is
	generic (
		H, V: natural;
		ADDR_LENGTH: natural;
		PIXEL_LENGTH: natural;
		HEADER_LENGTH: natural;
		PATH_PREFIX: string
	);
	port (
		header: in character_array_t(0 to HEADER_LENGTH - 1);
		processed: in boolean;
		pixels: in character_array_t(0 to H * V - 1);
		tx_ed: out boolean
	);
end entity;

architecture bmp_writer_a of bmp_writer is
	signal tx_ed_2: boolean := false;
begin
	assert H mod 4 = 0 severity failure;
	assert V mod 4 = 0 severity failure;
	
	tx_ed <= tx_ed_2;
	process
		file bmp: file_t open write_mode is PATH_PREFIX & "/out.bmp";
	begin
		wait until processed;
		for i in header'range loop
			write(bmp, header(i));
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
