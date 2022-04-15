library ieee;
use ieee.all;
use std_logic_1164.all;
use numeric_std.all;
use work.all;
use helper_tb.all;
use helper.all;

entity fyp_tb is end entity;

architecture fyp_tb_a of fyp_tb is
	constant PERIOD100: time := 10 ns;
	signal clk100: std_logic := '0';
	signal reset: std_logic := '1';
begin
	check_ASSERTS;
	
	process begin
		wait for PERIOD100 / 2;
		clk100 <= not clk100;
	end process;
	
	process begin
		wait until rising_edge(clk100);
		reset <= '0';
		wait;
	end process;
	
--	ENABLE_OV_SCCB_TB_if: if ENABLE_OV_SCCB_TB generate
--		ov_sccb_tb_i: entity ov_sccb_tb port map (
--			reset => reset,
--			clk100 => clk100
--		);
--	end generate;
	
--	ENABLE_KERNEL3_TB_if: if ENABLE_KERNEL3_TB generate
--		kernel3_tb_i: entity kernel3_tb port map (
--			reset => reset,
--			clk => clk100
--		);
--	end generate;
	
--	ENABLE_PROCESSING_TB_if: if ENABLE_PROCESSING_TB generate
--		processing_tb_i: entity processing_tb port map (
--			reset => reset,
--			clk => clk100
--		);
--	end generate;
	
--	ENABLE_FRAME_BUFFER_Y_TB_if: if ENABLE_FRAME_BUFFER_Y_TB generate
--		frame_buffer_y_tb_i: entity frame_buffer_y_tb port map (clk => clk100);
--	end generate;
	
--	ENABLE_DELAYER_TB_if: if ENABLE_DELAYER_TB generate
--		delayer_tb_i: entity delayer_tb port map (
--			reset => reset,
--			clk => clk100
--		);
--	end generate;
	
--	ENABLE_AGGREGATOR_TB_if: if ENABLE_AGGREGATOR_TB generate
--		aggregator_tb_i: entity asdf_tb port map (
--			reset => reset,
--			clk => clk100
--		);
--	end generate;
	
--	ENABLE_MIN_MAX_FINDER_TB_if: if ENABLE_MIN_MAX_FINDER_TB generate
--		min_max_finder_tb_i: entity min_max_finder_tb port map (
--			reset => reset,
--			clk => clk100
--		);
--	end generate;
	
--	a:entity filter_tb port map(reset=>reset,clk=>clk100);
--	b:entity tmp port map(reset=>reset,clk=>clk100);
--	c:entity frame_buffer_y_tb port map(reset=>reset,clk100=>clk100);
--	d:entity tmp2 port map(reset=>reset,clk=>clk100);
	e:entity tmp3 port map(rst=>reset,clk=>clk100);
end architecture;
