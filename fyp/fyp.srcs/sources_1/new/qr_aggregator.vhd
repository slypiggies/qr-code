library ieee; use ieee.all, work.all;
use std_logic_1164.all, helper.all;

entity qr_aggregator is
	port (
		rst, clk: in std_logic;
		addr: in vec_2_p.vec_2_t;
		px: in px_t;
		re: in std_logic;
		ed_i: in std_logic; -- End of frame. Assumption: if this and `re` are both `'1'`s, `re` will be ignored.
		pb: out vec_2_p.vec_2_t; -- Point Begin.
		cnt: out positive;
		we: out std_logic;
		ed_o: out std_logic
	);
end entity;

architecture qr_aggregator of qr_aggregator is
	signal first_px: std_logic; -- First pixel of the frame.
	signal px_save: px_t;
	signal pb_save: vec_2_p.vec_2_t;
	signal cnt_save: positive;
begin
	process (all) is begin
		if rising_edge(clk) then
			we <= '0'; -- Default value.
			ed_o <= ed_i;
			if rst = '1' or ed_i = '1' then
				first_px <= '1';
			elsif re = '1' then
				first_px <= '0';
				if first_px = '1' or px /= px_save then
					if first_px = '0' then
						pb <= pb_save;
						cnt <= cnt_save;
						we <= '1';
					end if;
					px_save <= px;
					pb_save <= addr;
					cnt_save <= 1;
				else
					cnt_save <= cnt_save + 1;
				end if;
			end if;
		end if;
	end process;
end architecture;
