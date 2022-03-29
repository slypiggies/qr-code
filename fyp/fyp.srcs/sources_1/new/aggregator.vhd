library ieee;
use ieee.all;
use std_logic_1164.all;
use numeric_std.all;
use work.all;
use helper.all;

entity aggregator is
	generic (
		H, V: positive;
		ADDR_LENGTH: positive
	);
	port (
		reset, clk: in std_logic;
		h_cnt, v_cnt: in unsigned(ADDR_LENGTH - 1 downto 0);
		we_cnt: in std_logic;
		pixel: in unsigned(PIXEL_LENGTH - 1 downto 0);
		h_cnt_begin, v_cnt_begin: out unsigned(ADDR_LENGTH - 1 downto 0);
		cnt: out unsigned(ADDR_LENGTH - 1 downto 0);
		we: out std_logic;
		eof: out std_logic -- End of frame.
	);
end entity;

architecture aggregator_a of aggregator is
	signal h_cnt_save: unsigned(h_cnt'range);
	signal v_cnt_save: unsigned(v_cnt'range);
	signal pixel_save: unsigned(pixel'range);
	signal cnt_2: unsigned(cnt'range);
	signal first_pixel: std_logic;
begin
	
	process (all) begin
		if reset = '1' then
			we <= '0';
			eof <= '0';
			first_pixel <= '1';
		elsif rising_edge(clk) then
			we <= '0'; -- Default value.
			eof <= '0'; -- Default value.
			if we_cnt = '1' then
				if h_cnt = to_unsigned(0, h_cnt'length) or pixel /= pixel_save then
					h_cnt_save <= h_cnt;
					v_cnt_save <= v_cnt;
					pixel_save <= pixel;
					cnt_2 <= to_unsigned(1, cnt_2'length);
					-- The first pixel from the first frame should not trigger `we`.
					if first_pixel = '0' then
						h_cnt_begin <= h_cnt_save;
						v_cnt_begin <= v_cnt_save;
						cnt <= cnt_2;
						we <= '1';
					else
						first_pixel <= '0';
					end if;
				else
					cnt_2 <= cnt_2 + 1;
				end if;
				if h_cnt = to_unsigned(0, h_cnt'length) and v_cnt = to_unsigned(0, v_cnt'length) then
					eof <= '1';
				end if;
			end if;
		end if;
	end process;
end architecture;
