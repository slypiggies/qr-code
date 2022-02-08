library ieee;
use ieee.all;
use std_logic_1164.all;
use numeric_std.all;
use work.all;
use helper_tb.all;
use helper.all;

entity kernel3_tb is
	port (
		reset, clk100: in std_logic;
		addr_r, addr_w: out unsigned(ADDR_LENGTH - 1 downto 0);
		pixel_r: in unsigned(PIXEL_LENGTH - 1 downto 0);
		pixel_w: out unsigned(PROCESSED_PIXEL_LENGTH - 1 downto 0);
		we: out std_logic
	);
end entity;

architecture kernel3_tb_a of kernel3_tb is
	constant KERNEL: integer_vector(0 to 8) := (-1, -2, -1, 0, 0, 0, 0, 0, 0);
	constant THRESHOLD: natural := 16;
	signal state: unsigned(3 downto 0);
begin
	kernel3_controller_i: entity kernel3_controller generic map (
		H => H,
		V => V,
		ADDR_LENGTH => ADDR_LENGTH
	) port map (
		reset => reset,
		CLK100 => clk100,
		state => state,
		addr_r => addr_r,
		addr_w => addr_w,
		we => we
	);
	
	kernel3_convolutor_i: entity kernel3_convolutor generic map (
		KERNEL => KERNEL,
		PROCESSED_PIXEL_LENGTH => PROCESSED_PIXEL_LENGTH,
		THRESHOLD => THRESHOLD
	) port map (
		CLK100 => clk100,
		state => state,
		pixel_r => pixel_r,
		pixel_w => pixel_w
	);
end architecture;
