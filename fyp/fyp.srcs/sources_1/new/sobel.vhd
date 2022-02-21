library ieee;
use ieee.all;
use std_logic_1164.all;
use numeric_std.all;
use work.all;
use helper.all;

entity sobel is
	generic (
		H, V: natural;
		ADDR_LENGTH: natural
	);
	port (
		reset: in std_logic;
		clk: in std_logic;
		addr_r, addr_w: out unsigned(ADDR_LENGTH - 1 downto 0);
		pixel_r: in unsigned(PIXEL_LENGTH - 1 downto 0);
		pixel_w: out unsigned(PIXEL_LENGTH - 1 downto 0);
		we: out std_logic
	);
end entity;

architecture sobel_a of sobel is
	constant KERNEL_X: integer_vector(0 to 8) := (1, 0, -1, 2, 0, -2, 1, 0, -1);
	constant KERNEL_Y: integer_vector(0 to 8) := (1, 2, 1, 0, 0, 0, -1, -2, -1);
	constant PROCESSED_PIXEL_LENGTH: natural := PIXEL_LENGTH * 3;
	constant THRESHOLD: natural := 4;
	signal state: unsigned(3 downto 0);
	signal pixel_w_x, pixel_w_y: unsigned(PROCESSED_PIXEL_LENGTH - 1 downto 0);
begin
	process (all)
		variable sum: unsigned(pixel_w_x'length + 1 - 1 downto 0);
	begin
		sum := ("0" & pixel_w_x) + ("0" & pixel_w_y);
		sum := "0" & sum(sum'left downto 1);
		if sum <= (sum'length - pixel_w'length downto 1 => '0') & (pixel_w'range => '1') then
			pixel_w <= sum(pixel_w'range);
		else
			pixel_w <= (others => '1');
		end if;
	end process;
	
	kernel3_controller_i: entity kernel3_controller generic map (
		H => H,
		V => V,
		ADDR_LENGTH => ADDR_LENGTH
	) port map (
		reset => reset,
		clk => clk,
		state => state,
		addr_r => addr_r,
		addr_w => addr_w,
		we => we
	);
	
	kernel3_convolutor_x_i: entity kernel3_convolutor generic map (
		KERNEL => KERNEL_X,
		PROCESSED_PIXEL_LENGTH => PROCESSED_PIXEL_LENGTH,
		THRESHOLD => THRESHOLD
	) port map (
		clk => clk,
		state => state,
		pixel_r => pixel_r,
		pixel_w => pixel_w_x
	);
	kernel3_convolutor_y_i: entity kernel3_convolutor generic map (
		KERNEL => KERNEL_Y,
		PROCESSED_PIXEL_LENGTH => PROCESSED_PIXEL_LENGTH,
		THRESHOLD => THRESHOLD
	) port map (
		clk => clk,
		state => state,
		pixel_r => pixel_r,
		pixel_w => pixel_w_y
	);
end architecture;
