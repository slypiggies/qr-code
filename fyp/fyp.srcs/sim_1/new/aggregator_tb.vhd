library ieee;
use ieee.all;
use std_logic_1164.all;
use numeric_std.all;
use work.all;
use helper_tb.all;
use helper.all;

entity aggregator_tb is
	port (
		reset, clk: std_logic
	);
end entity;

architecture aggregator_tb_a of aggregator_tb is
	signal addr: unsigned(ADDR_LENGTH - 1 downto 0);
	signal pixel, pixel_2: unsigned(PIXEL_LENGTH - 1 downto 0);
	signal h_cnt, v_cnt, cnt: unsigned(ADDR_LENGTH - 1 downto 0);
	signal we: std_logic;
	signal j: natural := 0;
begin
	delayer_i: entity delayer generic map (
		DELAY => FRAME_BUFFER_DELAY,
		LENGTH => PIXEL_LENGTH
	) port map (
		reset => reset,
		clk => clk,
		i => pixel,
		o => pixel_2,
		we => open
	);
	
	aggregator_i: entity aggregator generic map (
		H => H,
		V => V,
		ADDR_LENGTH => ADDR_LENGTH
	) port map (
		reset => reset,
		clk => clk,
		addr => addr,
		pixel => pixel_2,
		h_cnt => h_cnt,
		v_cnt => v_cnt,
		cnt => cnt,
		we => we
	);
	
	process begin
		pixel <= PIXELS_S(j);
		if j = PIXELS_S'length - 1 then
			j <= 0;
		else
			j <= j + 1;
		end if;
		wait until rising_edge(clk);
	end process;
end architecture;
