library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.all;

entity kernel3_tb is
	generic (
		H, V: natural;
		ADDR_LENGTH: natural;
		PIXEL_LENGTH: natural;
		PIXEL_R: unsigned(PIXEL_LENGTH - 1 downto 0)
	);
	port (
		reset, clk100: in std_logic;
		addr_r, addr_w: out unsigned(ADDR_LENGTH - 1 downto 0);
		pixel_w: out unsigned(PIXEL_LENGTH - 1 downto 0);
		we: out std_logic
	);
end entity;

architecture kernel3_tb_a of kernel3_tb is
	constant KERNEL: integer_vector := (1, 0, -1, 2, 0, -2, 1, 0, -1);
	constant PROCESSED_PIXEL_LENGTH: natural := PIXEL_LENGTH * 3;
	constant NORM_SHIFT: natural := 2;
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
		PIXEL_LENGTH => PIXEL_LENGTH,
		KERNEL => KERNEL,
		PROCESSED_PIXEL_LENGTH => PROCESSED_PIXEL_LENGTH,
		NORM_SHIFT => NORM_SHIFT
	) port map (
		CLK100 => clk100,
		state => state,
		pixel_r => PIXEL_R,
		pixel_w => pixel_w
	);
end architecture;
