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
		addr: out unsigned(ADDR_LENGTH - 1 downto 0);
		pixel: in unsigned(PIXEL_LENGTH - 1 downto 0);
		h_cnt, v_cnt: out unsigned(ADDR_LENGTH - 1 downto 0);
		cnt: out unsigned(ADDR_LENGTH - 1 downto 0);
		we: out std_logic
	);
end entity;

architecture aggregator_a of aggregator is
	signal addr_2: unsigned(addr'range);
	signal h_cnt_2, h_cnt_3: unsigned(h_cnt'range);
	signal v_cnt_2, v_cnt_3: unsigned(v_cnt'range);
	signal we_h_cnt, we_v_cnt: std_logic;
	signal h_cnt_save: unsigned(h_cnt'range);
	signal v_cnt_save: unsigned(v_cnt'range);
	signal pixel_save: unsigned(pixel'range);
	signal cnt_2: unsigned(cnt'range);
	signal first_pixel: std_logic;
begin
	delayer_h_i: entity delayer generic map (
		DELAY => FRAME_BUFFER_DELAY,
		LENGTH => h_cnt_2'length
	) port map (
		reset => reset,
		clk => clk,
		i => h_cnt_2,
		o => h_cnt_3,
		we => we_h_cnt
	);
	delayer_v_i: entity delayer generic map (
		DELAY => FRAME_BUFFER_DELAY,
		LENGTH => v_cnt_2'length
	) port map (
		reset => reset,
		clk => clk,
		i => v_cnt_2,
		o => v_cnt_3,
		we => we_v_cnt
	);
	
	addr <= addr_2;
	process (all) begin
		if reset = '1' then
			addr_2 <= (others => '0');
			h_cnt_2 <= (others => '0');
			v_cnt_2 <= (others => '0');
			we <= '0';
			first_pixel <= '1';
		elsif rising_edge(clk) then
			if h_cnt_2 < to_unsigned(H - 1, h_cnt_2'length) then
				addr_2 <= addr_2 + 1;
				h_cnt_2 <= h_cnt_2 + 1;
			else
				h_cnt_2 <= (others => '0');
				if v_cnt_2 < to_unsigned(V - 1, v_cnt_2'length) then
					addr_2 <= addr_2 + 1;
					v_cnt_2 <= v_cnt_2 + 1;
				else
					addr_2 <= (others => '0');
					v_cnt_2 <= (others => '0');
				end if;
			end if;
			-- Starting from here, use `h_cnt_3` and `v_cnt_3`.
			
			we <= '0'; -- Default value.
			if we_h_cnt = '1' then -- `we_v_cnt` is the same as `we_h_cnt`.
				if h_cnt_3 = to_unsigned(0, h_cnt_3'length) or pixel /= pixel_save then
					h_cnt_save <= h_cnt_3;
					v_cnt_save <= v_cnt_3;
					pixel_save <= pixel;
					cnt_2 <= to_unsigned(1, cnt_2'length);
					-- The first pixel from the first frame should not trigger `we`.
					if first_pixel = '0' then
						h_cnt <= h_cnt_save;
						v_cnt <= v_cnt_save;
						cnt <= cnt_2;
						we <= '1';
					else
						first_pixel <= '0';
					end if;
				else
					cnt_2 <= cnt_2 + 1;
				end if;
			end if;
		end if;
	end process;
end architecture;
