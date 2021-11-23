library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity kernel3_convolutor is
	generic (
		PIXEL_LENGTH: natural;
		KERNEL: integer_vector;
		PROCESSED_PIXEL_LENGTH: natural;
		NORM_SHIFT: natural
	);
	port (
		CLK100: in std_logic;
		state: in unsigned(3 downto 0);
		pixel_r: in unsigned(PIXEL_LENGTH - 1 downto 0);
		pixel_w: out unsigned(PIXEL_LENGTH - 1 downto 0)
	);
end entity;

architecture kernel3_convolutor_a of kernel3_convolutor is
	signal sum, sum_abs: signed(PROCESSED_PIXEL_LENGTH - 1 downto 0);
begin
	sum_abs <=
		sum when sum >= to_signed(0, sum'length)
		else -sum;
	pixel_w <= unsigned(sum_abs(NORM_SHIFT + pixel_w'length - 1 downto NORM_SHIFT));
	process (all)
		variable product: signed(sum'range);
	begin
		product := (
			product'length - (pixel_r'length + 1) * 2 - 1 downto 0 => '0'
		) & signed("0" & pixel_r) * to_signed(KERNEL(to_integer(state)), pixel_r'length + 1);
		if rising_edge(CLK100) then
			if state = X"0" then
				sum <= product;
			else
				sum <= sum + product;
			end if; 
		end if;
	end process;
end architecture;
