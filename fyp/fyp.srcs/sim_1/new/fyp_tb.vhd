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
	signal clk100: std_logic := '1';
	signal reset: std_logic := '1';
begin
	check_assertions;
	
	process begin
		wait for PERIOD100 / 2;
		clk100 <= not clk100;
	end process;
	
	process begin
		wait until falling_edge(clk100);
		reset <= '0';
		wait;
	end process;
	
	ENABLE_OV_SCCB_TB_if: if ENABLE_OV_SCCB_TB generate
		ov_sccb_tb_i: entity ov_sccb_tb port map (
			reset => reset,
			clk100 => clk100
		);
	end generate;
	
	ENABLE_KERNEL3_TB_if: if ENABLE_KERNEL3_TB generate
		kernel3_tb_i: entity kernel3_tb port map (
			reset => reset,
			clk => clk100
		);
	end generate;
	
	ENABLE_PROCESSING_TB_if: if ENABLE_PROCESSING_TB generate
		processing_tb_i: entity processing_tb port map (
			reset => reset,
			clk => clk100
		);
	end generate;
	
	ENABLE_FRAME_BUFFER_Y_TB_if: if ENABLE_FRAME_BUFFER_Y_TB generate
		frame_buffer_y_tb_i: entity frame_buffer_y_tb port map (clk => clk100);
	end generate;
end architecture;
