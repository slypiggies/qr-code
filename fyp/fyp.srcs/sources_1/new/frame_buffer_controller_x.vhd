library ieee;
use ieee.all;
use numeric_std.all;
use std_logic_1164.all;
use work.all;
use helper.all;

entity frame_buffer_controller_x is
	generic (
		H, V: positive;
		ADDR_LENGTH: positive
	);
	port (
		reset, clk: in std_logic;
		addr: out unsigned(ADDR_LENGTH - 1 downto 0);
		h_cnt, v_cnt: out unsigned(ADDR_LENGTH - 1 downto 0);
		we_cnt: out std_logic
	);
end entity;

architecture frame_buffer_controller_x_a of frame_buffer_controller_x is
	signal addr_2: unsigned(addr'range);
	signal h_cnt_2: unsigned(h_cnt'range);
	signal v_cnt_2: unsigned(v_cnt'range);
begin
	delayer_h_i: entity delayer generic map (
		DELAY => BRAM_R_DELAY,
		LENGTH => h_cnt_2'length
	) port map (
		reset => reset,
		clk => clk,
		i => h_cnt_2,
		o => h_cnt,
		we => we_cnt
	);
	delayer_v_i: entity delayer generic map (
		DELAY => BRAM_R_DELAY,
		LENGTH => v_cnt_2'length
	) port map (
		reset => reset,
		clk => clk,
		i => v_cnt_2,
		o => v_cnt,
		we => open
	);
	
	addr <= addr_2;
	process (all) begin
		if reset = '1' then
			addr_2 <= (others => '0');
			h_cnt_2 <= (others => '0');
			v_cnt_2 <= (others => '0');
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
		end if;
	end process;
end architecture;
